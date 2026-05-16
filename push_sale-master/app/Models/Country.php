<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Passport\HasApiTokens;

class Country extends Model
{
    use HasApiTokens,HasFactory;

    protected $table = "country";

    protected $fillable = [
        'name',
        'code',
    ];

    protected $hidden = ["created_at","updated_at"];


    public function Visit()
    {
        return $this->hasMany(VisitClient::class)->whereBetween('created_at', [date('Y-m-d 00:00:00'), date('Y-m-d 23:59:59')]);
    }
}
