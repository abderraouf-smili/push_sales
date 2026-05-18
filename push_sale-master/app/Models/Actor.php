<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Passport\HasApiTokens;

class Actor extends Model
{
    use HasApiTokens, HasFactory;
    protected $table = "actor";

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        "id",
        "type",
        "firstname",
        "user_id",
        "lastname",
        "mail",
        "profile_id",
        "rate",
        "phone",
        "image",
        "distributor_id",
        "address_id",
        "is_active"
    ];

    protected $hidden = ["user_id", "address_id", "profile_id", "created_at", "updated_at"];

    public function Address()
    {
        return $this->belongsTo(Address::class);
    }

    public function Profile()
    {
        return $this->hasOne(ActorProfile::class, "id", "profile_id");
    }

    public function Clients()
    {
        return $this->hasMany(Client::class, "actor_id", "id");
    }

    public function User()
    {
        return $this->hasOne(User::class, "id", "user_id");
    }

    public function StockMobile()
    {
        return $this->hasOne(StockMobile::class, "actor_id", "id");
    }
    public function Distributor()
    {
        return $this->belongsTo(Distributor::class);
    }

    public function realisation(){
        return $this->hasMany(Order::class);
    }
}
