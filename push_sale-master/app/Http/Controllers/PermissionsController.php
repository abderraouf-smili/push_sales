<?php

namespace App\Http\Controllers;
use Illuminate\Support\Facades\Auth;
use App\Models\Permissions;
use App\Models\Actor;

class PermissionsController extends Controller{
    public function index(){
        try{
            $user = Auth::user();
            if ($user) {
                $actor = Actor::where("user_id",$user->id)->first();
                $permissions = Permissions::where("profile_id",$actor->profile_id)->get();
                return response()->json(["status" => "SUCCESS", "data" => ["permission" => $permissions,"type_actor"=>$actor->type]]);
            }else{
                return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
            }
        }catch(\Exception $e){
            return response()->json(["status" => "FAIL", "message" => $e->getMessage()]);
        }
    }
}