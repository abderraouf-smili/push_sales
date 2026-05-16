<?php

namespace App\Http\Controllers\Warehouses;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\Order;
use App\Models\Sequence;
use App\Models\Actor;
use App\Http\Controllers\Controller;
use App\Models\StockMobile;
use App\Models\StockOperation;
use App\Models\StockWarehouse;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;

class StockMobileController extends Controller
{


    public function index()
    {
        try {
            $user = Auth::user();
            if ($user) {
                $actor=Actor::where("user_id",$user->id)->first();
                $stockmobile = StockMobile::where("actor_id",$actor->id)->first();
                if($stockmobile){
                    $current_stock = StockWarehouse::where("warehouse_id",$stockmobile->id)
                    ->get();
                    return response()->json(["status" => "SUCCESS", "data" => $current_stock]);
                }else{
                    return response()->json(["status" => "error", "message" => "No Stock Mobile found"]);
                }
            } else {
                return response()->json(["status" => "error", "message" => "User is not authentified"]);
            }
        } catch (\Exception $e) {
            return response()->json(["status" => "error", "message" => $e->getMessage()]);
        }
    }
}
