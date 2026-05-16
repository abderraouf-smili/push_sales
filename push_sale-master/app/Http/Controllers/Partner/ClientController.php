<?php

namespace App\Http\Controllers\Partner;

use App\Models\Country;
use App\Models\City;
use App\Models\State;
use App\Models\Client;
use App\Models\Actor;
use App\Models\Sequence;
use App\Models\Transactions;
use App\Models\Address;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Http\Controllers\Controller;
use App\Models\PurchaseOrder;
use App\Models\VisitDays;
use Exception;
use Kreait\Firebase\Database\Transaction;
use Illuminate\Support\Facades\Log;
use App\Support\TenantGuard;

class ClientController extends Controller
{
    //
    public function index()
    {
        $user = Auth::user();
        if ($user) {
            $actor = Actor::where("user_id", $user->id)->first();
            $clients = Client::with("TypePV", "Address.City", "Address.State", "Address.Country", "VisitDays","Visits.Reason")
                ->where("actor_id", $actor->id)
                ->selectRaw("*,coalesce((select sum(debit) - sum(credit) from `transactions` where client_id=`client`.id),0) as solde,(select count(id) from `order` where client_id=`client`.id and date_format(order_date,'%Y-%m-%d')=date_format(now(),'%Y-%m-%d')) as sales")
                ->orderBy("name", "asc")
                ->get();
            return response()->json(["status" => "SUCCESS", "data" => $clients]);
        } else {
            return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
        }
    }

    public function create(Request $request)
    {
        $user = Auth::user();
        if ($user) {

            $validator = Validator::make($request->all(), [
                "id" => "required",
                "name" => "required",
                "typepv_id" => "required",
                "latitude" => "required",
                "longitude" => "required",
                "wilaya" => "required",
                "city" => "required",
                "country_code" => "required",
                "country_name" => "required",
            ]);

            if ($validator->fails()) {
                return response()->json(["status" => "FAIL", "message" => $validator->errors()]);
            }
            $data = $request->all();

            try {
                DB::beginTransaction();
                //Locate Actor
                $actor = TenantGuard::actor($user);
                $data["actor_id"] = $actor->id;

                $existingClient = Client::where("id", $data["id"])->first();
                if ($existingClient && !TenantGuard::client($data["id"], $user)) {
                    DB::rollBack();
                    return TenantGuard::forbiddenResponse();
                }

                //Locate Sequence
                $seq = Sequence::where("resource", "Client")->where("res_id", $actor->id)->first();
                if($seq){
                    $data["code"] = $seq->prefix . $this->completeChars(($seq->current + 1), $seq->position);
                }else{
                    Log::error("sequence for client for the user [" . Auth::user()->id . "] does not exist");
                }

                //build address object
                $country = Country::where("code", $data["country_code"])->first();
                if ($country) {
                    $data["country_id"] = $country->id;
                } else {
                    $country = Country::create([
                        "name" => $data["country_name"],
                        "code" => $data["country_code"]
                    ]);
                    $data["country_id"] = $country->id;
                }

                $state = State::where("name", $data["wilaya"]=="Algiers" || $data["wilaya"]=="Wilaya d'Alger" ? "Alger":$data["wilaya"])->first();
                if ($state) {
                    $data["state_id"] = $state->id;
                } else {
                    $state = State::create([
                        "code" => $data["wilaya"],
                        "name" => $data["wilaya"],
                        "name_ar" => $data["wilaya"],
                        "country_id" => $data["country_id"],
                    ]);
                    $data["state_id"] = $state->id;
                }

                $city = City::where("name", $data["city"])->first();
                if ($city) {
                    $data["city_id"] = $city->id;
                } else {
                    $city = City::create([
                        "name" => $data["city"],
                        "name_ar" => $data["city"],
                        "state_id" => $data["state_id"],
                    ]);
                    $data["city_id"] = $city->id;
                }
                $old_id = $data["id"];
                $data["id"] = "CLI-" . $data["id"];
                $address = Address::where("id", $data["id"])->first();
                if (!$address) {
                    $address = Address::create($data);
                }
                $data["id"] = $old_id;
                if ($address) {
                    $data["address_id"] = $address->id;
                    $actor_folder = storage_path('app/public') . "/clients" . "/" . $this->completeChars($user->id, 6);
                    if (isset($data["image"])) {
                        //Image to upload or nothing to do when "-1"
                        if ($data["image"] != "-1") {
                            if (!file_exists($actor_folder)) {
                                mkdir($actor_folder, 0775, true);
                            }
                            $file_name = md5(date('Y-m-d H:i:s')) . ".jpg";
                            $image = base64_decode($data["image"]);
                            file_put_contents($actor_folder . "/" . $file_name, $image);
                            $data["image"] = "/storage/clients/" . $this->completeChars($user->id, 6) . "/" . $file_name;
                        } else {
                            $data["image"] = null;
                        }
                    }
                    $client = $existingClient ?: Client::where("id", $data["id"])->first();
                    if (!$client) {
                        $client = Client::create($data);
                        Log::info("creation client [" . $client->id . "]");
                        if (isset($data["visit_days"])) {
                            VisitDays::where("client_id", $client->id)->delete();
                            foreach ($data["visit_days"] as $item) {
                                VisitDays::create(["client_id" => $client->id, "day" => $item["day"]]);
                            }
                        }
                    }
                    if ($client) {
                        $seq->Next("Client");
                        DB::commit();
                        return response()->json(["status" => "SUCCESS", "data" => $client]);
                    }
                }
            } catch (Exception $e) {
                DB::rollBack();
                return response()->json(["status" => "FAIL", "message" => $e->getMessage()]);
            }
        } else {
            return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
        }
    }


