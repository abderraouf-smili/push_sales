<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Passport\HasApiTokens;

class TrackingOrders extends Model
{
    use HasApiTokens, HasFactory;

    protected $table = "tracking_orders";

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        "id",
        "actor_id",
        "order_id",
        "purchaseorder_id",
        "state",
        "amount",
        "image",
        "is_last",
        "updated_at",
        "created_at"
    ];

    public function actor()
    {
        return $this->belongsTo(Actor::class, "actor_id", "id");
    }

    public function delivery_proof()
    {
        return $this->belongsTo(DeliveryProof::class, "purchaseorder_id", "purchaseorder_id")->select(["purchaseorder_id", "image"]);
    }
}
