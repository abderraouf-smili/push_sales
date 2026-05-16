<?php

namespace App\Http\Controllers\Partner;



use Illuminate\Support\Facades\Auth;
use App\Http\Controllers\Controller;
use App\Models\City;
use Illuminate\Support\Facades\DB;
use App\Models\Actor;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class CityController extends Controller
{
    public function index(Request $request)
    {

        $user = Auth::user();
        if ($user) {
            $validator = Validator::make($request->all(), [
                "state_id" => "required",
            ]);
            if ($validator->fails()) {
                $cities = DB::table("client")
                          ->select("city.id","city.name","city.name_ar")
                          ->join("address","client.address_id","=","address.id")
                          ->join("city","city.id","=","address.city_id")
                          ->where("actor_id",Actor::where("user_id",$user->id)->first()->id)
                          ->distinct()
                          ->get();
                // City::with()

                return response()->json(["status" => "SUCCESS", "data" => $cities]);
            }
            $data = $request->all();
            $cities = City::where("state_id", $data["state_id"])->get();
            return response()->json(["status" => "SUCCESS", "data" => $cities]);
        } else {
            return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
        }
    }
}
