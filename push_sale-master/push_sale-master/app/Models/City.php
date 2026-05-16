<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Passport\HasApiTokens;

class City extends Model
{
    use HasApiTokens,HasFactory;
    protected $table = "city";
    protected $fillable = ["id","name","name_ar","state_id"];

    protected $hidden = ["state_id","created_at","updated_at"];

    public function addresses(){
        return $this->hasMany(Address::class);
    }

    public function state(){
        return $this->belongsTo(State::class);
    }
}
