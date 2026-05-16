<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Passport\HasApiTokens;

class DeliveryProof extends Model
{
    use HasApiTokens, HasFactory;
    protected $table = "delivery_proof";
    public $incrementing = false;
    protected $keyType = 'string';
    protected $primaryKey = "purchaseorder_id";

    protected $fillable = ["purchaseorder_id", "image", "date"];
}
