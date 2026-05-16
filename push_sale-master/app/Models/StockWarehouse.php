<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\DB;
use Exception;

class StockWarehouse extends Model
{
    use HasFactory;
    protected $table = "stock_warehouse";
    protected $fillable = [
        "distributor_id",
        'warehouse_id',
        "variant_id",
        'image',
        'short_description_fr',
        'short_description_ar',
        'variant1_fr',
        'variant1_ar',
        'variant2_fr',
        'variant2_ar',
        'package',
        'quantity',
        'previsionnel',
        'stock_price',
        'is_mobile',
    ];

    protected $hidden = ["distributor_id", 'warehouse_id', "created_at", "updated_at"];


    public function warehouse()
    {
        return $this->hasOne(Warehouse::class, "id", "warehouse_id");
    }

    public function prices()
    {
        return $this->hasMany(PriceListItem::class, "variant_id", "variant_id")
            ->join("pricelist", "pricelist_item.pricelist_id", "pricelist.id")
            ->select("pricelist_item.pricelist_id", "pricelist_item.variant_id",DB::raw("pricelist_item.variant_id as var_id"),"pricelist_item.id","pricelist_item.price","pricelist.typepv_id");
    }
}
