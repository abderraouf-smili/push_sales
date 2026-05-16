<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Passport\HasApiTokens;

class Category extends Model
{
    use HasApiTokens,HasFactory;

    protected $table = "category";

    protected $fillable = ["code","image","short_description_ar","long_description_ar","short_description_fr","long_description_fr"];

    protected $hidden = ["created_at","updated_at"];
    
    public function products(){
        return $this->hasMany(Product::class);
    }

}