<?php

namespace App\Http\Controllers\Order;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\Order;
use App\Models\Sequence;
use App\Models\Actor;
use App\Http\Controllers\Controller;
use App\Models\OrderItem;
use App\Models\Coupon;
use App\Models\Variant;
use App\Models\StockQuantity;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use App\Support\TenantGuard;

class OrderController extends Controller
{
    public function index(Request $request)
    {
        // $validator = Validator::make($request->all(), [
        //     "date" => "required",
        // ]);

        // if ($validator->fails()) {
        //     return response()->json(["status" => "FAIL", "message" => $validator->errors()]);
        // }
        $user = Auth::user();
        if ($user) {
            if (isset($request->all()["client_id"])) {
                $client_id = $request->all()["client_id"];
                $actor = Actor::where("user_id", $user->id)->first();

                $order = Order::where("client_id", "=", $client_id)
                    ->where("actor_id", $actor->id)
                    ->with("orderitem", "client.Address.City", "client.Address.State", "client.Address.Country", "tracking.actor")
                    ->get();
            } else if (isset($request->all()["date"])) {
                $date = $request->all()["date"];
                $actor = Actor::where("user_id", $user->id)->first();
                $order = Order::whereBetween("order_date", [$date . " 00:00:00", $date . " 23:59:59"])
                    ->where("actor_id", $actor->id)
                    ->with(["orderitem", "client.Address.City", "client.Address.State", "client.Address.Country", "tracking.actor", "tracking" => function ($query) {
                        $query->orderBy('created_at', 'asc');
                    }])
                    ->withSum("PurchaseOrders", "total_amount", "residual")
                    ->withSum("PurchaseOrders", "residual")
                    ->orderBy("code")
                    ->get();
            } else {
                return response()->json(["status" => "SUCCESS", "data" => null]);
            }
            return response()->json(["status" => "SUCCESS", "data" => $order]);
        } else {
            return response()->json(["status" => "error", "message" => "User is not authentified"]);
        }
    }


    public function create(Request $request)
    {
        try {
            DB::beginTransaction();
            $user = Auth::user();
            if ($user) {
                $validator = Validator::make($request->all(), [
                    "id" => "required",
                    "track_id" => "required",
                    "client_id" => "required",
                    "order_date" => "required",
                    "planned_delivery_date" => "required",
                    "state" => "required",
                    "orderitems" => "required",
                ]);

                if ($validator->fails()) {
                    return response()->json(["status" => "FAIL", "message" => $validator->errors()]);
                }
                $data = $request->all();
                $client = TenantGuard::client($data["client_id"], $user);
                if (!$client) {
                    DB::rollback();
                    return TenantGuard::forbiddenResponse();
                }
                $warehouseIds = array_map(function ($item) {
                    return isset($item["warehouse_id"]) ? $item["warehouse_id"] : null;
                }, $data["orderitems"]);
                $warehouses = TenantGuard::warehouses($warehouseIds, $user);
                if ($warehouses->count() != count(array_unique(array_filter($warehouseIds)))) {
                    DB::rollback();
                    return TenantGuard::forbiddenResponse();
                }
                $existingOrder = Order::where("id", $data["id"])->first();
                if ($existingOrder && !TenantGuard::order($data["id"], $user)) {
                    DB::rollback();
                    return TenantGuard::forbiddenResponse();
                }
                $unvailable_stock = StockQuantity::checkStockLevel($data["orderitems"]);
                if (count($unvailable_stock) > 0) {
                    $variants = Variant::whereIn("id", $unvailable_stock)->get();
                    DB::rollback();
                    return response()->json(["status" => "FAIL", "code" => "300", "message" => "stock unavailable", "data" => $variants]);
                }
                $total_amount = 0;
                $coupon_substrate = false;
                foreach ($data["orderitems"] as $item) {
                    //extrait les element du items
                    $total_amount += $item["quantity"] * $item["price"];
                    $orderitem = OrderItem::where("id", $item["id"])->first();
                    if (!$orderitem) {
                        $oi = OrderItem::create(($item));
                        if ($oi) {
                            //warehouse,variant_id,quantity
                            if (isset($item["coupon_id"]) && $item["coupon_id"] != null && $item["coupon_id"] != "") {
                                if (!$coupon_substrate) {
                                    Coupon::Substrate($item["coupon_id"]);
                                    $coupon_substrate = true;
                                }
                            }
                            $ret = StockQuantity::SubPrevionnelStockQuantity($item["warehouse_id"], $item["variant_id"], $item["quantity"] * ($item["unite"] == "Cart" ?  $item["package"] : 1));
                        }
                    }
                }
                $order = Order::where("id", $data["id"])->with("orderitem")->first();
                if (!$order) {
                    $data["total_amount"] = $total_amount;
                    $data["residual"] = $total_amount;
                    $actor = Actor::where("user_id", $user->id)->first();
                    $data["actor_id"] = $actor->id;
                    $seq = Sequence::where("resource", "Order")->where("res_id", $actor->id)->first();
                    $data["code"] = $seq->prefix . $this->completeChars(($seq->current + 1), $seq->position);
                    $order = Order::create($data);
                    $order = Order::where("id", $order->id)->with("orderitem")->first();
                    if ($order) {
                        $seq->Next("Order");
                        $ret = $order->toPurchaseOrder($data["track_id"]);
                        DB::commit();
                        return response()->json(["status" => "SUCCESS", "data" => $order]);
                    }
                }
                $ret = $order->toPurchaseOrder($data["track_id"]);
                DB::commit();
                return response()->json(["status" => "SUCCESS", "data" => $order]);
            } else {
                DB::rollback();
                return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
            }
        } catch (\Exception $e) {
            DB::rollback();
            return response()->json(["status" => "FAIL", "message" => $e->getMessage()]);
        }
    }

    public function statusOrder(Request $request)
    {
        $user = Auth::user();
        if ($user) {
            $validator = Validator::make($request->all(), [
                "status" => "required",
            ]);
            $status = $request->all()["status"];
            if ($validator->fails()) {
                return response()->json(["status" => "FAIL", "message" => $validator->errors()]);
            }
            $actor = Actor::where("user_id", $user->id)->first();

            $orders = Order::where("actor_id", $actor->id)
                            ->where("order_date", ">=", date("Y-m-01"))
                            ->with(["PurchaseOrders" => function ($query) use ($status) {
                                    $query->where("state", $status);
                            },"client"])
                            ->whereHas('PurchaseOrders', function ($query) use ($status) {
                                $query->where('state', $status);
                            })
                            ->get();
            return response()->json(["status" => "SUCCESS", "data" => $orders]);
        } else {
            return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
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
