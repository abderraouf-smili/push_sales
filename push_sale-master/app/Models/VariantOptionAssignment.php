<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class VariantOptionAssignment extends Model
{
    protected $fillable = [
        'variant_id',
        'option_id',
        'option_value_id',
    ];

    public function option()
    {
        return $this->belongsTo(VariantOption::class, 'option_id');
    }

    public function value()
    {
        return $this->belongsTo(VariantOptionValue::class, 'option_value_id');
    }
}
