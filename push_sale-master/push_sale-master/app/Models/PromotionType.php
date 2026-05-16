<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Passport\HasApiTokens;

class PromotionType extends Model
{
    use HasApiTokens, HasFactory;
    protected $table = "promotion_type";

    protected $fillable = ["id", "description", "type",];

    protected $hidden = ["created_at", "updated_at"];

}
