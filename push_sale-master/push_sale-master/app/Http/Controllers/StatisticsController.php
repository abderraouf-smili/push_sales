<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\Order;
use App\Models\Sequence;
use App\Models\Actor;
use App\Models\OrderItem;
use Illuminate\Support\Facades\DB;

class StatisticsController extends Controller
{

    public function stats()
    {
        $user = Auth::user();
        if ($user) {
            try {
                $actor = Actor::where("user_id", $user->id)->first();
                $statPie = DB::table("stats_category_dayly")
                    ->where("actor_id", $actor->id)
                    ->where("order_date", ">=", date("Y-m-01"))
                    ->select("short_description_fr", "short_description_ar", DB::raw('round(sum(total),2) as total'))
                    ->groupBy("short_description_fr", "short_description_ar")
                    ->get();
                $statLine = DB::table("order")
                    ->where("actor_id", "=", $actor->id)
                    ->where("state", "!=", "cancelled")
                    ->where("order_date", ">=", date("Y-m-01"))
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
                    ->where("order_date", ">=", date("Y-m-d 00:00:00"))
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
                    ->where("client.actor_id", $actor->id)
                    ->where("visit_days.day", DB::raw("dayname(now())"))
                    ->whereNotIn("client.id", function ($query) use ($actor) {
                        $query->select("client_id")
                            ->from("order")
                            ->where("actor_id", $actor->id)
                            ->where("order_date", ">=", date("Y-m-d"));
                    })
                    ->select(DB::raw("count(distinct client.id) as client_visit_missed"))
                    ->first();


                $orders = DB::table("order")
                    ->where("order.actor_id", "=", $actor->id)
                    ->where("order.order_date", ">=", date("Y-m-01"))
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
}
