<?php

namespace App\Http\Controllers\Product;


use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\PriceList;
use App\Models\PriceListItem;
use App\Models\Actor;
use App\Models\TypePV;
use App\Http\Controllers\Controller;
use Exception;
use Illuminate\Support\Facades\Validator;


class PriceListController extends Controller
{
    //
    public function index(){
        $user = Auth::user();
        if($user){
			$actor = Actor::where("user_id", $user->id)->first();
			if ($actor->distributor_id) {
				$pricelist = PriceList::with("typepv","items.variant.product")
										->where("distributor_id", $actor->distributor_id)->get();
				
				return response()->json(["status"=>"SUCCESS","data"=>$pricelist]);
			}else{
				return response()->json(["status"=>"FAIL","message"=>"Access to entry not allowed"]);
			}
        }else{
            return response()->json(["status"=>"FAIL","message"=>"User is not authentified"]);
        }
    }
	
    public function save(Request $request){
        $user = Auth::user();
        if($user){
            $validator = Validator::make($request->all(), [
                "items" => "required",]);

            if ($validator->fails()) {
                return response()->json(["status" => "FAIL", "message" => $validator->errors()]);
            }
			$r = null;
			try {
				$actor = Actor::where("user_id", $user->id)->first();
				if ($actor->distributor_id) {
					$items = $request->all()["items"];
					PriceListItem::adjuster($items);
					return response()->json(["status"=>"SUCCESS","data"=>"OK"]);
				}else{
					return response()->json(["status"=>"FAIL","message"=>"Access to entry not allowed"]);
				}
			}catch (Exception $e) {
                return response()->json(["status" => "ERROR", "message" => $e->getMessage()]);
            }
        }else{
            return response()->json(["status"=>"FAIL","message"=>"User is not authentified"]);
        }
    }	

}



