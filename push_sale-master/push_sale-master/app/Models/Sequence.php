<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Passport\HasApiTokens;

class Sequence extends Model
{
    use HasApiTokens,HasFactory;
    protected $table = "sequence";

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = ["id",'resource','res_id','prefix','current','position'];


    protected $hidden = ["created_at","updated_at"];


    public function Next($resource){
        //
        $this->where("res_id",$this->res_id)->where("resource",$resource)->update(["current"=>$this->current+1]);
    }
}
