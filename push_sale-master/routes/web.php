<?php

use App\Http\Controllers\ConsumerController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\ConfigController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

// Route::get('/', function () {
//     return view('welcome');
// });

// Route::get("consumers",[ConsumerController::class,"index"]);
// Route::get("articles",[ProductController::class,"index"]);

// Route::get('clearroute', [ConfigController::class, 'clear']);
// Route::get('cacheroute', [ConfigController::class, 'cache']);

Route::get('storage/{path}', function ($path) {
    $root = realpath(storage_path('app/public'));
    $file = realpath($root . DIRECTORY_SEPARATOR . str_replace(['/', '\\'], DIRECTORY_SEPARATOR, $path));

    if (!$root || !$file || strpos($file, $root) !== 0 || !is_file($file)) {
        abort(404);
    }

    return response()->file($file);
})->where('path', '.*');
