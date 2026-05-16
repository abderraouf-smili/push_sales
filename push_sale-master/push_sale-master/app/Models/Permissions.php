<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Passport\HasApiTokens;

class Permissions extends Model
{
    use HasApiTokens,HasFactory;
    protected $table="permissions";

    protected $fillable = ["id","profile_id","permission","value"];

    protected $hidden = ["created_at","updated_at"];
}
