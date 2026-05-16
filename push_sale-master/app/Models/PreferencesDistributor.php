<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Passport\HasApiTokens;

class PreferencesDistributor extends Model
{
    use HasApiTokens, HasFactory;
	protected $table = "preferences_distributor";
    protected $fillable = [
        "id",
        "distributor_id",
        "property",
        "value",
    ];
	protected $hidden = ["created_at", "updated_at", "distributor_id"];

    public function distributor()
    {
        return $this->hasOne(Distributor::class, "id", "distributor_id");
    }
}
