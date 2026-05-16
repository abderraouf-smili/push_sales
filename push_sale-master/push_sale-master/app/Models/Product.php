<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Passport\HasApiTokens;

class Product extends Model
{
    use HasApiTokens, HasFactory;

    protected $table = "product";

    protected $fillable = ["ssin", "rate", "short_description_ar", "long_description_ar", "short_description_fr", "long_description_fr", "image", "category_id"];




    // protected $hidden = ["category_id",];

    public function allVariants(){
        return $this->hasMany(Variant::class);
    }

    public function variants()
    {
        return $this->hasMany(FullVariant::class);
    }

    public function purchasevariants()
    {
        return $this->hasMany(PurchaseVariant::class);
    }

    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function promotion()
    {
        return $this->belongsTo(PromotionItem::class);
    }
}
