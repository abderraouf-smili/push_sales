<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class VariantOptionValue extends Model
{
    protected $fillable = [
        'option_id',
        'value',
        'normalized_value',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    public function option()
    {
        return $this->belongsTo(VariantOption::class, 'option_id');
    }
}