    public function update(Request $request)
    {

        $user = Auth::user();
        if ($user) {
            $validator = Validator::make($request->all(), [
                "id" => "required",
                "address_id" => "required",
                "name" => "required",
                "typepv_id" => "required",
                "latitude" => "required",
                "longitude" => "required",
                "wilaya" => "required",
                "city" => "required",
                "country_code" => "required",
                "country_name" => "required",
            ]);

            if ($validator->fails()) {
                return response()->json(["status" => "FAIL", "message" => $validator->errors()]);
            }
            try {
                DB::beginTransaction();
                $data = $request->all();
                $actor = Actor::where("user_id", $user->id)->first();


                $data["actor_id"] = $actor->id;
                $current_client = TenantGuard::client($data["id"], $user);
                if (!$current_client) {
                    DB::rollBack();
                    return TenantGuard::forbiddenResponse();
                }

                $data["code"] = $current_client->code;

                //build address object
                $country = Country::where("code", $data["country_code"])->first();
                if ($country) {
                    $data["country_id"] = $country->id;
                } else {
                    $country = Country::create([
                        "name" => $data["country_name"],
                        "code" => $data["country_code"]
                    ]);
                    $data["country_id"] = $country->id;
                }

                $state = State::where("name", $data["wilaya"]=="Algiers" || $data["wilaya"]=="Wilaya d'Alger" ? "Alger":$data["wilaya"])->first();
                if ($state) {
                    $data["state_id"] = $state->id;
                } else {
                    $state = State::create([
                        "code" => $data["wilaya"],
                        "name" => $data["wilaya"],
                        "name_ar" => $data["wilaya"],
                        "country_id" => $data["country_id"],
                    ]);
                    $data["state_id"] = $state->id;
                }

                $city = City::where("name", $data["city"])->first();
                if ($city) {
                    $data["city_id"] = $city->id;
                } else {
                    $city = City::create([
                        "name" => $data["city"],
                        "name_ar" => $data["city"],
                        "state_id" => $data["state_id"],
                    ]);
                    $data["city_id"] = $city->id;
                }

                if ($current_client->address_id != $data["address_id"]) {
                    DB::rollBack();
                    return TenantGuard::forbiddenResponse();
                }

                Address::where("id", $current_client->address_id)->update([
                    "street"      => isset($data["street"]) ? $data["street"] : null,
                    "commune"     => isset($data["commune"]) ? $data["commune"] : null,
                    "zipcode"     => isset($data["zipcode"]) ? $data["zipcode"] : null,
                    "latitude"    => $data["latitude"],
                    "longitude"   => $data["longitude"],
                    "city_id"     => $data["city_id"],
                    "state_id"    => $data["state_id"],
                    "country_id"  => $data["country_id"],
                ]);


                $actor_folder = storage_path('app/public') . "/clients" . "/" . $this->completeChars($user->id, 6);
                if (isset($data["image"])) {
                    //Image to upload or nothing to do when "-1"
                    if ($data["image"] != "-1") {
                        if (!file_exists($actor_folder)) {
                            mkdir($actor_folder, 0775, true);
                        }
                        $file_name = md5(date('Y-m-d H:i:s')) . ".jpg";
                        $image = base64_decode($data["image"]);
                        file_put_contents($actor_folder . "/" . $file_name, $image);
                        $data["image"] = "/storage/clients/" . $this->completeChars($user->id, 6) . "/" . $file_name;
                    } else {
                        $data["image"] = $current_client->image;
                    }
                } else {
                    if (file_exists($current_client->image)) {
                        unlink($current_client->image);
                    }
                    $data["image"] = null;
                }

                Client::where("id", $current_client->id)->update([
                    "name"          => $data["name"],
                    "mobile"        => isset($data["mobile"]) ? $data["mobile"] : null,
                    "typepv_id"     => $data["typepv_id"],
                    "image"         => $data["image"],
                ]);

                if (isset($data["visit_days"])) {
                    VisitDays::where("client_id", $current_client->id)->delete();
                    foreach ($data["visit_days"] as $item) {
                        VisitDays::create(["client_id" => $current_client->id, "day" => $item["day"]]);
                    }
                }

                $client = Client::where("id", $current_client->id)->first();
                if ($client) {
                    DB::commit();
                    return response()->json(["status" => "SUCCESS", "data" => $client]);
                }
            } catch (Exception $e) {
                DB::rollBack();
                return response()->json(["status" => "FAIL", "message" => $e->getMessage()]);
            }
        } else {
            return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
        }
    }

