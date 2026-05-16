<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Passport\HasApiTokens;

class PreferencesUser extends Model
{
    use HasApiTokens, HasFactory;
    protected $table = "preferences_user";
    protected $fillable = ["id","user_id","language"];
}
