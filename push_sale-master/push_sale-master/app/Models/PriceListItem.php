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

    protected $hidden = [/*"pricelist_id",  */ "variant_id", "created_at", "updated_at"];


    static public function adjuster($list){
        foreach($list as $item){
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
