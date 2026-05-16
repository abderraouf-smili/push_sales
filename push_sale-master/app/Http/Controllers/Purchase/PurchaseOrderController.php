<?php

namespace App\Http\Controllers\Purchase;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\PurchaseOrder;
use App\Models\Sequence;
use App\Models\Actor;
use App\Http\Controllers\Controller;
use App\Http\Controllers\NotificationController;
use App\Models\DeliveryProof;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\PurchaseOrderItem;
use App\Models\StockMobile;
use App\Models\Variant;
use App\Models\StockQuantity;
use App\Models\TrackingOrders;
use App\Models\Transactions;
use App\Models\TransactionType;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use App\Support\TenantGuard;


class PurchaseOrderController extends Controller
{
    public function index(Request $request)
    {
        $user = Auth::user();
        if ($user) {
            $actor = TenantGuard::actor($user);
            $query = PurchaseOrder::where("type", "invoice_in")
                ->with("orderitem")
                ->select(["id","code","purchase_date","total_amount"])
                ->orderBy('purchase_date', 'desc');
            if ($actor && $actor->distributor_id) {
                $query->forDistributor($actor->distributor_id);
            } else {
                $query->where("actor_id", $actor ? $actor->id : null);
            }
            $data = $query->get();
            return response()->json(["status" => "SUCCESS", "data" => $data]);
        } else {
            return response()->json(["status" => "error", "message" => "User is not authentified"]);
        }
    }


    public function create(Request $request)
    {
        $user = Auth::user();
        if ($user) {
            $validator = Validator::make($request->all(), [
                "id" => "required",
                "purchase_date" => "required",
                "state" => "required",
                "orderitems" => "required",
            ]);

            if ($validator->fails()) {
                return response()->json(["status" => "FAIL", "message" => $validator->errors()]);
            }
            $data = $request->all();
            DB::beginTransaction();
            try {
                $actor = TenantGuard::actor($user);
                $order = TenantGuard::purchaseOrder($data["id"], $user);
                $rawOrderExists = PurchaseOrder::where("id", $data["id"])->exists();
                if (!$order && $rawOrderExists) {
                    DB::rollBack();
                    return TenantGuard::forbiddenResponse();
                }

                $warehouse = TenantGuard::warehouse($data["warehouse_id"], $actor);
                if (!$warehouse) {
                    DB::rollBack();
                    return TenantGuard::forbiddenResponse();
                }

                $warehouseIds = array_map(function ($item) {
                    return isset($item["warehouse_id"]) ? $item["warehouse_id"] : null;
                }, $data["orderitems"]);
                $warehouses = TenantGuard::warehouses($warehouseIds, $actor);
                if ($warehouses->count() != count(array_unique(array_filter($warehouseIds)))) {
                    DB::rollBack();
                    return TenantGuard::forbiddenResponse();
                }

                foreach ($data["orderitems"] as $item) {
                    if ($item["warehouse_id"] != $warehouse->id) {
                        DB::rollBack();
                        return TenantGuard::forbiddenResponse();
                    }
                    //extrait les element du items
                    $orderitem = PurchaseOrderItem::where("id", $item["id"])->first();
                    if (!$orderitem) {
                        $oi = PurchaseOrderItem::create(($item));
                        if ($oi) {
                            //warehouse,variant_id,quantity
                            StockQuantity::AddRealStockQuantity($item["warehouse_id"], $item["variant_id"], $item["quantity"] * ($item["unite"] == "Cart" ?  $item["package"] : 1), $item["price"]);
                        }
                    }
                }
                if (!$order) {
                    $data["actor_id"] = $actor->id;
                    $data["residual"] = $data["total_amount"];
                    $seq = Sequence::where("resource", "PurchaseOrder")->where("res_id", $actor->id)->first();
                    $data["code"] = $seq->prefix . $this->completeChars(($seq->current + 1), $seq->position);
                    $order = PurchaseOrder::create($data);
                    $order = PurchaseOrder::where("id", $order->id)->with("orderitem")->first();
                    if ($order) {
                        $seq->Next("PurchaseOrder");
                        DB::commit();
                        return response()->json(["status" => "SUCCESS", "data" => $order]);
                    }
                }
                DB::commit();
                return response()->json(["status" => "SUCCESS", "data" => $order]);
            } catch (\Exception $e) {
                DB::rollback();
                return response()->json(["status" => "FAIL", "message" => $e->getMessage()]);
            }
        } else {
            return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
        }
    }

