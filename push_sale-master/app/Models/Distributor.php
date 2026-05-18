<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Passport\HasApiTokens;

class Distributor extends Model
{
    use HasApiTokens, HasFactory;
    protected $table = "distributor";


    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        "id",
        "code",
        "private",
        "is_active",
        "name",
        "phone",
        "email",
        "contact_name",
        "address_id",
    ];

    protected $hidden = ["address_id", "created_at", "updated_at"];

    public function Warehouses()
    {
        return $this->hasMany(Warehouse::class);
    }

    public function Address()
    {
        return $this->belongsTo(Address::class);
    }
}
