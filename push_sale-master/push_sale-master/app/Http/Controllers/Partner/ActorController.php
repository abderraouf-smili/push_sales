<?php

namespace App\Http\Controllers\Partner;

use App\Models\ActorProfile;
use App\Models\StockMobile;
use App\Models\Actor;
use App\Models\State;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Auth;
use Exception;
use App\Http\Controllers\Controller;
use App\Models\Address;
use App\Models\Sequence;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\DB;

class ActorController extends Controller
{


    public function check()
    {
		// return response()->json(["status" => "SUCCESS", "message" => "GET OK"]);
        try {
            $user = Auth::user();
            if ($user) {
                $actor = Actor::where("user_id", $user->id)->first();
                if ($actor) {
                    $response = array("hasactor" =>  1, "userinfo" => array("name" => $user->name, "device_id" => $user->device_id));
                } else {
                    $response = array("hasactor" =>  0, "userinfo" => array("name" => $user->name, "device_id" => $user->device_id));
                }
                return response()->json(["status" => "SUCCESS", "data" => $response]);
            } else {
                return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
            }
        } catch (\Exception $e) {
            return response()->json(["status" => "FAIL", "message" => $e->getMessage()]);
        }
    }

    public function index()
    {
        $user = Auth::user();
        if ($user) {
            $actor = Actor::where("user_id", $user->id)->with("Profile", "Distributor", "Address.City", "Address.State", "Address.Country")->first();
            return response()->json(["status" => "SUCCESS", "data" => $actor]);
        } else {
            return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
        }
    }

