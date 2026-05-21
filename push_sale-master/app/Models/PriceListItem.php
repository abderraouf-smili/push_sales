<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Passport\HasApiTokens;

class PriceListItem extends Model
{
    use HasApiTokens, HasFactory;
    protected $table = "pricelist_item";

    protected $fillable = [
        "id",
        "sku",
        "price",
        "pricelist_id",
        "variant_id",
    ];

    protected $hidden = [/*"pricelist_id",  */ "variant_id", "created_at", "updated_at", "deleted_at"];

    public function scopeForDistributor($query, $distributorId)
    {
        return $query->whereHas("pricelist", function ($q) use ($distributorId) {
            $q->where("distributor_id", $distributorId);
        });
    }

    static public function adjuster($list, $distributorId = null){
        $allowedIds = null;
        if ($distributorId) {
            $ids = array_values(array_unique(array_filter(array_map(function ($item) {
                return isset($item["id"]) ? $item["id"] : null;
            }, $list))));

            $allowedIds = array_flip(
                PriceListItem::forDistributor($distributorId)
                    ->whereIn("id", $ids)
                    ->pluck("id")
                    ->all()
            );
        }

        foreach($list as $item){
            if ($allowedIds !== null && !isset($allowedIds[$item["id"]])) {
                continue;
            }
            PriceListItem::where("id",$item["id"])->update(["price"=>$item["price"]]);
        }
    }


    public function variant()
    {
        return $this->hasOne(Variant::class, "id", "variant_id");
    }

    public function pricelist()
    {
        return $this->belongsTo(PriceList::class, "pricelist_id");
    }
}
