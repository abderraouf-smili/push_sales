<?php

namespace App\Http\Controllers\Warehouses;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\Order;
use App\Models\Sequence;
use App\Models\Actor;
use App\Http\Controllers\Controller;
use App\Models\Distributor;
use App\Models\TrackingOrders;
use App\Models\PurchaseOrder;
use App\Models\StockMobile;
use App\Models\StockOperation;
use App\Models\StockOperationItems;
use App\Models\Variant;
use App\Models\StockQuantity;
use App\Models\StockWarehouse;
use App\Models\Warehouse;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;

class StockOperationController extends Controller
{


    public function index()
    {
        try {
            $user = Auth::user();
            if ($user) {
                $actor = Actor::where("user_id", $user->id)->first();
                $operations = StockOperation::where("actor_id", $actor->id)
                    ->wherein("state", ["new", "processing"])
                    ->with("items")
                    ->orderBy("created_at", "desc")
                    ->limit(10)
                    ->get();
                return response()->json(["status" => "SUCCESS", "data" => $operations]);
            } else {
                return response()->json(["status" => "error", "message" => "User is not authentified"]);
            }
        } catch (\Exception $e) {
            return response()->json(["status" => "error", "message" => $e->getMessage()]);
        }
    }


    public function create(Request $request)
    {
        $user = Auth::user();
        if ($user) {
            $validator = Validator::make($request->all(), [
                "id" => "required",
                "track_id" => "required",
                "operation_date" => "required",
                "type" => "required",
                "warehouse_id" => "required",
                "items" => "required",
                "purchase_ids" => "required"
            ]);
            if ($validator->fails()) {
                return response()->json(["status" => "FAIL", "message" => $validator->errors()]);
            }
            $data = $request->all();
            try {

                DB::beginTransaction();
                $actor = Actor::where("user_id", $user->id)->first();
                $data["distributor_id"] = Warehouse::where("id", $data["warehouse_id"])->first()["distributor_id"];
                $data["location_id"] = StockMobile::where("actor_id", $actor->id)->first()["id"];
                foreach ($data["items"] as $item) {
                    $item["operation_id"] = $data["id"];
                    $lastPP = StockWarehouse::where("warehouse_id", $data["warehouse_id"])->where("variant_id", $item["variant_id"])->first();
                    $item["stockprice"] = $lastPP->stock_price;
                    StockOperationItems::create($item);
                    StockQuantity::AddPrevisionnelStockQuantity($data["location_id"], $item["variant_id"], $item["quantity"], $item["stockprice"], true);
                }

                $seq = Sequence::where("resource", "Chargement")->where("res_id", $actor->id)->first();
                $data["code"] = $seq->prefix . $this->completeChars(($seq->current + 1), $seq->position);
                $seq->Next("Chargement");

                $data["actor_id"] = $actor->id;
                $bt = StockOperation::create($data);
                if ($bt) {
                    $pos = 0;
                    foreach ($data["purchase_ids"] as $id) {
                        $purchaseOrder = PurchaseOrder::where("id", $id)->first();
                        $purchaseOrder->update(
                            [
                                "actor_id" => $actor->id,
                                "operation_id" => $bt->id,
                                "state" => "taken"
                            ]
                        );
                        TrackingOrders::create([
                            "id" => $data["track_id"] . "-" . $pos,
                            "order_id" => $purchaseOrder->order_id,
                            "purchaseorder_id" => $purchaseOrder->id,
                            "state" => "taken",
                            "actor_id" => $actor->id,
                            "is_last" => false,
                        ]);
                        $pos++;
                        // check purchase orders if all "taken"
                        $purchaseOrders = PurchaseOrder::where("order_id", $purchaseOrder->order_id)
                            ->where("id", "!=", $id)
                            ->where("state", "!=", "taken")
                            ->get();
                        if ($purchaseOrders->count() == 0) {
                            Order::where("id", $purchaseOrder->order_id)->update(["state" => "taken"]);
                        } else {
                            Order::where("id", $purchaseOrder->order_id)->update(["state" => "partial_taken"]);
                        }
                    }
                }
                DB::commit();
                return response()->json(["status" => "SUCCESS", "data" => $bt]);
            } catch (\Exception $e) {
                DB::rollback();
                return response()->json(["status" => "error", "message" => $e->getMessage()]);
            }
        } else {
            return response()->json(["status" => "error", "message" => "User is not authentified"]);
        }
    }


    public function confirm(Request $request)
    {
        $user = Auth::user();
        if ($user) {
            $validator = Validator::make($request->all(), [
                "operation_id" => "required",
                "track_id" => "required",
            ]);
            if ($validator->fails()) {
                return response()->json(["status" => "FAIL", "message" => $validator->errors()]);
            }
            $data = $request->all();
            try {
                DB::beginTransaction();
                $operation = StockOperation::where("id", $data["operation_id"])->with("items")->first();
                $unvailable_stock = StockQuantity::checkRealStockLevel($operation->items, $operation->warehouse_id);

                if (count($unvailable_stock) > 0) {
                    $variants = Variant::whereIn("id", $unvailable_stock)->get();
                    DB::rollback();
                    return response()->json(["status" => "FAIL", "code" => "300", "message" => "stock unavailable", "data" => $variants]);
                }
                foreach ($operation->items as $item) {
                    //soustraire la quantité réelle du dépot pour la rendre égale au prévisionnel
                    StockQuantity::SubStockQuantity($operation->warehouse_id, $item["variant_id"], $item["quantity"]);
                    //Ajouter la quanité au location_id afin de la rendre comme previsionnel
                    StockQuantity::UpdateRealStock($operation->location_id, $item["variant_id"], $item["quantity"]);
                }
                $operation->update(["state" => "processing"]);
                $purchaseorders = PurchaseOrder::where("operation_id", $data["operation_id"])->get();
                $actor = Actor::where("user_id", $user->id)->first();
                $pos = 0;
                foreach ($purchaseorders as $purchaseOrder) {
                    PurchaseOrder::where("id",$purchaseOrder->id)->update(["state" => "in_way"]);
                    TrackingOrders::create([
                        "id" => $data["track_id"] . "-" . $pos,
                        "order_id" => $purchaseOrder->order_id,
                        "purchaseorder_id" => $purchaseOrder->id,
                        "state" => "in_way",
                        "actor_id" => $actor->id,
                        "is_last" => false,
                    ]);
                    $pos++;
                }
                DB::commit();
                return response()->json(["status" => "SUCCESS", "data" => $purchaseorders]);
            } catch (\Exception $e) {
                DB::rollback();
                return response()->json(["status" => "error", "message" => $e->getMessage()]);
            }
        } else {
            return response()->json(["status" => "error", "message" => "User is not authentified"]);
        }
    }

    private function completeChars($number, $p)
    {
        $ret = "";
        for ($i = strlen($number); $i < $p; $i++) {
            $ret .= "0";
        }
        return $ret . $number;
    }
}
