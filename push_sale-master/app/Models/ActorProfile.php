<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Passport\HasApiTokens;

class ActorProfile extends Model
{
    use HasApiTokens,HasFactory;
    protected $table="actor_profile";

    protected $fillable = ["id","code","name","name_ar","workspace_type","has_stock_mobile","add_client"];

    protected $hidden = ["created_at","updated_at"];
}