    //@ les nouvelles commandes pour le chargement qui sont utilisées dans la section transfert=>livraisons
    public function getOrdersReadyToPack()
    {
        $user = Auth::user();
        if ($user) {
            $actor = Actor::where("user_id", $user->id)->first();
            if ($actor->distributor_id) {
                $orders = PurchaseOrder::where("type", "invoice_out")
                    ->with("orderitem", "client.Address.city", "client.Address.state", "warehouse.address.city", "warehouse.address.state")
                    ->wherenull("actor_id")
                    ->where("state", "!=", "cancelled")
                    ->whereBetween("planned_delivery_date", [date('Y-m-d 00:00:00'), date('Y-m-d 23:59:59', strtotime(now() . ' +1 day'))])
                    ->whereHas("warehouse.distributor", function ($query) use ($actor) {
                        $query->where("distributor.private", "1")
                            ->where("distributor.id", $actor->distributor_id);
                    })
                    ->get();
                return response()->json(["status" => "SUCCESS", "data" => $orders]);
            } else {
                return response()->json(["status" => "SUCCESS", "data" => []]);
            }
        } else {
            return response()->json(["status" => "error", "message" => "User is not authentified"]);
        }
    }

    //@ les commandes prete pour livraison (dans le menu camion ==> Commandes à livrer)
    public function getOrdersReadyToShip(Request $request)
    {
        try {
            $user = Auth::user();
            if ($user) {
                $actor = Actor::where("user_id", $user->id)->first();
                $purchase_orders = PurchaseOrder::where("actor_id", $actor->id)
                    ->whereBetween("planned_delivery_date", [date('Y-m-d 00:00:00'), date('Y-m-d 23:59:59')])
                    ->whereIn("state", ["in_way", "shipped", "returned", "paid"])
                    ->where("type", "invoice_out")
                    ->with("orderitem", "client.Address.city", "client.Address.state", "client.Address.country", "cash", "delivery_proof")
                    ->withSum("cash", "debit")
                    ->get();
                return response()->json(["status" => "SUCCESS", "data" => $purchase_orders]);
            } else {
                return response()->json(["status" => "error", "message" => "User is not authentified"]);
            }
        } catch (\Exception $e) {
            DB::rollback();
            return response()->json(["status" => "FAIL", "message" => $e->getMessage()]);
        }
    }

