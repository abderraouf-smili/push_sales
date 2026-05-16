<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\DB;
use Exception;

class StockOperation extends Model
{
    use HasFactory;
    protected $table = "stock_operation";

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        "id",
        "type",
        "operation_date",
        "force_package",
        "code",
        "state",
        "actor_id",
        "operation_id",
        "location_id",
        "warehouse_id",
        "distributor_id",
    ];

    protected $hidden = ["created_at", "updated_at"];

    public function items()
    {
        return $this->hasMany(StockOperationItems::class,"operation_id","id");
    }
    public function actor()
    {
        return $this->belongsTo(Actor::class,"actor_id","id");
    }
    public function distributor()
    {
        return $this->belongsTo(Distributor::class,"distributor_id","id");
    }
    public function location()
    {
        return $this->belongsTo(StockMobile::class,"location_id","id");
    }


}
