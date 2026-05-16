<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Passport\HasApiTokens;


class Address extends Model
{
    use HasApiTokens, HasFactory;
    protected $table = "address";

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = ["id","street", "commune", "zipcode", "latitude", "longitude", "city_id", "state_id", "country_id"];

    protected $hidden = ["state_id", "city_id", "country_id", "created_at", "updated_at"];

    public function city()
    {
        return $this->belongsTo(City::class);
    }
    public function state()
    {
        return $this->belongsTo(State::class);
    }
    public function country()
    {
        return $this->belongsTo(Country::class);
    }
}