    // pour livreur à l'écran de livrer
    public function setOrderShipped(Request $request)
    {
        $user = Auth::user();
        if ($user) {
            $validator = Validator::make($request->all(), [
                "id" => "required",
                "track_id" => "required",
                "purchase_date" => "required",
                "state" => "required",
                "orderitems" => "required",
            ]);

            if ($validator->fails()) {
                return response()->json(["status" => "FAIL", "message" => $validator->errors()]);
            }
            try {
                $data = $request->all();
                DB::beginTransaction();
                $actor = TenantGuard::actor($user);
                $visiblePo = PurchaseOrder::visibleToActor($actor)
                    ->where("id", $data["id"])
                    ->where("actor_id", $actor->id)
                    ->first();
                if (!$visiblePo) {
                    DB::rollBack();
                    return TenantGuard::forbiddenResponse();
                }
                $po = $visiblePo->state == "in_way" ? $visiblePo : null;
                $location = StockMobile::where("actor_id", $actor->id)->first();
                if ($po) {
                    foreach ($data["orderitems"] as $item) {
                        PurchaseOrderItem::where("id", $item["id"])
                            ->where("purchaseorder_id", $po->id)
                            ->update(
                            [
                                "quantity" => $item["quantity"],
                                "unite" => $item["unite"],
                                "price" => $item["price"],
                                "confirmed_quantity" => $item["confirmed_quantity"],
                                "cancelled_quantity" => $item["cancelled_quantity"],
                            ]
                        );
                        OrderItem::where("order_id", $po->order_id)
                            ->where("variant_id", $item["variant_id"])
                            ->update(
                                [
                                    "quantity" => $item["quantity"],
                                    "unite" => $item["unite"],
                                    "price" => $item["price"],
                                    "confirmed_quantity" => $item["confirmed_quantity"],
                                    "cancelled_quantity" => $item["cancelled_quantity"],
                                ]
                            );
                        StockQuantity::SubStockPrevRealQuantity($location->id, $item["variant_id"], $item["confirmed_quantity"] * ($item["unite"] == "Cart" ? $item["package"] : 1));
                    }
                }


                // if delivery proof exist, then add it at attachment and save path
                if (isset($data["delivery_proof"])) {
                    $directory = storage_path('app/public') . "/delivery_proof";
                    if (!file_exists($directory)) {
                        mkdir($directory, 0775, true);
                    }
                    $path = $directory . "/" . $data["id"] . ".jpg";
                    $image = base64_decode($data["delivery_proof"]);
                    file_put_contents($path, $image);
                }

                $torder = TrackingOrders::where("purchaseorder_id", $data["id"])->where("state", "shipped")->first();
                if (!$torder && $po) {
                    TrackingOrders::create([
                        "id" => $data["track_id"],
                        "order_id" => $po->order_id,
                        "purchaseorder_id" => $po->id,
                        "state" => "shipped",
                        "amount" => $data["total_amount"],
                        "image" => isset($data["delivery_proof"]) ? "/storage/delivery_proof/" . $data["id"] . ".jpg" : null,
                        "actor_id" => $actor->id,
                        "is_last" => ($data["total_amount"] == 0),
                    ]);
                    $notif = new NotificationController();
                    $notif_o = Order::where("id", $po->order_id)->first();
                    // Log::info($notif_o->actor_id);
                    $notif_u = Actor::where('id',$notif_o->actor_id)->first();
                    Log::info("Send Notification to Actor: " . $notif_u->firstname . " " . $notif_u->lastname . " - order :" . $po->code);
                    $params = [
                        "user_id" => $notif_u->user_id,
                        "title" => "Order Status - " . $po->code,
                        "body"  => "The order has been shipped",
                    ];
                    // Log::info((object)$params);
                    $notif->send((object)$params);

                }


                // creation d'écriture de vente
                if ($po) {
                    if ($data["total_amount"] != 0) {
                        Transactions::create([
                            "id" => $data["track_id"] . "-" . "S",
                            "client_id"         => $po->client_id,
                            "actor_id"          => $actor->id,
                            "order_id"          => $po->order_id,
                            "purchaseorder_id"  => $po->id,
                            "type_id"           => TransactionType::SALE(),
                            "credit"            => $data["total_amount"],
                            "debit"             => 0,
                            "account_date"      => date("Y-m-d"),
                        ]);
                    }
                }
                // en cas d'encaissement
                if (isset($data["collected"]) && isset($data["attached"])) {
                    if ($po) {
                        if ($data["attached"]) { //encaissement lettré
                            if ($data["collected"] != 0) {
                                Transactions::create([
                                    "id" => $data["track_id"] . "-" . "C",
                                    "client_id"         => $po->client_id,
                                    "actor_id"          => $actor->id,
                                    "order_id"          => $po->order_id,
                                    "purchaseorder_id"  => $po->id,
                                    "type_id"           => TransactionType::CASH(),
                                    "credit"            => 0,
                                    "debit"             => $data["collected"],
                                    "account_date"      => date("Y-m-d"),
                                ]);
                            }
                            TrackingOrders::create([
                                "id" => $data["track_id"] . "-" . "P",
                                "order_id" => $po->order_id,
                                "purchaseorder_id" => $po->id,
                                "state" => $data["total_amount"] - ($po->total_amount - $po->residual) - $data["collected"] == 0 ? "paid" : "partially_paid",
                                "amount" => $data["collected"],
                                "actor_id" => $actor->id,
                                "is_last" =>  $data["total_amount"] - ($po->total_amount - $po->residual) - $data["collected"] == 0,
                            ]);
                            PurchaseOrder::where("id", $data["id"])
                                ->update([
                                    "state" => $data["total_amount"] - ($po->total_amount - $po->residual) - $data["collected"] == 0 ? "paid" : "shipped",
                                    "total_amount" => $data["total_amount"],
                                    "residual" => $data["total_amount"] - ($po->total_amount - $po->residual) - $data["collected"],
                                    "delivery_date" => date("Y-m-d H:i:s")
                                ]);
                        } else { //encaissement non lettré
                            if ($data["collected"] != 0) {
                                Transactions::create([
                                    "id" => $data["track_id"] . "-" . "C",
                                    "client_id"         => $po->client_id,
                                    "actor_id"          => $actor->id,
                                    "type_id"           => TransactionType::CASH(),
                                    "credit"            => 0,
                                    "debit"             => $data["collected"],
                                    "account_date"      => date("Y-m-d"),
                                ]);
                            }
                            PurchaseOrder::where("id", $data["id"])
                                ->update([
                                    "state" => "shipped",
                                    "total_amount" => $data["total_amount"],
                                    "delivery_date" => date("Y-m-d H:i:s")
                                ]);
                        }
                    } else {
                        $po = $visiblePo;
                        if ($data["attached"]) { //encaissement lettré
                            $ecr = Transactions::where("purchaseorder_id", $data["id"])->where("type_id", TransactionType::CASH())->first();

                            if (!$ecr) {
                                if ($data["collected"] != 0) {
                                    Transactions::create([
                                        "id" => $data["track_id"] . "-" . "C",
                                        "client_id"         => $po->client_id,
                                        "actor_id"          => $actor->id,
                                        "order_id"          => $po->order_id,
                                        "purchaseorder_id"  => $po->id,
                                        "type_id"           => TransactionType::CASH(),
                                        "credit"            => 0,
                                        "debit"             => $data["collected"],
                                        "account_date"      => date("Y-m-d"),
                                    ]);
                                }
                                TrackingOrders::create([
                                    "id" => $data["track_id"]  . "-" . "P",
                                    "order_id" => $po->order_id,
                                    "purchaseorder_id" => $po->id,
                                    "state" => $data["total_amount"] - ($po->total_amount - $po->residual) - $data["collected"] == 0 ? "paid" : "partially_paid",
                                    "amount" => $data["collected"],
                                    "actor_id" => $actor->id,
                                    "is_last" => $data["total_amount"] - ($po->total_amount - $po->residual) - $data["collected"] == 0,
                                ]);
                                PurchaseOrder::where("id", $data["id"])->update([
                                    "state" => $data["total_amount"] - ($po->total_amount - $po->residual) - $data["collected"] == 0 ? "paid" : "shipped",
                                    "residual" => $data["total_amount"] - ($po->total_amount - $po->residual) - $data["collected"],
                                    "total_amount" => $data["total_amount"],
                                    "delivery_date" => date(
                                        "Y-m-d H:i:s"
                                    )
                                ]);
                            }
                        } else { //encaissement non lettré
                            if ($data["collected"] != 0) {
                                Transactions::create([
                                    "id" => $data["track_id"] . "-" . "C",
                                    "client_id"         => $po->client_id,
                                    "actor_id"          => $actor->id,
                                    "type_id"           => TransactionType::CASH(),
                                    "credit"            => 0,
                                    "debit"             => $data["collected"],
                                    "account_date"      => date("Y-m-d"),
                                ]);
                            }
                            // PurchaseOrder::where("id", $data["id"])->update(["state" => "shipped", "delivery_date" => date("Y-m-d H:i:s")]);
                        }
                    }
                } else {
                    PurchaseOrder::where("id", $data["id"])->update(
                        [
                            "state" => "shipped",
                            "delivery_date" => date("Y-m-d H:i:s"),
                            "total_amount" => $data["total_amount"],
                            "residual" => $data["total_amount"] - ($po->total_amount - $po->residual)

                        ]
                    );
                }
                DB::commit();
                return response()->json(["status" => "SUCCESS", "data" => $po]);
            } catch (\Exception $e) {
                DB::rollback();
                return response()->json(["status" => "FAIL", "message" => $e->getMessage()]);
            }
        } else {
            return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
        }
    }

