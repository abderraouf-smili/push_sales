<?php

namespace App\Http\Controllers\Product;


use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\Product;
use App\Models\Actor;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Validator;
use  Exception;
use App\Support\TenantGuard;

class ProductController extends Controller
{

    //
    public function index(Request $request)
    {
        $user = Auth::user();
        if ($user) {
            $actor = Actor::where("user_id", $user->id)->first();
            if (isset($request->all()["typepv_id"])) { //for sale
                $typepvid = $request->all()["typepv_id"];
                if ($actor->distributor_id) {
                    $products = Product::with(["variants" => function ($query) use ($typepvid, $actor) {
                        $query->where(function ($sub_q) use ($typepvid) {
                            $sub_q->where("full_variant.pricelits_typepv_id", $typepvid)
                                ->orwhere("full_variant.pricelits_typepv_id");
                        })
                            ->where(function ($sub_q) use ($typepvid) {
                                $sub_q->where("full_variant.promotion_typepv_id", $typepvid)
                                    ->orwherenull("full_variant.promotion_typepv_id");
                            })
                            ->where("full_variant.distributor_id", $actor->distributor_id);
                    }])
                        ->whereHas("variants", function ($query) use ($typepvid, $actor) {
                            $query->where(function ($sub_q) use ($typepvid) {
                                $sub_q->where("full_variant.pricelits_typepv_id", $typepvid)
                                    ->orwhere("full_variant.pricelits_typepv_id");
                            })
                                ->where(function ($sub_q) use ($typepvid) {
                                    $sub_q->where("full_variant.promotion_typepv_id", $typepvid)
                                        ->orwherenull("full_variant.promotion_typepv_id");
                                })
                                ->where("full_variant.distributor_id", $actor->distributor_id);
                        })
                        ->get();
                } else {
                    $products = Product::with(["variants" => function ($query) use ($typepvid) {
                        $query->where(function ($sub_q) use ($typepvid) {
                            $sub_q->where("full_variant.pricelits_typepv_id", "=", $typepvid)
                                ->orwherenull("full_variant.pricelits_typepv_id");
                        })
                            ->where(function ($sub_q) use ($typepvid) {
                                $sub_q->where("full_variant.promotion_typepv_id", $typepvid)
                                    ->orwherenull("full_variant.promotion_typepv_id");
                            })
                            ->where(function ($sub_q) {
                                $sub_q->where("full_variant.private", "0");
                            });
                    }])
                        ->whereHas("variants", function ($query) use ($typepvid) {
                            $query->where(function ($sub_q) use ($typepvid) {
                                $sub_q->where("full_variant.pricelits_typepv_id", "=", $typepvid)
                                    ->orwherenull("full_variant.pricelits_typepv_id");
                            })
                                ->where(function ($sub_q) use ($typepvid) {
                                    $sub_q->where("full_variant.promotion_typepv_id", $typepvid)
                                        ->orwherenull("full_variant.promotion_typepv_id");
                                })
                                ->where(function ($sub_q) {
                                    $sub_q->where("full_variant.private", "0");
                                });
                        })
                        ->get();
                }
                return response()->json(["status" => "SUCCESS", "data" => $products]);
            } else { //for purchase
                if ($actor->distributor_id) {
                    $products = Product::with(["purchasevariants" => function ($query) use ($actor) {
                        $query->where("purchase_variants.distributor_id", $actor->distributor_id);
                    }])
                        // ->has("purchasevariants")
                        ->get();
                    return response()->json(["status" => "SUCCESS", "data" => $products]);
                }
            }
        } else {
            return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
        }
    }

    public function create(Request $request)
    {
        $user = Auth::user();
        if ($user) {
            $actor = TenantGuard::actor($user);
            if (!$actor || $actor->type != "admin") {
                return TenantGuard::forbiddenResponse();
            }
            $validator = Validator::make($request->all(), [
                "ssin" => "required",
                "rate" => "required",
                "short_description_ar" => "required",
                "long_description_ar" => "required",
                "short_description_fr" => "required",
                "long_description_fr" => "required",
                "image" => "required",
                "category_id" => "required",
            ]);

            if ($validator->fails()) {
                return response()->json(["status" => "FAIL", "message" => $validator->errors()]);
            }

			
            $data = $request->all();
            // $data["category_id"] = $category->id;
            try {
				if($data["id"] == 0){
					$product = Product::create($data);					
				}else{
					unset($data["file"]);
					if($data["image"] == "no"){
						unset($data["image"]);						
					}
					Product::where("id", $data["id"])->update($data);
					$product = Product::where("id", $data["id"])->first();
				}
				if ($request->hasFile('file')) {
					$file = $request->file('file');
					$directory = "products/" . $product->id;
					$fileName = uniqid("pro_") . $product->id . "." . $file->getClientOriginalName();
					$storageDirectory = storage_path('app/public') . "/" . $directory;
					if(!file_exists($storageDirectory)){
						mkdir($storageDirectory, 0775, true);
					}
					$file->move($storageDirectory, $fileName);
					Product::where("id", $product->id)->update(["image" => "/storage/{$directory}/{$fileName}"]);
					$product = Product::where("id", $product->id)->first();
					// return response()->json(["status" => "SUCCESS", "data" => "hasFile"]);	
				}
                return response()->json(["status" => "SUCCESS", "data" => $product]);
            } catch (Exception $e) {
                return response()->json(["status" => "FAIL", "data" => $e->getMessage()]);
            }
        } else {
            return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
        }
    }

    public function update(Request $request)
    {
        $user = Auth::user();
        if ($user) {
            $actor = TenantGuard::actor($user);
            if (!$actor || $actor->type != "admin") {
                return TenantGuard::forbiddenResponse();
            }
            $validator = Validator::make($request->all(), [
                "id" => "required",
                "ssin" => "required",
                "rate" => "required",
                "short_description_ar" => "required",
                "long_description_ar" => "required",
                "short_description_fr" => "required",
                "long_description_fr" => "required",
                "image" => "required",
                "category_id" => "required",
            ]);

            if ($validator->fails()) {
                return response()->json(["status" => "FAIL", "message" => $validator->errors()]);
            }
            $data = $request->all();
            try {
                $product = Product::where("id", $data["id"])->update($data);
                $product = Product::where("id", $data["id"])->first();
                return response()->json(["status" => "SUCCESS", "data" => $product]);
            } catch (Exception $e) {
                return response()->json(["status" => "FAIL", "data" => $e->getMessage()]);
            }
        } else {
            return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
        }
    }
	
	public function all(){
		$user = Auth::user();
        if ($user) {
			$actor = Actor::where("user_id", $user->id)->first();
			if($actor->type == "admin"){
				$products = Product::with("allVariants")->get();
				return response()->json(["status" => "SUCCESS", "data" => $products]);
			}else{
				return response()->json(["status" => "FAIL", "message" => "User is not allowed"]);				
			}
		} else {
            return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
        }
	}
}
