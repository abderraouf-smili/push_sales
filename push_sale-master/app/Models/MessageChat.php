<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Laravel\Passport\HasApiTokens;

class MessageChat extends Model
{
    use HasApiTokens, HasFactory;
    protected $table = "message_chat";

    protected $fillable = [
        "id",
        "from_actor_id",
        "to_actor_id",
        "message",
        "sent",
        "read",
    ];

    public function from()
    {
        return $this->belongsTo(Actor::class, "from_actor_id");
    }

    public function to()
    {
        return $this->belongsTo(Actor::class, "to_actor_id");
    }
}
