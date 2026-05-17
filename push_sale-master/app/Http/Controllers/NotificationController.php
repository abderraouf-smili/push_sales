<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\Auth;
use App\Models\Actor;
use App\Models\User;
use Illuminate\Support\Facades\Log;
use Illuminate\Http\Request;
use App\Support\TenantGuard;

// require_once 'vendor/autoload.php';

class NotificationController extends Controller
 {
    public function ssend(Request $request)
    {
        return $this->send($request);
    }

    public function send( $value )
 {
        try {
            $payload = $value instanceof Request ? (object) $value->all() : (object) $value;
            if (empty($payload->user_id) || empty($payload->title) || empty($payload->body)) {
                return response()->json([ 'status' => 'FAIL', 'message' => 'Missing notification payload' ]);
            }

            $serverKey = env('FCM_SERVER_KEY');
            if (empty($serverKey)) {
                return response()->json([ 'status' => 'FAIL', 'message' => 'FCM is not configured' ]);
            }

            $url = 'https://fcm.googleapis.com/fcm/send';
            $user = User::where( 'id', $payload->user_id )->first();
            if ( $user ) {
                if (empty($user->fcmtoken)) {
                    return response()->json([ 'status' => 'FAIL', 'message' => 'User has no FCM token' ]);
                }

                $currentActor = TenantGuard::actor(Auth::user());
                $targetActor = Actor::where("user_id", $user->id)->first();
                if ($currentActor && (!$targetActor || $currentActor->distributor_id != $targetActor->distributor_id)) {
                    return TenantGuard::forbiddenResponse();
                }
                Log::info("FCM notification requested", [
                    'user_id' => $user->id,
                    'title' => $payload->title,
                ]);
                $data = [
                    'registration_ids' => [ $user->fcmtoken ],
                    'notification' => [
                        'title' => $payload->title,
                        'body' => $payload->body,
                    ]
                ];
                $encodedData = json_encode( $data );
                $headers = [
                    'Authorization:key=' . $serverKey,
                    'Content-Type: application/json',
                ];
                $ch = curl_init();

                curl_setopt( $ch, CURLOPT_URL, $url );
                curl_setopt( $ch, CURLOPT_POST, true );
                curl_setopt( $ch, CURLOPT_HTTPHEADER, $headers );
                curl_setopt( $ch, CURLOPT_RETURNTRANSFER, true );
                curl_setopt( $ch, CURLOPT_SSL_VERIFYHOST, 2 );
                curl_setopt( $ch, CURLOPT_HTTP_VERSION, CURL_HTTP_VERSION_1_1 );
                curl_setopt( $ch, CURLOPT_SSL_VERIFYPEER, true );
                curl_setopt( $ch, CURLOPT_POSTFIELDS, $encodedData );
                $result = curl_exec( $ch );
                if ( $result === FALSE ) {
                    Log::warning('FCM request failed', ['error' => curl_error($ch)]);
                    curl_close( $ch );
                    return response()->json([ 'status' => 'FAIL', 'message' => 'FCM request failed' ]);
                }
                curl_close( $ch );
                return response()->json( [ 'status' => 'SUCCESS', 'message' => $result ] );

            } else {
                return response()->json( [ 'status' => 'FAIL', 'message' => 'User not found' ] );
            }

        } catch ( \Exception $e ) {
            return response()->json( [ 'status' => 'FAIL', 'message' => $e->getMessage() ] );
        }
    }
}
