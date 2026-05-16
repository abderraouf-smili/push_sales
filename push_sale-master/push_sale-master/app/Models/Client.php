<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Passport\HasApiTokens;

class Client extends Model
{
    use HasApiTokens, HasFactory;
    protected $table = "client";

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = ["id","name", "code", "name", "mobile", "image", "typepv_id", "rate", "mail", "address_id", "actor_id"];

    protected $hidden = ["typepv_id", "address_id", "created_at", "updated_at"];

    public function Address()
    {
        return $this->belongsTo(Address::class);
    }

    public function transactions(){
        return $this->hasMany(Transactions::class);
    }

    public function TypePV()
    {
        return $this->hasOne(TypePV::class, "id", "typepv_id");
    }

    public function Actor()
    {
        return $this->belongsTo(Actor::class);
    }

    public function VisitDays(){
        return $this->hasMany(VisitDays::class);
    }

    public function Visits()
    {
        return $this->hasMany(VisitClient::class)->whereBetween('created_at', [date('Y-m-d 00:00:00'), date('Y-m-d 23:59:59')]);
    }
}
