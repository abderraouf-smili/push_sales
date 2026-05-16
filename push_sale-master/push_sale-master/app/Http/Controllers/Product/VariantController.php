<?php

namespace App\Http\Controllers\Product;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Auth;
use App\Models\Variant;
use App\Models\Actor;
use App\Models\FullVariant;
use Exception;

class VariantController extends Controller
{
    public function index()
    {
        $user = Auth::user();
        if ($user) {
            $actor = Actor::where("user_id", $user->id)->first();
            if ($actor->distributor_id) {
                $variants = FullVariant::with("product", "warehouse")->where("distributor_id", $actor->distributor_id)->get();
            } else {
                $variants = FullVariant::with("product", "warehouse")->get();
            }
            return response()->json(["status" => "SUCCESS", "data" => $variants]);
        } else {
            return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
        }
    }

    public function index_purchase()
    {
        $user = Auth::user();
        try {
            if ($user) {
                $actor = Actor::where("user_id", $user->id)->first();
                if ($actor->distributor_id) {
                    $variants = FullVariant::with("product")
                        ->where("distributor_id", $actor->distributor_id)
                        ->whereNull("promotion_id")
                        ->get();
                    return response()->json(["status" => "SUCCESS", "data" => $variants]);
                } else {
                    return response()->json(["status" => "FAIL", "message" => "User is not allowed for this resources"]);
                }
            } else {
                return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
            }
        } catch (Exception $e) {
            return response()->json(["status" => "FAIL", "message" => $e->getMessage()]);
        }
    }
    public function create(Request $request)
    {
        $user = Auth::user();
        if ($user) {
            $validator = Validator::make($request->all(), [
				"variants"			=> "required",
                // "product_id" 	=> "required",
                // "package" 		=> "required",
				// "option1_ar"	=> "required",
				// "option1_fr"	=> "required",
				// "variant1_ar"	=> "required",
				// "variant1_fr"	=> "required",
				// "option2_ar"	=> "required",
				// "option2_fr"	=> "required",
				// "variant2_ar"	=> "required",
				// "variant2_fr"	=> "required",
            ]);

            if ($validator->fails()) {
                return response()->json(["status" => "FAIL", "message" => $validator->errors()]);
            }
			try {
				$data = $request->all();
				$variants = [];
				
				foreach ($data["variants"] as $index => $element) {
					$element["barcode"] = $element["barcode"] ?? "";
					// Vérifier si un fichier existe pour ce variant dans $_FILES
					if (isset($_FILES['variants']['name'][$index]['imageUpload']) && $_FILES['variants']['error'][$index]['imageUpload'] === 0) 
					{
						$fileName = $_FILES['variants']['name'][$index]['imageUpload'];
						$tmpName  = $_FILES['variants']['tmp_name'][$index]['imageUpload'];
			
						// $info .= " | Image: $fileName | Taille: $fileSize octets";
			
						// Optionnel : déplacer le fichier si nécessaire
						$newFileName = uniqid('variant_') . "." . basename($fileName);
						$img = '/products/' . $element["product_id"] . '/' . $newFileName;
						move_uploaded_file($tmpName, storage_path('app/public') . $img);
						$element["image"] = "/storage" . $img;
						unset($element["imageUpload"]);
						if($element["id"] < 0){
							unset($element["id"]);
							$variants[] = Variant::create($element);
						}else{
							$variant = Variant::find($element["id"]);
							$variant->update($element);
							$variants[] = $variant;
						}
					} else {
						unset($element["imageUpload"]);
						if($element["id"] < 0){
							unset($element["id"]);
							$variants[] = Variant::create($element);
						}else{
							$variant = Variant::find($element["id"]);
							$variant->update($element);
							$variants[] = $variant;
						}
					}
				}

				return response()->json([
					"status" => "SUCCESS",
					"data" => $variants
				]);
            } catch (Exception $e) {
                return response()->json(["status" => "ERROR", "message" => $e->getMessage()]);
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
                "product_id" => "required",
                "sku" => "required",
                "barcode" => "required",
                "image" => "required",
                "package" => "required",
                "unite" => "required",
                "option1_ar" => "required",
                "variant1_ar" => "required",
                "option1_fr" => "required",
                "variant1_fr" => "required",
            ]);

            if ($validator->fails()) {
                return response()->json(["status" => "FAIL", "message" => $validator->errors()]);
            }
            $data = $request->all();
            try {
                Variant::where("id", $data["id"])->update($data);
                $variant = Variant::where("id", $data["id"])->first();
                return response()->json(["status" => "SUCCESS", "data" => $variant]);
            } catch (Exception $e) {
                return response()->json(["status" => "SUCCESS", "data" => $e->getMessage()]);
            }
        } else {
            return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
        }
    }
}
