<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Passport\HasApiTokens;


class OrderItem extends Model
{
    use HasApiTokens, HasFactory;
    protected $table = "orderitem";

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        "id",
        "image",
        "product_name",
        "variant_name_1",
        "option_1",
        "variant_name_2",
        "option_2",
        "promotion_id",
        "promotionitem_id",
        "coupon_id",
        "unite",
        "order_id",
        "variant_id",
        "sku",
        "warehouse_id",
        "quantity",
        "confirmed_quantity",
        "cancelled_quantity",
        "package",
        "discount",
        "price",
    ];

    public function variant()
    {
        return $this->hasOne(Variant::class, "id", "variant_id");
    }

    public function Order()
    {
        return $this->belongsTo(Order::class);
    }
}
