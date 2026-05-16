<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\Auth;
use App\Models\Actor;
use App\Models\User;
use Illuminate\Support\Facades\Log;

// require_once 'vendor/autoload.php';

class NotificationController extends Controller
 {
    // public function ssend()
    // {
    //     try {
    //         $user = Auth::user();
    //         if ( $user ) {
    //             // $actor = Actor::where( 'user_id', $user->id )->first();
    //             $firebaseConfig = [
    //                 'apiKey' => 'AIzaSyBJMebqSmc0sxl7vgviZiG2gel3n9pIq_c',
    //                 'authDomain' => 'pushsale-2ed49.firebaseapp.com',
    //                 'projectId' => 'pushsale-2ed49',
    //                 'storageBucket' => 'pushsale-2ed49.appspot.com',
    //                 'messagingSenderId' => '908812739457',
    //                 'appId' => '1:908812739457:android:41aedb056bab5d79d77e80',
    //                 'type' => 'service_account',
    //                 'client_email'=> 'shini20fr@gmail.com',
    //                 // 'private_key'=> 'uV_bZqsqAkVjt_sO6bFwlz2Re3cCRkwjNM0ccj0E4cI',
    // ];

    //             $firebase = ( new Factory )->withServiceAccount( json_encode( $firebaseConfig ) );

    //             $messaging = $firebase->createMessaging();
    //             $notification = Notification::create( 'Titre de la notification', 'Contenu de la notification' );
    //             $message = CloudMessage::withTarget( 'token', $user->fcmtoken )
    //                 ->withNotification( $notification );
    //             $messaging->send( $message );
    //             return response()->json( [ 'status' => 'SUCCESS', 'data' => $message ] );
    //         } else {
    //             return response()->json( [ 'status' => 'FAIL', 'message' => 'User is not authentified' ] );
    //         }
    //     } catch ( \Exception $e ) {
    //         return response()->json( [ 'status' => 'FAIL', 'message' => $e->getMessage() ] );
    //     }
    // }

    public function send( Object $value )
 {
        try {
            $url = 'https://fcm.googleapis.com/fcm/send';
            $user = User::where( 'id', $value->user_id )->first();
            Log::info("fcmToek : " . $user->fcmtoken);
            Log::info("title : " . $user->title);
            Log::info("body  : " . $user->body);
            if ( $user ) {
                $data = [
                    'registration_ids' => [ $user->fcmtoken ],
                    'notification' => [
                        'title' => $value->title,
                        'body' => $value->body,
                    ]
                ];
                $encodedData = json_encode( $data );
                $headers = [
                    'Authorization:key=' . env( 'FCM_SERVER_KEY' ),
                    'Content-Type: application/json',
                ];
                $ch = curl_init();

                curl_setopt( $ch, CURLOPT_URL, $url );
                curl_setopt( $ch, CURLOPT_POST, true );
                curl_setopt( $ch, CURLOPT_HTTPHEADER, $headers );
                curl_setopt( $ch, CURLOPT_RETURNTRANSFER, true );
                curl_setopt( $ch, CURLOPT_SSL_VERIFYHOST, 0 );
                curl_setopt( $ch, CURLOPT_HTTP_VERSION, CURL_HTTP_VERSION_1_1 );
                // Disabling SSL Certificate support temporarly
                curl_setopt( $ch, CURLOPT_SSL_VERIFYPEER, false );
                curl_setopt( $ch, CURLOPT_POSTFIELDS, $encodedData );
                // Execute post
                $result = curl_exec( $ch );
                if ( $result === FALSE ) {
                    die( 'Curl failed: ' . curl_error( $ch ) );
                }
                // Close connection
                curl_close( $ch );
                // FCM response
                return response()->json( [ 'status' => 'SUCCESS', 'message' => $result ] );

            } else {

            }

        } catch ( \Exception $e ) {
            return response()->json( [ 'status' => 'FAIL', 'message' => $e->getMessage() ] );
        }
    }
}