    // pour l'encaissement à partir de l'écran du livreur
    public function setNewCashOrder(Request $request)
    {
        $user = Auth::user();
        if ($user) {
            $validator = Validator::make($request->all(), [
                "purchaseorder_id" => "required",
                "client_id" => "required",
                "track_id" => "required",
                "collected" => "required",
                "attached" => "required",
            ]);

            if ($validator->fails()) {
                return response()->json(["status" => "FAIL", "message" => $validator->errors()]);
            }
            $data = $request->all();
            try {
                $actor = TenantGuard::actor($user);
                DB::beginTransaction();
                $po = TenantGuard::purchaseOrder($data["purchaseorder_id"], $user);
                if (!$po) {
                    DB::rollBack();
                    return TenantGuard::forbiddenResponse();
                }
                if ($po) {
                    if ($data["attached"] && $po->residual != 0 && $po->state != "paid") {
                        // cash for the order
                        if ($data["collected"] > 0) {
                            if ($data["collected"] - $po->residual == 0) {
                                //lettrer order only
                                PurchaseOrder::where("id", $data["purchaseorder_id"])->update([
                                    "residual" => 0,
                                    "state" => "paid",
                                ]);
                                Transactions::create([
                                    "id"                => $data["track_id"],
                                    "client_id"         => $po->client_id,
                                    "actor_id"          => $actor->id,
                                    "order_id"          => $po->order_id,
                                    "purchaseorder_id"  => $po->id,
                                    "type_id"           => TransactionType::CASH(),
                                    "credit"            => 0,
                                    "debit"             => $data["collected"],
                                    "account_date"      => date("Y-m-d"),
                                ]);

                                TrackingOrders::create([
                                    "id"                => $data["track_id"],
                                    "order_id"          => $po->order_id,
                                    "purchaseorder_id"  => $po->id,
                                    "state"             => "paid",
                                    "amount"            => $data["collected"],
                                    "actor_id"          => $actor->id,
                                    "is_last"           => 1,
                                ]);
                            } else if ($data["collected"] - $po->residual > 0) {
                                //lettrer et ajouter la difference
                                PurchaseOrder::where("id", $data["purchaseorder_id"])->update([
                                    "residual" => 0,
                                    "state" => "paid",
                                ]);

                                Transactions::create([
                                    "id" => $data["track_id"],
                                    "client_id"         => $po->client_id . "-" . "C",
                                    "actor_id"          => $actor->id,
                                    "order_id"          => $po->order_id,
                                    "purchaseorder_id"  => $po->id,
                                    "type_id"           => TransactionType::CASH(),
                                    "credit"            => 0,
                                    "debit"             => $po->residual,
                                    "account_date"      => date("Y-m-d"),
                                ]);
                                Transactions::create([
                                    "id" => $data["track_id"] . "-" . "CC",
                                    "client_id"         => $po->client_id,
                                    "actor_id"          => $actor->id,
                                    "type_id"           => TransactionType::CASH(),
                                    "credit"            => 0,
                                    "debit"             => $data["collected"] - $po->residual,
                                    "account_date"      => date("Y-m-d"),
                                ]);

                                TrackingOrders::create([
                                    "id" => $data["track_id"],
                                    "order_id" => $po->order_id,
                                    "purchaseorder_id" => $po->id,
                                    "state" => "paid",
                                    "amount" => $data["collected"],
                                    "actor_id" => $actor->id,
                                    "is_last" => 1,
                                ]);
                            } else {
                                // pas totalement ecaissé
                                PurchaseOrder::where("id", $data["purchaseorder_id"])->update([
                                    "residual" => $po->residual - $data["collected"],
                                ]);

                                Transactions::create([
                                    "id" => $data["track_id"],
                                    "client_id"         => $po->client_id,
                                    "actor_id"          => $actor->id,
                                    "order_id"          => $po->order_id,
                                    "purchaseorder_id"  => $po->id,
                                    "type_id"           => TransactionType::CASH(),
                                    "credit"            => 0,
                                    "debit"             => $data["collected"],
                                    "account_date"      => date("Y-m-d"),
                                ]);

                                TrackingOrders::create([
                                    "id" => $data["track_id"],
                                    "order_id" => $po->order_id,
                                    "purchaseorder_id" => $po->id,
                                    "state" => "partially_paid",
                                    "amount" => $data["collected"],
                                    "actor_id" => $actor->id,
                                    "is_last" => 0,
                                ]);
                            }
                        }
                    } else {
                        // cash for no order
                        Transactions::create([
                            "id"                => $data["track_id"],
                            "client_id"         => $po->client_id,
                            "actor_id"          => $actor->id,
                            "type_id"           => TransactionType::CASH(),
                            "credit"            => 0,
                            "debit"             => $data["collected"],
                            "account_date"      => date("Y-m-d"),
                        ]);
                    }
                } else {
                    return response()->json(["status" => "FAIL", "message" => "No order found"]);
                }
                DB::commit();
                return response()->json(["status" => "SUCCESS", "data" => $po]);
            } catch (\Exception $e) {
                DB::rollback();
                return response()->json(["status" => "FAIL", "message" => $e->getMessage()]);
            }
        } else {
            return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
        }
    }


