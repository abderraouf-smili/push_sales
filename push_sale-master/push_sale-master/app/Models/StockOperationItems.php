<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\DB;
use Exception;

class StockOperationItems extends Model
{
    use HasFactory;
    protected $table = "stock_operation_items";

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        "id",
        "operation_id",
        "variant_id",
        "image",
        "product_name",
        "variant_1",
        "variant_2",
        "quantity",
        "package",
        "saleprice",
        "stockprice",
    ];

    protected $hidden = ["created_at", "updated_at"];
}
