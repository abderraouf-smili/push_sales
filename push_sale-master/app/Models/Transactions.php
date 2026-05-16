<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Passport\HasApiTokens;

class Transactions extends Model
{
    use HasApiTokens, HasFactory;

    protected $table = "transactions";

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        "id",
        "client_id",
        "actor_id",
        "order_id",
        "purchaseorder_id",
        "type_id",
        "credit",
        "debit",
        "account_date",
        "updated_at",
        "created_at"
    ];
}
