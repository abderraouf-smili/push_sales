<?php

namespace App\Http\Controllers\Product;


use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\Category;
use App\Http\Controllers\Controller;
use App\Models\PriceList;
use Exception;
use Illuminate\Support\Facades\Validator;


class CategoryController extends Controller
{
    //
    public function index()
    {
        $user = Auth::user();
        if ($user) {
            $categories = Category::all();
            //$categories = PriceList::with([
            //    "items" => function ($query) {
            //        $query->select()->with([
            //            "variant" => function ($query) {
            //                 $query->select()->where("id", "=", "4") ;
            //            }
            //        ]);
            //    },

            //])->select("id", "description")->get();
            return response()->json(["status" => "SUCCESS", "data" => $categories]);
        } else {
            return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
        }
    }

    public function create(Request $request)
    {
        $user = Auth::user();
        if ($user) {
            $validator = Validator::make($request->all(), [
                "code" => "required",
                "image" => "required",
                "short_description_ar" => "required",
                "long_description_ar" => "required",
                "short_description_fr" => "required",
                "long_description_fr" => "required",
            ]);

            if ($validator->fails()) {
                return response()->json(["status" => "FAIL", "message" => $validator->errors()]);
            }
            try {
                $category = Category::create($request->all());
                return response()->json(["status" => "SUCCESS", "data" => $category]);
            } catch (Exception $e) {
                return response()->json(["status" => "FAIL", "Message" => $e->getMessage()]);
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
                "id"    => "required",
                "code"  => "required",
                "image" => "required",
                "short_description_ar" => "required",
                "long_description_ar" => "required",
                "short_description_fr" => "required",
                "long_description_fr" => "required",
            ]);

            if ($validator->fails()) {
                return response()->json(["status" => "FAIL", "message" => $validator->errors()]);
            }
            $data = $request->all();
            Category::where("id", $data["id"])->update([
                "code"                  => $data["code"],
                "image"                 => $data["image"],
                "short_description_ar"  => $data["short_description_ar"],
                "long_description_ar"   => $data["long_description_ar"],
                "short_description_fr"  => $data["short_description_fr"],
                "long_description_fr"   => $data["long_description_fr"],
            ]);
            $category = Category::where("id", $data["id"])->first();
            return response()->json(["status" => "SUCCESS", "data" => $category]);
        } else {
            return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
        }
    }
}