    public function global_receivable()
    {
        $user = Auth::user();
        if ($user) {
            $actor = Actor::where("user_id", $user->id)->first();

            $solde = DB::select("select
                                        c.id as client_id,
                                        c.image,
                                        c.name as client_name,
                                        concat(a.lastname,' ',a.firstname) as actor_name,
                                        s.code as state_code,
                                        ct.name as city_name,
                                        sum(t.debit) as total_paye,
                                        sum(t.credit) as total_vendu,
                                        sum(t.credit) - sum(t.debit) as solde
                                 from transactions t
                                 join client c on t.client_id = c.id
                                 join address ad on c.address_id = ad.id
                                 join state s on ad.state_id = s.id
                                 join city ct on ad.city_id = ct.id
                                 join actor a on c.actor_id=a.id
                                 join purchase_order po on t.purchaseorder_id = po.id
                                 join warehouse w on po.warehouse_id = w.id
                                 join distributor d on w.distributor_id = d.id
                                 where d.id= ?
                                 group by c.id,c.name,c.image,a.lastname,a.firstname,s.code,ct.name
                                 having round(sum(t.debit)-sum(t.credit),2) != 0
                                 order by solde desc", [$actor->distributor_id]);

            return response()->json(["status" => "SUCCESS", "data" => $solde]);
        } else {
            return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
        }
    }

    public function detail_receivable(Request $request)
    {
        $user = Auth::user();
        if ($user) {
            try {
                $validator = Validator::make($request->all(), [
                    "client_id" => "required",
                ]);
                if ($validator->fails()) {
                    return response()->json(["status" => "FAIL", "message" => $validator->errors()]);
                }
                $data = $request->all();
                $client = TenantGuard::client($data["client_id"], $user);
                if (!$client) {
                    return TenantGuard::forbiddenResponse();
                }
                $solde = DB::select("select
                                            t.purchaseorder_id,
                                            po.purchase_date,
                                            po.code,
                                            po.total_amount,
                                            sum(t.credit)-sum(t.debit) as solde
                                     FROM `transactions` t
                                     join purchase_order po on po.id = t.purchaseorder_id
                                     WHERE t.`client_id` = ?
                                     group by t.client_id,t.purchaseorder_id,po.purchase_date,po.code,po.total_amount
                                     having sum(t.credit)!=sum(t.debit)
                                     order by po.purchase_date desc", [$client->id]);
                return response()->json(["status" => "SUCCESS", "data" => $solde]);
            } catch (Exception $e) {
                return response()->json(["status" => "FAIL","code"=>"500", "message" => $e->getMessage()]);
            }
        } else {
            return response()->json(["status" => "FAIL","code"=>"400", "message" => "User is not authentified"]);
        }
    }


    public function detail_receivable_by_date(Request $request)
    {
        $user = Auth::user();
        if ($user) {
            $actor = Actor::where("user_id", $user->id)->first();
            try {
                $data = $request->all();
                $solde = DB::select("select
                                            t.purchaseorder_id,
                                            DATE_FORMAT(po.purchase_date, '%Y') as year,
                                            DATE_FORMAT(po.purchase_date, '%m-%Y') as month,
                                            DATE_FORMAT(po.purchase_date, '%d-%m-%Y') as date,
                                            c.name,
                                            c.image,
                                            po.code,
                                            po.total_amount,
                                            sum(t.credit)-sum(t.debit) as solde
                                     FROM `transactions` t
                                     join client c on c.id = t.client_id
                                     join purchase_order po on po.id = t.purchaseorder_id
                                     join warehouse w on po.warehouse_id = w.id
                                     WHERE w.distributor_id=?
                                     group by c.name,c.image,t.purchaseorder_id,DATE_FORMAT(po.purchase_date, '%d-%m-%Y'),DATE_FORMAT(po.purchase_date, '%Y'),DATE_FORMAT(po.purchase_date, '%m-%Y'),po.code,po.total_amount
                                     having sum(t.credit)!=sum(t.debit) and abs(sum(t.credit)-sum(t.debit))>0.5
                                     order by po.purchase_date desc", [$actor->distributor_id]);
                return response()->json(["status" => "SUCCESS", "data" => $solde]);
            } catch (Exception $e) {
                return response()->json(["status" => "FAIL","code"=>"500", "message" => $e->getMessage()]);
            }
        } else {
            return response()->json(["status" => "FAIL","code"=>"400", "message" => "User is not authentified"]);
        }
    }



    private function completeChars($number, $p)
    {
        $ret = "";
        for ($i = strlen($number); $i < $p; $i++) {
            $ret .= "0";
        }
        return $ret . $number;
    }
}
