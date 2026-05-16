<?php

namespace App\Http\Controllers\Partner;


use Illuminate\Support\Facades\Auth;
use App\Http\Controllers\Controller;
use App\Models\Actor;
use App\Models\ActorProfile;
use App\Models\Address;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Exception;
use Illuminate\Support\Facades\Log;

class ActorProfileController extends Controller
{
    public function index(){
        $user = Auth::user();
        if($user){
            $states = ActorProfile::get();
            return response()->json(["status"=>"SUCCESS", "data" => $states]);
        }else{
            return response()->json(["status"=>"FAIL","message" => "User is not authentified"]);
        }
    }

    public function update(Request $request){
        $user = Auth::user();
        if($user){
            $validator = Validator::make($request->all(),[
                // "email" => "required|mail",
                "street" => "required",
                "state_id" => "required",
                "firstname" => "required",
                "lastname" => "required",
                "city_id" => "required",
                "profile_id" => "required",
                "image" => "required",
            ]);

            if($validator->fails()){
                return response()->json(["status"=>"FAIL","message" =>$validator->errors()]);
            }
            $data = $request->all();
            $data["country_id"] = 1;
            try{
                $address = Address::create($data);
                if($address){
                    $data["address_id"] = $address->id;
                    $actor = Actor::create($data);
                    return response()->json(["status"=>"SUCCESS","data" => $actor]);
                }
            }catch(Exception $e){
                return response()->json(["status"=>"FAIL","message" => $e->getMessage()]);
            }
            // return response()->json(["status"=>"SUCCESS", "data" => $states]);
        }else{
            return response()->json(["status"=>"FAIL","message" => "User is not authentified"]);
        }
    }
}
