<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Passport\HasApiTokens;

class PriceList extends Model
{
    use HasApiTokens, HasFactory;
    protected $table = "pricelist";

    protected $fillable = ["id", "code", "name", "description", "typepv_id", "start_date", "end_date", "active", "distributor_id"];

    protected $hidden = ["typepv_id", "created_at", "updated_at"];

    public function scopeForDistributor($query, $distributorId)
    {
        return $query->where("distributor_id", $distributorId);
    }


    public function typepv()
    {
        return $this->hasOne(TypePV::class, "id", "typepv_id");
    }

    public function distributor()
    {
        return $this->hasOne(Distributor::class, "id", "distributor_id");
    }

    public function items()
    {
        return $this->hasMany(PriceListItem::class,"pricelist_id","id");
    }
}
