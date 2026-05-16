<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PurchaseOrder extends Model
{
    use HasFactory;
    protected $table = "purchase_order";
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        "id",
        "code",
        "order_id",
        "actor_id",
        "client_id",
        "type",
        "warehouse_id",
        "total_amount",
        "residual",
        "purchase_date",
        "operation_id",
        "planned_delivery_date",
        "delivery_date",
        "state",
    ];

    public function scopeForDistributor($query, $distributorId)
    {
        return $query->whereHas("warehouse", function ($q) use ($distributorId) {
            $q->where("distributor_id", $distributorId);
        });
    }

    public function scopeVisibleToActor($query, $actor)
    {
        return $query->where(function ($q) use ($actor) {
            $q->where("actor_id", $actor->id);

            if ($actor->distributor_id) {
                $q->orWhereHas("warehouse", function ($warehouse) use ($actor) {
                    $warehouse->where("distributor_id", $actor->distributor_id);
                });
            }
        });
    }

    public function orderitem()
    {
        return $this->hasMany(PurchaseOrderItem::class, "purchaseorder_id", "id");
    }

    public function warehouse()
    {
        return $this->belongsTo(Warehouse::class, "warehouse_id", "id");
    }

    public function client()
    {
        return $this->belongsTo(Client::class, "client_id", "id");
    }

    public function cash()
    {
        return $this->hasMany(Transactions::class, "purchaseorder_id", "id")->select(["purchaseorder_id", "debit"]);
    }

    public function transactions()
    {
        return $this->hasMany(Transactions::class, 'purchaseorder_id');
    }

    public function delivery_proof()
    {
        return $this->belongsTo(DeliveryProof::class, "id", "purchaseorder_id");
    }

    public function reNew(){
        
    }
}