    public function create(Request $request)
    {
        try {

            $user = Auth::user();
            if ($user) {
                $validator = Validator::make($request->all(), [
                    "id" => "required",
                    "firstname" => "required",
                    "lastname" => "required",
                    // "mail" => "required",
                    "profile_id" => "required|numeric|min:0|not_in:0",
                    "city_id" => "required|numeric|min:0|not_in:0",
                    "state_id" => "required|numeric|min:0|not_in:0",
                    "country_id" => "required|numeric|min:0|not_in:0",
                ]);

                if ($validator->fails()) {
                    return response()->json(["status" => "FAIL", "message" => $validator->errors()]);
                }
                DB::beginTransaction();
                $data = $request->all();
                $actor_tocheck = Actor::where("id", $data["id"])->with("Profile")->first();
                if ($actor_tocheck) {
                    $address_check = Address::where("id", $actor_tocheck->address_id)->first();

                    // to  chnage to count when more sequences to be added
                    $sequence_check = Sequence::where("res_id", $actor_tocheck->id)->first();
                    if (!$address_check) {
                        $address_check = Address::create([
                            "id"          => "ACT-" . $data["id"],
                            "city_id"     => $data["city_id"],
                            "state_id"    => $data["state_id"],
                            "country_id"  => $data["country_id"],
                        ]);
                        Actor::where("id", $data["id"])->update(["address_id" => $address_check->id]);
                    }
                    if (!$sequence_check) {
                        if ($actor_tocheck->profile->has_stock_mobile) {
                            Sequence::create([
                                "id"        => "BT-" . $actor_tocheck->id,
                                "resource"  => "Chargement",
                                "prefix"    => "BT/" .  $user->id . "/",
                                "res_id"    => $actor_tocheck->id,
                                "current"   => "0",
                                "position"  => "6",
                            ]);
                        }
                        if ($actor_tocheck->profile->add_client) {
                            Sequence::create([
                                "id"        => "SC-" . $actor_tocheck->id,
                                "resource"  => "Client",
                                "prefix"    => "C" . State::where("id", $data["state_id"])->first()->code . $user->id . "_",
                                "res_id"    => $actor_tocheck->id,
                                "current"   => "0",
                                "position"  => "6",
                            ]);
                            Sequence::create([
                                "id"        => "SO-" . $actor_tocheck->id,
                                "resource"  => "Order",
                                "prefix"    => "Commande/" . $user->id . "/",
                                "res_id"    => $actor_tocheck->id,
                                "current"   => "0",
                                "position"  => "6",
                            ]);
                        }
                    }
                    DB::commit();
                    return response()->json(["status" => "SUCCESS", "data" => $actor_tocheck]);
                } else {
                    $data["user_id"] = $user->id;
                    $address_ckeck = Address::where("id", "ACT-" . $data["id"])->first();
                    if (!$address_ckeck) {
                        $address = Address::create([
                            "id"          => "ACT-" . $data["id"],
                            "city_id"     => $data["city_id"],
                            "state_id"    => $data["state_id"],
                            "country_id"  => $data["country_id"],
                        ]);
                    }
                    $data["address_id"] = "ACT-" . $data["id"];
                    $data["mail"] = $user->email;
                    // $actor = Actor::where("mail", $data["mail"])->first();
                    $data["image"] = "";
                    // if (!$actor) {

                    $actor = Actor::with("Profile")->create($data);
                    if ($actor->profile->has_stock_mobile) {
                        Sequence::create([
                            "id"        => "BT-" . $actor->id,
                            "resource"  => "Chargement",
                            "prefix"    => "BT/" .  $user->id . "/",
                            "res_id"    => $actor->id,
                            "current"   => "0",
                            "position"  => "6",
                        ]);
                    }
                    if ($actor->profile->add_client) {
                        Sequence::create([
                            "id"        => "SC-" . $actor->id,
                            "resource"  => "Client",
                            "prefix"    => "C" . State::where("id", $data["state_id"])->first()->code . $user->id . "_",
                            "res_id"    => $actor->id,
                            "current"   => "0",
                            "position"  => "6",
                        ]);
                        Sequence::create([
                            "id"        => "SO-" . $actor->id,
                            "resource"  => "Order",
                            "prefix"    => "Commande/" . $user->id . "/",
                            "res_id"    => $actor->id,
                            "current"   => "0",
                            "position"  => "6",
                        ]);
                    }
                    // }
                    $profile = ActorProfile::where("id", $data["profile_id"])->first();

                    $sm = StockMobile::where("actor_id", $actor->id)->first();

                    if ($profile->has_stock_mobile && !$sm) {
                        StockMobile::create([
                            "id"   => "SM-" . $actor->id,
                            "name" => "Stock Mobile : " . strtoupper($data["lastname"]) . " - " . strtoupper($data["firstname"]),
                            "code" => substr(strtoupper($data["lastname"]), 0, 1) . substr(strtoupper($data["firstname"]), 0, 1) . $actor->id,
                            "actor_id" => $actor->id,
                        ]);
                    }
                    DB::commit();
                    return response()->json(["status" => "SUCCESS", "data" => $actor]);
                }
            } else {
                return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
            }
        } catch (\Exception $e) {
            DB::rollback();
            return response()->json(["status" => "FAIL", "message" => $e->getMessage()]);
        }
    }

