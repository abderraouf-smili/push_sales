<?php

namespace App\Http\Controllers;

use App\Models\MessageChat;
use App\Models\Actor;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class MessageChatController extends Controller
{
    public function sendMessage(Request $request)
    {
        try {
            $user = Auth::user();
            if ($user) {
                $data = $request->all();
                $actor = Actor::where("user_id", $user->id);
                $message = MessageChat::create([
                    "id" => $data["message_chat_id"],
                    "from_actor_id" => $actor->id,
                    "to_actor_id" => $data["to_actor_id"],
                    "message" => $data["message"],
                    "sent" => false,
                    "read" => false,
                ]);
                return response()->son(["status" => "SUCCESS", "data" => $message]);
            } else {
                return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
            }
        } catch (\Exception $e) {
            return response()->json(["status" => "FAIL", "message" => $e->getMessage()]);
        }
    }

    public function getMessages(){
        try {
            $user = Auth::user();
            if ($user) {
                $actor = Actor::where("user_id", $user->id);
                $messages = MessageChat::where("from_actor_id", $actor->id)->orWhere("to_actor_id", $actor->id)->with("from","to")->get();
                return response()->son(["status" => "SUCCESS", "data" => $messages]);
            } else {
                return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
            }
        } catch (\Exception $e) {
            return response()->json(["status" => "FAIL", "message" => $e->getMessage()]);
        }
    }
}
