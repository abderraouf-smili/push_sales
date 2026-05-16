<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\Order;
use App\Models\Sequence;
use App\Models\Actor;
use App\Models\OrderItem;
use App\Models\TransactionType;
use Illuminate\Support\Facades\DB;
use App\Support\TenantGuard;

class StatisticsController extends Controller
{

    public function stats()
    {
        $user = Auth::user();
        if ($user) {
            try {
                $actor = Actor::where("user_id", $user->id)->first();
                $monthStart = date("Y-m-01 00:00:00");
                $todayStart = date("Y-m-d 00:00:00");
                $todayEnd = date("Y-m-d 23:59:59");

                $statPie = DB::table("order as o")
                    ->join("orderitem as oi", "oi.order_id", "=", "o.id")
                    ->join("variant as v", "v.id", "=", "oi.variant_id")
                    ->join("product as p", "p.id", "=", "v.product_id")
                    ->join("category as c", "c.id", "=", "p.category_id")
                    ->where("o.actor_id", $actor->id)
                    ->where("o.order_date", ">=", $monthStart)
                    ->select("c.short_description_fr", "c.short_description_ar", DB::raw("round(sum(oi.price * oi.quantity),2) as total"))
                    ->groupBy("c.short_description_fr", "c.short_description_ar")
                    ->get();
                $statLine = DB::table("order as o")
                    ->where("o.actor_id", "=", $actor->id)
                    ->where("o.state", "!=", "cancelled")
                    ->where("o.order_date", ">=", $monthStart)
                    ->select(DB::raw("DATE_FORMAT(order_date, '%Y-%m-%d') AS date"), DB::raw("ROUND(SUM(total_amount), 2) AS total"))
                    ->groupBy(DB::raw("DATE_FORMAT(order_date, '%Y-%m-%d')"))
                    ->orderBy(DB::raw("DATE_FORMAT(order_date, '%Y-%m-%d')"))
                    ->get();
                $clients = DB::table("client")
                    ->join("typepv", "client.typepv_id", "=", "typepv.id")
                    ->where("client.actor_id", "=", $actor->id)
                    ->select("typepv.name", "typepv.name_ar", DB::raw("count(typepv.name) as count"))
                    ->groupby("typepv.name", "typepv.name_ar")
                    ->get();
                $CA = DB::table("order")
                    ->where("actor_id", $actor->id)
                    ->where("state", "!=", "cancelled")
                    ->whereBetween("order_date", [$todayStart, $todayEnd])
                    ->select(DB::raw("round(coalesce(sum(total_amount),0),2) as total_amount"), DB::raw("count(id) as client_ordered_count"), DB::raw("coalesce(round(sum(total_amount)/count(id),2),0) as average_amount"))
                    ->first();

                $client_nb = DB::table("client")
                    ->join("visit_days", "visit_days.client_id", "client.id")
                    ->where("client.actor_id", $actor->id)
                    ->where("visit_days.day", DB::raw("dayname(now())"))
                    ->select(DB::raw("count(distinct client.id) as total_visit"))
                    ->first();

                $client_restant = DB::table("client")
                    ->join("visit_days", "visit_days.client_id", "client.id")
                    ->leftJoin("order", function ($join) use ($actor, $todayStart, $todayEnd) {
                        $join->on("order.client_id", "=", "client.id")
                            ->where("order.actor_id", $actor->id)
                            ->whereBetween("order.order_date", [$todayStart, $todayEnd]);
                    })
                    ->where("client.actor_id", $actor->id)
                    ->where("visit_days.day", DB::raw("dayname(now())"))
                    ->whereNull("order.id")
                    ->select(DB::raw("count(distinct client.id) as client_visit_missed"))
                    ->first();


                $orders = DB::table("order")
                    ->where("order.actor_id", "=", $actor->id)
                    ->where("order.order_date", ">=", $monthStart)
                    ->join("purchase_order", "purchase_order.order_id", "=", "order.id")
                    ->select(DB::raw("
                                        case
                                                when purchase_order.state ='new' then 1
                                                when purchase_order.state in ('taken','in_way') then 2
                                                when purchase_order.state in ('shipped') then 3
                                                when purchase_order.state in ('paid') then 4
                                                when purchase_order.state in  ('cancelled','expired') then 5
                                        end as num"), "purchase_order.state", DB::raw("count(purchase_order.state) as total"))
                    ->groupby("purchase_order.state")
                    ->orderby("num")
                    ->get();

                return response()->json(["status" => "SUCCESS", "data" => [
                    "line" => $statLine,
                    "categ" => $statPie,
                    "client_stats" => $clients,
                    "today_stats" => ["total_amount" => $CA->total_amount, "client_ordered_count" => $CA->client_ordered_count, "average_amount" => $CA->average_amount, "total_visit" => $client_nb->total_visit, "client_visit_missed" => $client_restant->client_visit_missed, "orders_status" => $orders],
                    "server_time" => date("Y-m-d H:i")
                ]]);
            } catch (\Exception $e) {
                return response()->json(["status" => "FAIL", "message" => $e->getMessage()]);
            }
        } else {
            return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
        }
    }


    public function DeliveryStats()
    {
        try {
            $user = Auth::user();
            if ($user) {
                $actor = Actor::where("user_id", $user->id)->first();
                $CA = DB::table("purchase_order")
                    ->where("actor_id", $actor->id)
                    ->where("planned_delivery_date", ">=", date("Y-m-d 00:00:00"))
                    ->where("planned_delivery_date", "<=", date("Y-m-d 23:59:59"))
                    ->select(
                        DB::raw("round(sum(case when state='paid' then total_amount else 0 end),2) as total_cash"), // total encaissement
                        DB::raw("round(sum(residual),2) as residual_amount"), // total restant en cash
                        DB::raw("count(id) as orders_total_delivery"),  // total orders à livrer
                        DB::raw("sum(case when state='in_way' then 1 else 0 end) as orders_restant_delivery") // orders restant à livrer
                    )
                    ->first();


                return response()->json(["status" => "SUCCESS", "data" => [
                    "today_stats" => [
                        "total_cash" => $CA->total_cash,
                        "residual_amount" => $CA->residual_amount,
                        "orders_total_delivery" => $CA->orders_total_delivery,
                        "orders_restant_delivery" => $CA->orders_restant_delivery
                    ],
                    "server_time" => date("Y-m-d H:i")
                ]]);
            } else {
                return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
            }
        } catch (\Exception $e) {
            return response()->json(["status" => "FAIL", "message" => $e->getMessage()]);
        }
    }

    public function ProfitStats(Request $request)
    {
        try {
            $user = Auth::user();
            if (!$user) {
                return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
            }

            $actor = TenantGuard::actor($user);
            if (!$actor || $actor->type != "admin" || !$actor->distributor_id) {
                return TenantGuard::forbiddenResponse();
            }

            $month = $request->input("month", date("Y-m"));
            if (!preg_match('/^\d{4}-\d{2}$/', $month)) {
                return response()->json(["status" => "FAIL", "message" => "Invalid month format. Use YYYY-MM"]);
            }

            $monthDate = \DateTime::createFromFormat("Y-m-d", $month . "-01");
            if (!$monthDate || $monthDate->format("Y-m") != $month) {
                return response()->json(["status" => "FAIL", "message" => "Invalid month format. Use YYYY-MM"]);
            }

            $monthStart = $monthDate->format("Y-m-01 00:00:00");
            $monthEnd = $monthDate->format("Y-m-t 23:59:59");

            $deliveredQuantity = "case when poi.confirmed_quantity is not null then poi.confirmed_quantity else greatest(poi.quantity - coalesce(poi.cancelled_quantity, 0), 0) end";
            $deliveredStockQuantity = "(" . $deliveredQuantity . ") * case when poi.unite = 'Cart' then poi.package else 1 end";
            $cashDeliveredQuantity = "case when poi2.confirmed_quantity is not null then poi2.confirmed_quantity else greatest(poi2.quantity - coalesce(poi2.cancelled_quantity, 0), 0) end";

            $rows = DB::table("purchase_order as po")
                ->join("purchase_orderitem as poi", "poi.purchaseorder_id", "=", "po.id")
                ->join("warehouse as w", "w.id", "=", "po.warehouse_id")
                ->leftJoin("stock_quantity as sq", function ($join) {
                    $join->on("sq.emplacement_id", "=", "po.warehouse_id")
                        ->on("sq.variant_id", "=", "poi.variant_id");
                })
                ->where("w.distributor_id", $actor->distributor_id)
                ->whereBetween("po.delivery_date", [$monthStart, $monthEnd])
                ->where("po.type", "invoice_out")
                ->whereIn("po.state", ["shipped", "paid", "partially_paid"])
                ->whereRaw($deliveredQuantity . " > 0")
                ->select(
                    DB::raw("DATE_FORMAT(po.delivery_date, '%Y-%m-%d') as date"),
                    DB::raw("round(sum((" . $deliveredQuantity . ") * poi.price), 2) as sales"),
                    DB::raw("round(sum((" . $deliveredStockQuantity . ") * coalesce(sq.stock_price, sq.lastpurchaseprice, 0)), 2) as purchases"),
                    DB::raw("round(sum(" . $deliveredQuantity . "), 2) as quantity")
                )
                ->groupBy(DB::raw("DATE_FORMAT(po.delivery_date, '%Y-%m-%d')"))
                ->orderBy("date")
                ->get();

            $cashTypeId = TransactionType::CASH();
            $cashRows = DB::table("purchase_order as po")
                ->join("warehouse as w", "w.id", "=", "po.warehouse_id")
                ->leftJoin("transactions as t", function ($join) use ($cashTypeId) {
                    $join->on("t.purchaseorder_id", "=", "po.id")
                        ->where("t.type_id", $cashTypeId);
                })
                ->where("w.distributor_id", $actor->distributor_id)
                ->whereBetween("po.delivery_date", [$monthStart, $monthEnd])
                ->where("po.type", "invoice_out")
                ->whereIn("po.state", ["shipped", "paid", "partially_paid"])
                ->whereExists(function ($query) use ($cashDeliveredQuantity) {
                    $query->select(DB::raw(1))
                        ->from("purchase_orderitem as poi2")
                        ->whereColumn("poi2.purchaseorder_id", "po.id")
                        ->whereRaw($cashDeliveredQuantity . " > 0");
                })
                ->select(
                    DB::raw("DATE_FORMAT(po.delivery_date, '%Y-%m-%d') as date"),
                    DB::raw("round(sum(coalesce(t.debit, 0)), 2) as cashed")
                )
                ->groupBy(DB::raw("DATE_FORMAT(po.delivery_date, '%Y-%m-%d')"))
                ->get();

            $data = [];
            $totalSales = 0;
            $totalPurchases = 0;
            $totalQuantity = 0;
            $totalCashed = 0;
            $days = (int) $monthDate->format("t");
            $rowsByDate = $rows->keyBy("date");
            $cashRowsByDate = $cashRows->keyBy("date");

            for ($day = 1; $day <= $days; $day++) {
                $date = $month . "-" . str_pad($day, 2, "0", STR_PAD_LEFT);
                $row = $rowsByDate->get($date);
                $cashRow = $cashRowsByDate->get($date);
                $sales = $row ? (float) $row->sales : 0;
                $purchases = $row ? (float) $row->purchases : 0;
                $quantity = $row ? (float) $row->quantity : 0;
                $cashed = $cashRow ? (float) $cashRow->cashed : 0;
                $profit = round($sales - $purchases, 2);

                $totalSales += $sales;
                $totalPurchases += $purchases;
                $totalQuantity += $quantity;
                $totalCashed += $cashed;
                $data[] = [
                    "date" => $date,
                    "day" => $day,
                    "sales" => round($sales, 2),
                    "purchases" => round($purchases, 2),
                    "quantity" => round($quantity, 2),
                    "cashed" => round($cashed, 2),
                    "profit" => $profit,
                ];
            }

            return response()->json(["status" => "SUCCESS", "data" => [
                "month" => $month,
                "basis" => "delivered_quantities",
                "summary" => [
                    "sales" => round($totalSales, 2),
                    "purchases" => round($totalPurchases, 2),
                    "quantity" => round($totalQuantity, 2),
                    "cashed" => round($totalCashed, 2),
                    "profit" => round($totalSales - $totalPurchases, 2),
                ],
                "daily" => $data,
            ]]);
        } catch (\Exception $e) {
            return response()->json(["status" => "FAIL", "message" => $e->getMessage()]);
        }
    }
}