    public function update(Request $request)
    {
        $user = Auth::user();
        if ($user) {
            $validator = Validator::make($request->all(), [
                "firstname" => "required",
                "lastname" => "required",
                "phone" => "required",
            ]);

            if ($validator->fails()) {
                return response()->json(["status" => "FAIL", "message" => $validator->errors()]);
            }
            DB::beginTransaction();
            try {
                $data = $request->all();
                $actor = Actor::where("user_id", $user->id)->first();
                $actor_folder = storage_path('app/public') . "/actors";
                if ($actor->image != null) {
                    $old_image = $actor_folder  . "/" . str_replace("/storage/actors", "", $actor->image);
                } else {
                    $old_image = null;
                }
                if (isset($data["image"])) {
                    //Image to upload or nothing to do when "-1"
                    if ($data["image"] != "-1") {
                        $file_name = md5(date('Y-m-d H:i:s')) . ".jpg";
                        if ($old_image != null && file_exists($old_image)) {
                            unlink($old_image);
                        }
                        $image = base64_decode($data["image"]);
                        file_put_contents($actor_folder . "/" . $file_name, $image);
                        $data["image"] = "/storage/actors/" . $file_name;
                    } else {
                        if ($old_image != null && file_exists($old_image)) {
                            unlink($old_image);
                        }
                        $data["image"] = null;
                    }
                }


                if (isset($data["city_id"]) && isset($data["state_id"])) {
                    Address::where("id", $actor->address_id)->update(["city_id" => $data["city_id"], "state_id" => $data["state_id"]]);
                }
                if (isset($data["image"])) {
                    Actor::where("user_id", $user->id)->update([
                        "firstname" => $data["firstname"],
                        "lastname" => $data["lastname"],
                        "phone" => $data["phone"],
                        "image" => $data["image"] ?? null,
                    ]);
                } else {
                    Actor::where("user_id", $user->id)->update([
                        "firstname" => $data["firstname"],
                        "lastname" => $data["lastname"],
                        "phone" => $data["phone"],

                    ]);
                }
                $actor = Actor::where("user_id", $user->id)
                    ->with("Profile", "Distributor", "Address.City", "Address.State", "Address.Country")
                    ->first();
                DB::commit();
                return response()->json(["status" => "SUCCESS", "data" => $actor]);
            } catch (Exception $e) {
                DB::rollback();
                return response()->json(["status" => "FAIL", "message" => $e->getMessage()]);
            }
        } else {
            return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
        }
    }

    public function getList()
    {
        try {
            $user = Auth::user();
            if ($user) {
                $actor = Actor::where("user_id", $user->id)->where("type", "admin")->first();
                if ($actor) {
                    $actors = Actor::where("distributor_id", $actor->distributor_id)->with("Profile")->withCount(["realisation as orders_count" => function ($query) {
                        $query->where("order_date", ">=", date("Y-m-d"));
                    }, "realisation as orders_amount" => function ($query) {
                        $query->where("order_date", ">=", date("Y-m-d"))
                        ->select(DB::raw("coalesce(SUM(total_amount),0)"));
                    }])->get()->map(function($vendor) {
                        return [
                            'id' => $vendor->id,
                            'firstname' => $vendor->firstname,
                            'lastname' => $vendor->lastname,
                            'mail' => $vendor->mail,
                            'image' => $vendor->image,
                            'rate' => $vendor->rate,
                            'phone' => $vendor->phone,
                            'profile' => $vendor->profile,
                            'realisation' => [
                                'orders_count' => $vendor->orders_count,
                                'orders_amount' => $vendor->orders_amount,
                            ],
                        ];
                    });
                    return response()->json(["status" => "SUCCESS", "data" => $actors]);
                } else {
                    return response()->json(["status" => "SUCCESS", "data" => []]);
                }
            } else {
                return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
            }
        } catch (\Exception $e) {
            return response()->json(["status" => "FAIL", "message" => $e->getMessage()]);
        }
    }
	
	public function getAllActors()
	{
        try {
            $user = Auth::user();
            if ($user) {
                $actor = Actor::where("user_id", $user->id)->where("type", "admin")->first();
                if ($actor) {
                    $actors = Actor::where(function ($query) use ($actor) {
																		$query->where('distributor_id', $actor->distributor_id)
																			  ->orWhereNull('distributor_id');
																	}
											)->with(["Profile","Address","Distributor"])->get();
                    return response()->json(["status" => "SUCCESS", "data" => $actors]);
                } else {
                    return response()->json(["status" => "FAILD", "data" => "User is not allowed to access to this entry !"]);
                }
            } else {
                return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
            }
        } catch (\Exception $e) {
            return response()->json(["status" => "FAIL", "message" => $e->getMessage()]);
        }
	}
}
