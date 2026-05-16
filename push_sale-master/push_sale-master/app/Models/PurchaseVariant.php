<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Passport\HasApiTokens;

class PurchaseVariant extends Model
{
    use HasApiTokens, HasFactory;

    protected $table = "purchase_variants";

    protected $fillable = [
        "sku",
        "lastpurchaseprice",
        "quantity",
        "barcode",
        "image",
        "package",
        "option1_ar",
        "option1_fr",
        "variant1_ar",
        "variant1_fr",
        "option2_ar",
        "option2_fr",
        "variant2_ar",
        "variant2_fr",
        "product_id",
        "warehouse_id",
        "distributor_id",
    ];



    protected $hidden = ["created_at", "updated_at",];

    public function product()
    {
        return $this->belongsTo(Product::class);
    }


    public function warehouse()
    {
        return $this->belongsTo(Warehouse::class,"warehouse_id","id");
    }
}
