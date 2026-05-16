<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Passport\HasApiTokens;

class Promotion extends Model
{
    use HasApiTokens, HasFactory;
    protected $table = "promotion";

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = ["id", "description", "start_date", "end_date", "distributor_id", "typepv_id", "type_promotion_id"];

    protected $hidden = ["typepv_id", "distributor_id", "type_promotion_id", "created_at", "updated_at"];

    public function type()
    {
        return $this->hasOne(PromotionType::class, "id", "type_promotion_id");
    }

    public function distributor()
    {
        return $this->belongsTo(Distributor::class, "distributor_id");
    }

    public function typePV()
    {
        return $this->belongsTo(TypePV::class, "typepv_id", "id");
    }

    public function lines()
    {
        return $this->hasMany(PromotionItem::class, "promotion_id", "id");
    }
}
