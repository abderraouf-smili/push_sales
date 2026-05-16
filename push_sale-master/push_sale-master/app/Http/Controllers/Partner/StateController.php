<?php

namespace App\Http\Controllers\Partner;


use App\Models\State;
use Illuminate\Support\Facades\Auth;
use App\Http\Controllers\Controller;


class StateController extends Controller
{
    public function index(){
        $user = Auth::user();
        if($user){
            $states = State::get();
            return response()->json(["status"=>"SUCCESS", "data" => $states]);
        }else{
            return response()->json(["status"=>"FAIL","message" => "User is not authentified"]);
        }
    }
}
