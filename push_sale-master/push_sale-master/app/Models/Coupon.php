<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Passport\HasApiTokens;
use Illuminate\Support\Facades\DB;

class Coupon extends Model
{
    use HasApiTokens, HasFactory;
    protected $table = "coupon";


    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        "id",
        "description",
        "code",
        "is_pourcentage",
        "discount",
        "count",
        "start_date",
        "end_date",
        "min_amount",
        "distributor_id",
    ];

    protected $hidden = ["created_at", "updated_at"];

    public function warehouses()
    {
        return $this->hasMany(Warehouse::class, 'distributor_id', 'distributor_id');
    }

    public function Substrate($id){
        Coupon::where('id', $id)->update([
            "count"=>DB::raw("case when count=0 then 0 else count-1 end")
        ]);
    }
}
