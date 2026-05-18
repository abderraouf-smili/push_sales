<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DeliveryTripStop extends Model
{
    protected $fillable = [
        'delivery_trip_id',
        'purchase_order_id',
        'order_id',
        'client_id',
        'sequence',
        'status',
        'latitude',
        'longitude',
        'estimated_arrival',
        'actual_arrival',
    ];

    protected $casts = [
        'estimated_arrival' => 'datetime',
        'actual_arrival' => 'datetime',
    ];

    public function trip()
    {
        return $this->belongsTo(DeliveryTrip::class, 'delivery_trip_id');
    }
}
