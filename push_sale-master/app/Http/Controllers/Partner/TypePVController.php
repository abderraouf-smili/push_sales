<?php

namespace App\Http\Controllers\Partner;


use Illuminate\Support\Facades\Auth;
use App\Http\Controllers\Controller;

use App\Models\TypePV;


class TypePVController extends Controller
{
    public function index(){
        $user = Auth::user();
        if($user){
            $states = TypePV::get();
            return response()->json(["status"=>"SUCCESS", "data" => $states]);
        }else{
            return response()->json(["status"=>"FAIL","message" => "User is not authentified"]);
        }
    }
}