    // pour l'encaissement à partir de l'écran des créances
    public function saveCashOrders(Request $request)
    {
        $user = Auth::user();
        if ($user) {
            try {
                $validator = Validator::make($request->all(), [
                    "data" => "required",
                    "track_id" => "required",
                ]);
                if ($validator->fails()) {
                    return response()->json(["status" => "FAIL", "message" => $validator->errors()]);
                }
                $data = $request->all()["data"];
                $track_id = $request->all()["track_id"];
                DB::beginTransaction();
                $actor = TenantGuard::actor($user);
                $pos = 0;
                foreach ($data as $item) {
                    $track_id = $track_id . "-" . $pos;
                    $pos++;
                    if ($item["cashed"] > 0) {
                        //$item["purchaseorder_id"];
                        //$item["cashed"];
                        $po = PurchaseOrder::visibleToActor($actor)
                            ->where("id", $item["purchaseorder_id"])
                            ->where("state", "shipped")
                            ->first();
                        if (!$po) {
                            DB::rollBack();
                            return TenantGuard::forbiddenResponse();
                        }
                        if ($po) {
                            PurchaseOrder::where("id", $item["purchaseorder_id"])
                                ->update([
                                    "residual" => $po->residual - $item["cashed"],
                                    "state" => $item["paid"] ? "paid" : "shipped"
                                ]);
                            Transactions::create([
                                "id"                => $track_id,
                                "client_id"         => $po->client_id,
                                "actor_id"          => $actor->id,
                                "order_id"          => $po->order_id,
                                "purchaseorder_id"  => $po->id,
                                "type_id"           => TransactionType::CASH(),
                                "credit"            => 0,
                                "debit"             => $item["cashed"],
                                "account_date"      => date("Y-m-d"),
                            ]);

                            TrackingOrders::create([
                                "id"                => $track_id,
                                "order_id"          => $po->order_id,
                                "purchaseorder_id"  => $po->id,
                                "state"             => $item["paid"] ? "paid" : "partially_paid",
                                "amount"            => $item["cashed"],
                                "actor_id"          => $actor->id,
                                "is_last"           => $item["paid"] ? 1 : 0,
                            ]);
                        }
                    }
                }
                DB::commit();
                return response()->json(["status" => "SUCCESS", "data" =>  "done"]);
            } catch (\Exception $e) {
                DB::rollBack();
                return response()->json(["status" => "FAIL", "message" => $e->getMessage()]);
            }
        } else {
            return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
        }
        return response()->json(["status" => "SUCCESS", "data" => $request->all()]);
    }



