<?php

namespace App\Http\Controllers;
use Illuminate\Support\Facades\Auth;
use App\Models\PreferencesDistributor;
use App\Models\Actor;

class ConfigurationController extends Controller{
    public function index(){
        try{
            $user = Auth::user();
            if ($user) {
                $actor = Actor::where("user_id",$user->id)->first();
				if($actor->distributor_id){
					$config = PreferencesDistributor::where(function ($query) use ($actor) {
																						$query->where('distributor_id', $actor->distributor_id)
																							->orWhereNull('distributor_id');
																					})->get();					
				}else{
					$config = PreferencesDistributor::whereNull('distributor_id')->get();
				}
                return response()->json(["status" => "SUCCESS", "data" => ["preferences" => $config]]);
            }else{
                return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
            }
        }catch(\Exception $e){
            return response()->json(["status" => "FAIL", "message" => $e->getMessage()]);
        }
    }
}