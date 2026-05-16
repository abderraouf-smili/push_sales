<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Passport\HasApiTokens;

class PromotionItem extends Model
{
    use HasApiTokens, HasFactory;
    protected $table = "promotion_item";

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = ["id", "promotion_id", "category_id", "product_id", "variant_id", "discount", "unite", "minimum"];

    protected $hidden = ["promotion_id", "category_id", "product_id", "variant_id", "created_at", "updated_at"];

    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function product()
    {
        return $this->belongsTo(Product::class);
    }

    public function variant()
    {
        return $this->belongsTo(FullVariant::class);
    }

    public function promotion()
    {
        return $this->belongsTo(Promotion::class);
    }
}
