<?php

namespace App\Http\Controllers;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;
use App\Models\Permissions;
use App\Models\Actor;
use App\Support\WorkspaceResolver;

class PermissionsController extends Controller{
    public function index(){
        try{
            $user = Auth::user();
            if ($user) {
                $actor = Actor::where("user_id",$user->id)->with("Profile", "Distributor")->first();
                if (!$actor) {
                    return response()->json(["status" => "FAIL", "message" => "Actor profile not found"]);
                }

                $permissions = Permissions::where("profile_id",$actor->profile_id)->get();
                $enabledPermissions = $permissions
                    ->filter(fn ($permission) => (bool) $permission->value)
                    ->pluck("permission")
                    ->values()
                    ->all();
                $workspaceType = WorkspaceResolver::type($actor);

                return response()->json([
                    "status" => "SUCCESS",
                    "data" => [
                        // Legacy contract used by the current Flutter app.
                        "permission" => $permissions,
                        "type_actor" => $actor->type,

                        // New workspace contract for the B2B platform.
                        "user" => [
                            "id" => $user->id,
                            "name" => $user->name,
                            "email" => $user->email,
                        ],
                        "actor" => [
                            "id" => $actor->id,
                            "type" => $actor->type,
                            "firstname" => $actor->firstname,
                            "lastname" => $actor->lastname,
                            "mail" => $actor->mail,
                            "distributor_id" => $actor->distributor_id,
                        ],
                        "profile" => $actor->Profile ? [
                            "id" => $actor->Profile->id,
                            "code" => $actor->Profile->code,
                            "name" => $actor->Profile->name,
                            "workspace_type" => $workspaceType,
                        ] : null,
                        "workspace_type" => $workspaceType,
                        "menus" => WorkspaceResolver::menus($workspaceType),
                        "legacy_menus" => WorkspaceResolver::legacyMenusFromPermissions($enabledPermissions),
                        "actions" => WorkspaceResolver::actions($workspaceType),
                        "permissions" => $enabledPermissions,
                    ],
                ]);
            }else{
                return response()->json(["status" => "FAIL", "message" => "User is not authentified"]);
            }
        }catch(\Exception $e){
            Log::error("Permissions loading failed", [
                "user_id" => optional(Auth::user())->id,
                "error" => $e->getMessage(),
            ]);

            return response()->json(["status" => "FAIL", "message" => "Unable to load permissions"]);
        }
    }
}