    public function changePlannedDate(Request $request)
    {
        $user = Auth::user();
        if ($user) {
            $validator = Validator::make($request->all(), [
                "order_id" => "required",
                "date" => "required",
            ]);

            if ($validator->fails()) {
                return response()->json(["status" => "FAIL", "message" => $validator->errors()]);
            }
            try {
                $data = $request->all();
                DB::beginTransaction();
                $order = TenantGuard::order($data["order_id"], $user);
                if (!$order) {
                    DB::rollBack();
                    return TenantGuard::forbiddenResponse();
                }

                Order::where("id", $order->id)->update([
                    "planned_delivery_date" => $data["date"]
                ]);

                PurchaseOrder::visibleToActor(TenantGuard::actor($user))->where("order_id", $order->id)->update([
                    "planned_delivery_date" => $data["date"]
                ]);

                DB::commit();
                return response()->json(["status" => "SUCCESS", "message" => "succefully updated"]);
            } catch (\Exception $e) {
                DB::rollback();
                return response()->json(["status" => "FAIL", "message" => $e->getMessage()]);
            }
        } else {
            return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
        }
    }

    public function renewOrder(Request $request){
        $user = Auth::user();
        if ($user) {
            $validator = Validator::make($request->all(), [
                "order_id" => "required",
            ]);
            if ($validator->fails()) {
                return response()->json(["status" => "FAIL", "message" => $validator->errors()]);
            }
            $data = $request->all();
            DB::beginTransaction();
            $actor = TenantGuard::actor($user);
            $baseOrder = TenantGuard::order($data["order_id"], $user);
            if (!$baseOrder) {
                DB::rollBack();
                return TenantGuard::forbiddenResponse();
            }
            $order = PurchaseOrder::visibleToActor($actor)->where("order_id",$baseOrder->id)->where("state","expired")->orderBy("created_at","desc")->first();
            if (!$order) {
                DB::rollBack();
                return TenantGuard::forbiddenResponse();
            }

            $orderitems = PurchaseOrderItem::where("purchaseorder_id",$order->id)->get();
            $unvailable_stock = StockQuantity::checkStockLevel($orderitems,$order->warehouse_id);
            $variants = Variant::whereIn("id", $unvailable_stock)->get();
            if (count($unvailable_stock) > 0) {
                return response()->json(["status" => "ERROR", "message" => $variants]);
            }
            foreach ($orderitems as $item) {
                StockQuantity::AddRealStockQuantity($order->warehouse_id, $item["variant_id"], $item["quantity"] * ($item["unite"] == "Cart" ?  $item["package"] : 1), $item["price"]);
            }

            $c_ord = [];
            $keys = explode("-",$order->id);
            $new_id = $order->id;
             if(count($keys) > 4){
                $new_id = $keys[0] . "-" . $keys[1] . "-" .$keys[2] . "-" . $keys[3] . "-" .$keys[4] . "-" . ($keys[5]+1);
            }



            $c_ord["id"] = $new_id;
            $c_ord["code"] = $order->code;
            $c_ord["order_id"] = $order->order_id;
            $c_ord["client_id"] = $order->client_id;
            $c_ord["type"] = $order->type;
            $c_ord["warehouse_id"] = $order->warehouse_id;
            $c_ord["total_amount"] = $order->total_amount;
            $c_ord["residual"] = $order->total_amount;
            $c_ord["purchase_date"] = date("Y-m-d H:i:s");
            $c_ord["planned_delivery_date"] = date("Y-m-d H:i:s");
            $c_ord["state"] = "new";



            $oi_cr_item = [];
            $o_c = PurchaseOrder::create($c_ord);

            foreach($orderitems as $item){
                $oi_cr_item["id"]               = $item["id"] . "-" . "0";
                $oi_cr_item["purchaseorder_id"] = $new_id;
                $oi_cr_item["image"]            = $item["image"];
                $oi_cr_item["product_name"]     = $item["product_name"];
                $oi_cr_item["variant_name_1"]   = $item["variant_name_1"];
                $oi_cr_item["variant_name_2"]   = $item["variant_name_2"];
                $oi_cr_item["promotion_id"]     = $item["promotion_id"];
                $oi_cr_item["promotionitem_id"] = $item["promotionitem_id"];
                $oi_cr_item["coupon_id"]        = $item["coupon_id"];
                $oi_cr_item["unite"]            = $item["unite"];
                $oi_cr_item["discount"]         = $item["discount"];
                $oi_cr_item["variant_id"]       = $item["variant_id"];
                $oi_cr_item["sku"]              = $item["sku"];
                $oi_cr_item["quantity"]         = $item["quantity"];
                $oi_cr_item["package"]          = $item["package"];
                $oi_cr_item["price"]            = $item["price"];
                $a = PurchaseOrderItem::create($oi_cr_item);
            }
            $track = TrackingOrders::where("id", $new_id)->first();
            if (!$track) {
                $purchaseOrder = TrackingOrders::create([
                    "id" => $new_id,
                    "order_id" => $order->order_id,
                    "purchaseorder_id" => $new_id,
                    "state" => "new",
                    "amount" => $order->total_amount,
                    "actor_id" => $order->actor_id,
                    "is_last" => false,
                ]);
                $purchaseOrder->save();
            }

            Order::where("id",$order->order_id)
                ->update([
                    "order_date" => date("Y-m-d H:i:s"),
                    "planned_delivery_date" => date("Y-m-d H:i:s")
                ]);
            DB::commit();
            return response()->json(["status" => "SUCCESS", "message" => $c_ord]);
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
