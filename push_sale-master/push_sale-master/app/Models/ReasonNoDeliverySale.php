<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Passport\HasApiTokens;

class ReasonNoDeliverySale extends Model
{
    use HasApiTokens, HasFactory;

    protected $table = "reason_no_delivery_sale";
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        "id",
        "type_reason",
        'code',
        'revisit',
        'description_ar',
        'description_fr',
        'assortissement',
    ];


    protected $hidden = ["created_at", "updated_at",];
}
