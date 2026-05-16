<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Passport\HasApiTokens;

class FullPromotion extends Model
{
    use HasApiTokens, HasFactory;
    protected $table = "full_promotion";

    protected $fillable = [
        "id",
        "description",
        "start_date",
        "end_date",
        "promotion_item_id",
        "promotion_id",
        "distributor_id",
        "private",
        "warehouse_id",
        "address_id",
        "pricelist_typepv_id",
        "promotion_typepv_id",
        "type_promotion_id",
        "image",
        "category_id",
        "product_id",
        "variant_id",
        "discount",
        "minimum",
        "unite",

    ];

    protected $hidden = [
        "variant_id",
        "product_id",
        "category_id",
        "typepv_id",
        "warehouse_id",
        "address_id",
        "distributor_id",
        "type_promotion_id",
        "created_at",
        "updated_at"
    ];

    public function type()
    {
        return $this->hasOne(PromotionType::class, "id", "type_promotion_id");
    }

    public function distributor()
    {
        return $this->belongsTo(Distributor::class, "distributor_id");
    }

    public function warehouse()
    {
        return $this->belongsTo(Warehouse::class, "warehouse_id", "id");
    }

    public function typepv()
    {
        return $this->belongsTo(TypePV::class, "typepv_id", "id");
    }

    public function category()
    {
        return $this->belongsTo(Category::class, "category_id", "id");
    }

    public function product()
    {
        return $this->belongsTo(Product::class, "product_id", "id");
    }

    public function variant()
    {
        return $this->belongsTo(Variant::class, "variant_id", "id");
    }
}
