<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Passport\HasApiTokens;

class TypePV extends Model
{
    use HasApiTokens,HasFactory;

    protected $table = "typepv";

    protected $fillable = ["id","name","name_ar"];

    protected $hidden = ["created_at","updated_at"];

}
