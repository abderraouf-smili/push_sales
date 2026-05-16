<?php

namespace App\Http\Controllers\Address;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Auth;
use App\Models\Address;
class AddressController extends Controller
{
    public function createAddress(Request $request){
        $user = Auth::user();
        if($user){
            $validator = Validator::make($request->all(),[
                "street" => "required",
                "zipcode" => "required",
                "latitude" => "required",
                "longitude" => "required",
                "city_id" => "required",
                "state_id" => "required",
                "country_id" => "required",
            ]);

            if($validator->fails()){
                return response()->json(["status"=>"FAIL","message" =>$validator->errors()]);
            }

            $data = $request->all();
            $address = Address::create($data);
            if($address){
                return response()->json(["status"=>"SUCCESS","message"=>"Address has been created succefully","data" => $address]);
            }
        }else{
            return response()->json(["status"=>"FAIL","message"=>"User is not authentified"]);
        }


    }
}
