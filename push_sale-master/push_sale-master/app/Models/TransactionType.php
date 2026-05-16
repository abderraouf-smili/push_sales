<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Passport\HasApiTokens;

class TransactionType extends Model
{
    use HasApiTokens,HasFactory;

    protected $table = "transaction_type";

    protected $fillable = [
        "id",
        "name",
        "sens",
        "updated_at",
        "created_at"
    ];

    static public function SALE(){
        $ret = TransactionType::where("name","sale")->first();
        return $ret->id;
    }

    static public function CASH(){
        $ret = TransactionType::where("name","cash")->first();
        return $ret->id;
    }
}
