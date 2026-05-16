<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Passport\HasApiTokens;

class State extends Model
{
    use HasApiTokens,HasFactory;
    protected $table = "state";

    protected $fillable = [
        'id',
        'code',
        'name',
        'name_ar',
        "country_id"
    ];


    protected $hidden = ["country_id","created_at","updated_at"];

    /*
    public function Addresses(){
        return $this->hasMany(Address::class);
    }
    */

    public function cities()
    {
        return $this->hasMany(City::class);
    }

    public function country(){
        return $this->belongsTo(Country::class);
    }

}
