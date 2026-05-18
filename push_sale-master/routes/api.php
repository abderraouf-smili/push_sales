<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Partner\UserController;
use App\Http\Controllers\Partner\ActorController;
use App\Http\Controllers\Partner\ClientController;
use App\Http\Controllers\Partner\StateController;
use App\Http\Controllers\Partner\CityController;
use App\Http\Controllers\Partner\ActorProfileController;
use App\Http\Controllers\Partner\TypePVController;
use App\Http\Controllers\Partner\ReasonController;

use App\Http\Controllers\Product\ProductController;
use App\Http\Controllers\Product\VariantController;
use App\Http\Controllers\Product\CategoryController;
use App\Http\Controllers\Product\PriceListController;
use App\Http\Controllers\Product\PromotionController;

use App\Http\Controllers\Order\OrderController;

use App\Http\Controllers\StatisticsController;
use App\Http\Controllers\PermissionsController;
use App\Http\Controllers\ConfigurationController;
use App\Http\Controllers\NotificationController;

use App\Http\Controllers\Warehouses\WarehouseController;
use App\Http\Controllers\Warehouses\StockOperationController;
use App\Http\Controllers\Warehouses\StockMobileController;

use App\Http\Controllers\Purchase\PurchaseOrderController;

use App\Http\Controllers\Settings\CouponController;

use App\Http\Controllers\MessageChatController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

Route::post("register", [UserController::class, "register"]);
Route::post("login", [UserController::class, "login"]);
Route::post("userdetail", [UserController::class, "userDetail"]);


Route::middleware('auth:api')->group(function () {
    Route::get("configuration",[ConfigurationController::class,"index"]);

    //Acteurs
    Route::post("createactor", [ActorController::class, "create"]);
    Route::post("actorinfo", [ActorController::class, "index"]);
    Route::post("updateactor", [ActorController::class, "update"]);
    Route::post("isprofiled", [ActorController::class, "check"]);
    Route::post("actorprofile", [ActorProfileController::class, "index"]);
    Route::post("updateatorprofile", [ActorProfileController::class, "update"]);
    Route::post("actorslist", [ActorController::class, "getList"]);
    Route::post("actorslistinfo", [ActorController::class, "getAllActors"]);



    //Clients
    Route::post("clients", [ClientController::class, "index"]);
    Route::post("typepointsvente", [TypePVController::class, "index"]);
    Route::post("createclient", [ClientController::class, "create"]);
    Route::post("updateclient", [ClientController::class, "update"]);
    Route::post("globalreceivable", [ClientController::class, "global_receivable"]);
    Route::post("detailreceivable", [ClientController::class, "detail_receivable"]);
    Route::post("receivablebydate", [ClientController::class, "detail_receivable_by_date"]);
    Route::post("states", [StateController::class, "index"]);
    Route::post("cities", [CityController::class, "index"]);

    // Visit
    Route::post("reasonlist", [ReasonController::class, "index"]);
    Route::post("createvisit", [ReasonController::class, "create"]);

    // Categories
    Route::post("categories", [CategoryController::class, "index"]);
    Route::post("createcategory", [CategoryController::class, "create"]);
    Route::post("updatecategory", [CategoryController::class, "update"]);

    //Products
    Route::post("products", [ProductController::class, "index"]);
    Route::post("allproducts", [ProductController::class, "all"]);
    Route::post("createproduct", [ProductController::class, "create"]);
    Route::post("updateproduct", [ProductController::class, "update"]);

    //Variant
    Route::post("createvariant", [VariantController::class, "create"]);
    Route::post("updatevariant", [VariantController::class, "update"]);
    Route::post("variants",      [VariantController::class, "index"]);
    Route::post("purchasevariants", [VariantController::class, "index_purchase"]);

    //Pricelist
    Route::post("pricelists", [PriceListController::class, "index"]);
    Route::post("saveprices", [PriceListController::class, "save"]);

    //Promotion
    Route::post("promotions", [PromotionController::class, "index"]);
    Route::post("listpromotions", [PromotionController::class, "promotion_for_user"]);
    Route::post("setpromotion", [PromotionController::class, "update_or_create"]);



    // Orders
    Route::post("createorder",  [OrderController::class, "create"]);
    Route::post("currentorders",  [OrderController::class, "index"]);
    Route::post("statusorder",  [OrderController::class, "statusOrder"]);

    //warehouses
    Route::post("warehouses",  [WarehouseController::class, "index"]);
    Route::post("adjustement",  [WarehouseController::class, "adjustement"]);

    // Purchase Order
    Route::post("createpurchaseorder",  [PurchaseOrderController::class, "create"]);
    Route::post("topackorders",  [PurchaseOrderController::class, "getOrdersReadyToPack"]);
    Route::post("toshiporders",  [PurchaseOrderController::class, "getOrdersReadyToShip"]);
    Route::post("shiporder",  [PurchaseOrderController::class, "setOrderShipped"]);
    Route::post("cashorder",  [PurchaseOrderController::class, "setNewCashOrder"]);
    Route::post("sendcashforall",  [PurchaseOrderController::class, "saveCashOrders"]);
    Route::post("changeplanneddate",  [PurchaseOrderController::class, "changePlannedDate"]);
    Route::post("reneworder",  [PurchaseOrderController::class, "renewOrder"]);
    
    Route::post("purchaseorderslist", [PurchaseOrderController::class, "index"]);

    //Stock Operations
    Route::post("createtransfer",  [StockOperationController::class, "create"]);
    Route::post("listtransfer",  [StockOperationController::class, "index"]);
    Route::post("confirmtransfer",  [StockOperationController::class, "confirm"]);


    //Stock Mobile
    Route::post("currentstock",  [StockMobileController::class, "index"]);


    //stats
    Route::post("stats_month",  [StatisticsController::class, "stats"]);
    Route::post("deliverystats",  [StatisticsController::class, "DeliveryStats"]);
    Route::post("profitstats",  [StatisticsController::class, "ProfitStats"]);

    //Permissions
    Route::post("permissions",  [PermissionsController::class, "index"]);
    Route::post("permissions/workspace",  [PermissionsController::class, "index"]);

    //Send Push Notification
    Route::post("sendnotification", [NotificationController::class, "send"]);
    Route::post("sendnotification2", [NotificationController::class, "ssend"]);

    //Send/Receive Message Chat
    Route::post("sendmessage", [MessageChatController::class, "sendMessage"]);
    Route::post("getmessage", [MessageChatController::class, "getMessage"]);

    //Coupons
    Route::post("listcoupons", [CouponController::class, "index"]);
    Route::post("createcoupons", [CouponController::class, "create"]);
    Route::post("checkcoupon", [CouponController::class, "check"]);


    
});
