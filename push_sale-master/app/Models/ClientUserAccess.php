<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ClientUserAccess extends Model
{
    protected $table = 'client_user_access';

    protected $fillable = [
        'user_id',
        'client_id',
        'distributor_id',
        'access_type',
        'is_primary',
        'is_active',
    ];

    protected $casts = [
        'is_primary' => 'boolean',
        'is_active' => 'boolean',
    ];
}
