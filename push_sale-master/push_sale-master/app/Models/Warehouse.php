<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Passport\HasApiTokens;

class Warehouse extends Model
{
    use HasApiTokens, HasFactory;

    protected $table = "warehouse";

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        "id",
        "name",
        "code",
        "distributor_id",
        "address_id",

    ];



    protected $hidden = ["distributor_id", "address_id", "created_at", "updated_at",];

    public function distributor()
    {
        return $this->belongsTo(Distributor::class);
    }

    public function address()
    {
        return $this->belongsTo(Address::class);
    }


    public function variants(){
        return $this->hasMany(StockWarehouse::class);
    }
}
