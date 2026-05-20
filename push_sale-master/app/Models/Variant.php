<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Passport\HasApiTokens;

class Variant extends Model
{
    use HasApiTokens, HasFactory;

    protected $table = "variant";

    protected $fillable = [
        "barcode",
        "image",
        "package",
        "option1_ar",
        "option1_fr",
        "variant1_ar",
        "variant1_fr",
        "option2_ar",
        "option2_fr",
        "variant2_ar",
        "variant2_fr",
        "product_id",
        "option_signature",
    ];



    protected $hidden = ["created_at", "updated_at",];

    public function product()
    {
        return $this->belongsTo(Product::class);
    }

    public function pricing()
    {
        return $this->hasMany(PriceListItem::class);
    }

    public function promotion()
    {
        return $this->hasMany(PromotionItem::class);
    }

    public function optionAssignments()
    {
        return $this->hasMany(VariantOptionAssignment::class, 'variant_id');
    }
}
