<?php

namespace App\Http\Controllers\Warehouses;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\Warehouse;
use App\Models\Actor;
use App\Http\Controllers\Controller;
use App\Models\PriceListItem;
use App\Models\StockQuantity;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;

class WarehouseController extends Controller
{
    public function index(Request $request)
    {
        try {
            $user = Auth::user();
            if ($user) {
                $actor = Actor::where("user_id", $user->id)->first();
                $warehouses = Warehouse::with(["Address.City", "Address.State", "Address.Country", "variants.prices" => function ($query) use ($actor) {
                    $query->where("pricelist.distributor_id", $actor->distributor_id)
                        ->where("pricelist.active", true)
                        ->where(function ($query) {
                            $query->where(function ($query) {
                                $now = now()->format('Y-m-d H:i:s');
                                $query->where("start_date", "<=", $now)
                                    ->where("end_date", ">=", $now);
                            })->orWhere(function ($query) {
                                $query->wherenull("start_date")
                                    ->wherenull("end_date");
                            });
                        });
                }, "variants" => function ($query) {
                    $query->where("stock_warehouse.is_mobile", "0");
                }])
                    ->where("distributor_id", $actor->distributor_id)
                    ->get();
                return response()->json(["status" => "SUCCESS", "data" => $warehouses]);
            } else {
                return response()->json(["status" => "error", "message" => "User is not authentified"]);
            }
        } catch (\Exception $e) {
            return response()->json(["status" => "FAIL", "message" => $e->getMessage()]);
        }
    }

    public function adjustement(Request $request)
    {
        try {
            $data = $request->all();
            $user = Auth::user();
            if ($user) {
                DB::beginTransaction();
                // $data["stock"] est une map (variant_id,stock) pour mettre à jour le stock au dépot $data["warehouse_id"]
                $outOfStock = StockQuantity::checkForAdjust($data["warehouse_id"],$data["stock"]);
                PriceListItem::adjuster($data["prices"]);
                if(count($outOfStock)>0){
                    //stock has some out of stock
                    DB::commit();
                    return response()->json(["status"=>"FAIL","message"=>"out of stock","data"=>$outOfStock]);
                }else{
                    StockQuantity::adjuster($data["warehouse_id"],$data["stock"]);
                }
                DB::commit();
                return response()->json(["status"=>"SUCCESS","data"=>"SUCCESS"]);
            } else {
                return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
            }
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(["status" => "FAIL", "message" => $e->getMessage()]);
        }
    }
}
