<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PurchaseOrderItem extends Model
{
    use HasFactory;

    protected $table = "purchase_orderitem";
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        "id",
        "purchaseorder_id",
        "image",
        "product_name",
        "variant_name_1",
        "variant_name_2",
        "promotion_id",
        "promotionitem_id",
        "coupon_id",
        "unite",
        "discount",
        "variant_id",
        "sku",
        "quantity",
        "confirmed_quantity",
        "cancelled_quantity",
        "package",
        "price"
    ];
}
