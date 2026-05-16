<?php

namespace App\Http\Controllers\Settings;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\Warehouse;
use App\Models\Coupon;
use App\Models\Actor;
use App\Http\Controllers\Controller;
use App\Models\PriceListItem;
use App\Models\StockQuantity;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;

class CouponController extends Controller
{
    public function index()
    {
        try {
            $user = Auth::user();
            if ($user) {
                $actor = Actor::where("user_id", $user->id)->first();
                $coupons = Coupon::where("distributor_id", $actor->distributor_id)->get();
                return response()->json(["status" => "SUCCESS", "data" => $coupons]);
            } else {
                return response()->json(["status" => "error", "message" => "User is not authentified"]);
            }
        } catch (\Exception $e) {
            return response()->json(["status" => "FAIL", "message" => $e->getMessage()]);
        }
    }

    public function create(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                "id" => "required",
                "description" => "required",
                "code" => "required",
                "is_pourcentage" => "required",
                "discount" => "required",
                "count" => "required",
                "min_amount" => "required",
                "start_date" => "required",
                "end_date" => "required",
                "operation" => "required",
            ]);

            if ($validator->fails()) {
                return response()->json(["status" => "FAIL", "message" => $validator->errors()]);
            }
            $data = $request->all();
            DB::beginTransaction();
            $user = Auth::user();
            if ($user) {
                if ($data["operation"] == "create") {
                    $actor = Actor::where("user_id", $user->id)->first();
                    $data["distributor_id"] = $actor->distributor_id;
                    unset($data["operation"]);
                    Coupon::create($data);
                } else if ($data["operation"] == "update") {
                    unset($data["operation"]);
                    Coupon::where("id", $data["id"])->update($data);
                }
                DB::commit();
                return response()->json(["status" => "SUCCESS", "data" => "success"]);
            } else {
                return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
            }
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(["status" => "FAIL", "code" => "500", "message" => $e->getMessage()]);
        }
    }


    public function check(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                "coupon_code" => "required",
                "warehouses_amount" => "required",
            ]);

            if ($validator->fails()) {
                return response()->json(["status" => "FAIL", "message" => $validator->errors()]);
            }
            $data = $request->all();
            $user = Auth::user();
            if ($user) {
                $amount_distributor = [];
                $warehouse_ids = [];
                foreach ($data["warehouses_amount"] as $warehouse_id => $amount) {
                    $w = Warehouse::where("id", $warehouse_id)->first();
                    if (isset($amount_distributor[$w->distributor_id])) {
                        $amount_distributor[$w->distributor_id] += $amount;
                    } else {
                        $amount_distributor[$w->distributor_id] = $amount;
                        $warehouse_ids[$w->distributor_id][] = $warehouse_id;
                    }
                }
                $coupon = Coupon::where("code", $data["coupon_code"])
                    ->where("start_date", "<=", date("Y-m-d"))
                    ->where("end_date", ">=", date("Y-m-d"))
                    ->first();
                if ($coupon && isset($amount_distributor[$coupon->distributor_id])) {
                    if ($coupon->count > 0) {
                        if ($amount_distributor[$coupon->distributor_id] >= $coupon->min_amount) {
                            return response()->json(["status" => "SUCCESS", "data" => ["coupon" => $coupon, "warehouse_ids" => $warehouse_ids[$coupon->distributor_id]]]);
                        } else {
                            return response()->json(["status" => "FAIL", "code" => "amount_below", "message" => "order.amount.must.be.more.than@" . $coupon->min_amount]);
                        }
                    } else {
                        return response()->json(["status" => "FAIL", "code" => "300", "message" => "no.more.coupon.available"]);
                    }
                } else {
                    return response()->json(["status" => "FAIL", "code" => "404", "message" => "no.coupon.found"]);
                }
            } else {
                return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
            }
        } catch (\Exception $e) {
            return response()->json(["status" => "FAIL", "code" => "500", "message" => $e->getMessage()]);
        }
    }
}
