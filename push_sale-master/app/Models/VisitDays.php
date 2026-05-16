<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Passport\HasApiTokens;

class VisitDays extends Model
{
    use HasApiTokens, HasFactory;

    protected $table = "visit_days";

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        "id",
        "client_id",
        "day",
    ];

    protected $hidden = ["created_at", "updated_at",];

}
