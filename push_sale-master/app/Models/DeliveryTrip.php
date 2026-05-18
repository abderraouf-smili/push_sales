<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DeliveryTrip extends Model
{
    protected $fillable = [
        'actor_id',
        'distributor_id',
        'trip_date',
        'status',
        'route_summary',
        'total_distance',
        'estimated_duration',
    ];

    protected $casts = [
        'trip_date' => 'date',
        'route_summary' => 'array',
    ];

    public function stops()
    {
        return $this->hasMany(DeliveryTripStop::class)->orderBy('sequence');
    }
}
