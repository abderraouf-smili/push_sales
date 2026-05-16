<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Passport\HasApiTokens;

class StockMobile extends Model
{
    use HasApiTokens,HasFactory;
    protected $table = "stock_mobile";

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = ["id",'name','code','actor_id'];

    protected $hidden = ["created_at","updated_at"];

    public function items(){
        return $this->hasMany(StockQuantity::class,"emplacement_id","id");
    }
}
