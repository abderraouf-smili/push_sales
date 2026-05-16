<?php

namespace App\Http\Controllers;

use App\Models\MessageChat;
use App\Models\Actor;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Support\TenantGuard;

class MessageChatController extends Controller
{
    public function sendMessage(Request $request)
    {
        try {
            $user = Auth::user();
            if ($user) {
                $data = $request->all();
                $actor = TenantGuard::actor($user);
                $toActor = Actor::where("id", $data["to_actor_id"])->first();
                if (!$actor || !$toActor || $actor->distributor_id != $toActor->distributor_id) {
                    return TenantGuard::forbiddenResponse();
                }
                $message = MessageChat::create([
                    "id" => $data["message_chat_id"],
                    "from_actor_id" => $actor->id,
                    "to_actor_id" => $data["to_actor_id"],
                    "message" => $data["message"],
                    "sent" => false,
                    "read" => false,
                ]);
                return response()->json(["status" => "SUCCESS", "data" => $message]);
            } else {
                return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
            }
        } catch (\Exception $e) {
            return response()->json(["status" => "FAIL", "message" => $e->getMessage()]);
        }
    }

    public function getMessage()
    {
        return $this->getMessages();
    }

    public function getMessages(){
        try {
            $user = Auth::user();
            if ($user) {
                $actor = TenantGuard::actor($user);
                if (!$actor) {
                    return TenantGuard::forbiddenResponse();
                }
                $messages = MessageChat::where(function ($query) use ($actor) {
                    $query->where("from_actor_id", $actor->id)
                        ->orWhere("to_actor_id", $actor->id);
                })->with("from","to")->get();
                return response()->json(["status" => "SUCCESS", "data" => $messages]);
            } else {
                return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
            }
        } catch (\Exception $e) {
            return response()->json(["status" => "FAIL", "message" => $e->getMessage()]);
        }
    }
}
