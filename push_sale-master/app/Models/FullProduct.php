<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Passport\HasApiTokens;

class FullProduct extends Model
{
    use HasApiTokens, HasFactory;

    protected $table = "full_products";

    protected $fillable = [
        "distributopr_id",
        "warehouse_id",
        "category_id",
        "product_id",
        "variant_id",
        "promotion_id",
        "promotion_item_id",
        "pricelist_typepv_id",
        "promotion_typepv_id",
        "quantity",
        "sku",
        "price",
        "discount",
        "minimum"
    ];


    protected $hidden = [
        "distributopr_id",
        "warehouse_id",
        "category_id",
        "product_id",
        "variant_id",
        "promotion_id",
        "promotion_item_id",
        "pricelist_typepv_id",
        "promotion_typepv_id",
    ];



    public function distributor()
    {
        return $this->belongsTo(Distributor::class,"distributopr_id","id");
    }

    public function warehouse()
    {
        return $this->belongsTo(Warehouse::class,"warehouse_id","id");
    }

    public function variant()
    {
        return $this->belongsTo(Variant::class,"variant_id","id");
    }

    public function product()
    {
        return $this->belongsTo(Product::class,"product_id","id");
    }

    public function category()
    {
        return $this->belongsTo(Category::class,"category_id","id");
    }

    public function promotion()
    {
        return $this->belongsTo(PromotionItem::class);
    }

    public function promotion_typepv()
    {
        return $this->belongsTo(TypePV::class, "promotion_typepv_id", "id");
    }

    public function pricelist_typepv()
    {
        return $this->belongsTo(TypePV::class, "pricelist_typepv_id", "id");
    }
}
