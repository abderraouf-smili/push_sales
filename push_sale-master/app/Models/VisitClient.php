<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Passport\HasApiTokens;

class VisitClient extends Model
{
    use HasApiTokens, HasFactory;

    protected $table = "visit_client";
    public $incrementing = false;
    protected $keyType = 'string';
    protected $fillable = [
        "id",
        "actor_id",
        "reason_id",
        "client_id",
    ];


    protected $hidden = ["created_at", "updated_at","actor_id","reason_id","client_id"];

    public function Reason(){
        return $this->belongsTo(ReasonNoDeliverySale::class,"reason_id");
    }
}
