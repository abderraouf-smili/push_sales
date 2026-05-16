<?php

namespace App\Http\Controllers\Product;


use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\Actor;
use App\Http\Controllers\Controller;
use App\Models\FullPromotion;
use App\Models\Promotion;
use App\Models\PromotionItem;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;
use  Exception;
use App\Support\TenantGuard;

class PromotionController extends Controller
{
    //
    public function index(Request $request)
    {
        $validator = Validator::make($request->all(), [
            "typepv_id" => "required",
        ]);

        if ($validator->fails()) {
            return response()->json(["status" => "FAIL", "message" => $validator->errors()]);
        }
        $user = Auth::user();
        if ($user) {
            try {
                $actor = Actor::where("user_id", $user->id)->first();
                if ($actor->distributor_id) {
                    //actor is attached to distr
                    $promotion = FullPromotion::where("distributor_id", $actor->distributor_id)
                        ->where(function ($sub_q) use ($request) {
                            $sub_q->where("typepv_id", $request->all()["typepv_id"])
                                ->orwherenull("typepv_id");
                        })
                        ->with("category.products.variants", "product.variants", "variant")
                        ->get();
                } else {
                    //actor is not attached to any dist
                    $promotion = FullPromotion::where("private", false)
                        ->where(function ($sub_q) use ($request) {
                            $sub_q->where("typepv_id", $request->all()["typepv_id"])
                                ->orwherenull("typepv_id");
                        })
                        ->with("category.products.variants", "product.variants", "variant")
                        ->get();
                }

                return response()->json(["status" => "SUCCESS", "data" => $promotion]);
            } catch (Exception $e) {
                return response()->json(["status" => "FAIL", "message" => $e->getMessage()]);
            }
        } else {
            return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
        }
    }
    public function promotion_for_user()
    {
        try {
            $user = Auth::user();
            if ($user) {
                $actor = Actor::where("user_id", $user->id)->first();
                if ($actor->distributor_id) {
                    $promotion = Promotion::where("distributor_id", $actor->distributor_id)
                        ->with("lines.category.products.variants", "lines.product.variants", "lines.variant.product", "type")
                        ->orderBy("end_date", "desc")
                        ->get();
                    return response()->json(["status" => "SUCCESS", "data" => $promotion]);
                } else {
                    return response()->json(["status" => "FAIL", "message" => "User is not allowed for this resources"]);
                }
            } else {
                return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
            }
        } catch (Exception $e) {
            return response()->json(["status" => "FAIL", "message" => $e->getMessage()]);
        }
    }

    public function update_or_create(Request $request)
    {
        $user = Auth::user();
        if ($user) {
            $validator = Validator::make($request->all(), [
                "id" => "required",
                "description" => "required",
                "start_date" => "required",
                "end_date" => "required",
                "lines" => "required",
            ]);
            if ($validator->fails()) {
                return response()->json(["status" => "FAIL", "message" => $validator->errors()]);
            }
            $data = $request->all();
            DB::beginTransaction();
            try {
                $actor = TenantGuard::actor($user);
                $data["distributor_id"] = $actor->distributor_id;
                $promotion = Promotion::where("id", $data["id"])->first();
                if ($promotion && $promotion->distributor_id != $actor->distributor_id) {
                    DB::rollBack();
                    return TenantGuard::forbiddenResponse();
                }
                if (!$promotion) {
                    $promotion = Promotion::create($data);
                }else{
                    $promotion->update($data);
                }
                PromotionItem::where("promotion_id", $promotion->id)->delete();
                foreach ($data["lines"] as $item) {
                    $item["promotion_id"] = $data["id"];
                    $promotion_lines = PromotionItem::create($item);
                }
                DB::commit();
                return response()->json(["status" => "SUCCESS", "data" => $promotion]);
            } catch (\Exception $e) {
                DB::rollback();
                return response()->json(["status" => "FAIL", "message" => $e->getMessage()]);
            }
        } else {
            return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
        }
    }
}
