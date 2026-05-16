<?php

namespace App\Http\Controllers\Partner;


use App\Models\ReasonNoDeliverySale;
use App\Models\Actor;
use App\Models\VisitClient;
use Illuminate\Support\Facades\Auth;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Http\Request;

class ReasonController extends Controller
{
    public function index()
    {
        try {
            $user = Auth::user();
            if ($user) {
                $reasons = ReasonNoDeliverySale::orderBy("assortissement", "asc")->get();
                return response()->json(["status" => "SUCCESS", "data" => $reasons]);
            } else {
                return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
            }
        } catch (\Exception $e) {
            return response()->json(["status" => "FAIL", "message" => $e->getMessage()]);
        }
    }

    public function create(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                "client_id" => "required",
                "reason_id" => "required",
            ]);
            if ($validator->fails()) {
                return response()->json(["status" => "FAIL", "message" => $validator->errors()]);
            }
            $data = $request->all();
            $user = Auth::user();
            if ($user) {
                $actor = Actor::where("user_id", $user->id)->first();
                $visit = VisitClient::create([
                    "id" => $data["visit_id"],
                    "actor_id" => $actor->id,
                    "reason_id" => $data["reason_id"],
                    'client_id' => $data["client_id"],
                ]);
                return response()->json(["status" => "SUCCESS", "data" => $visit]);
            } else {
                return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
            }
        } catch (\Exception $e) {
            return response()->json(["status" => "FAIL", "message" => $e->getMessage()]);
        }
    }
}
