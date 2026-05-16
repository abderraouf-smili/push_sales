<?php


namespace App\Http\Controllers\Partner;

use App\Models\User;
use App\Models\Actor;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;
use Exception;

// function Dump($data)
// {
//     print "<pre>\n";
//     print_r($data);
//     print "<pre>";
// }

class UserController extends Controller
{

    public function register(Request $request){
        $validator = Validator::make($request->all(),[
            "name" => "required",
            "email" => "required|email",
            "fbuid" => "required",
            "fcmtoken" => "required",
            "device_id" => "required",
            "provider" => "required",
            "password" => "required|min:6",
        ]);
        if($validator->fails()){
            return response()->json(["status"=>"FAIL","message" =>$validator->errors()]);
        }
        if($request->provider == "gmail" || $request->provider == "facebook"){
            if(md5($request->fbuid) != $request->password){
                return response()->json(["status"=>"FAIL","message"=>"Sorry, you are not allowed to register !"]);
            }
        }
        $data = $request->all();
        $data["password"] = Hash::make($request->password);
        try{
            $user = User::create($data);
            if($user){
                return response()->json(["status"=>"SUCCESS","message"=>"User has been created succefully","data" => $user]);
            }
        }catch(Exception $e){
            return response()->json(["status"=>"FAIL","message"=>$e->getMessage()]);
        }
        return response()->json(["status"=>"FAIL","message"=>"Registration fails"]);
    }








    public function login(Request $request){
        $validator = Validator::make($request->all(),[
            "email" => "required|email",
            "password" => "required|min:6",
        ]);
        if($validator->fails()){
            return response()->json(["status"=>"FAIL","message"=>$validator->errors()]);
        }
        //Login
        if(Auth::attempt(["email" => $request->email,"password" => $request->password])){
            $user = Auth::user();
            $token = $user->createToken("usertoken")->accessToken;
            return response()->json(["status" => "SUCCESS","data" => $token]);
        }else{
            return response()->json(["status" => "FAIL","login" => false,"message" => "Password or Email invalid !"]);
        }
    }







    public function userDetail(Request $request){
        $validator = Validator::make($request->all(),[
            "fbuid" => "required",
        ]);

        if($validator->fails()){
            return response()->json(["status"=>"FAIL","message"=>$validator->errors()]);
        }

        $user = User::where("fbuid",$request->fbuid)->first();
        if($user){
            $actor = Actor::where("user_id",$user->id)->first();
            if($actor){
                return response()->json(["status"=>"SUCCESS","data"=>["provider" => $user->provider,"hasactor" => 1,"name" => $user->name, "type" => $actor->type]]);
            }else{
                return response()->json(["status"=>"SUCCESS","data"=>["provider" => $user->provider,"hasactor" => 0,"name" => $user->name, "type" => null]]);
            }
         }else{
             return response()->json(["status"=>"SUCCESS","data"=> null]);
        }
    }
}
