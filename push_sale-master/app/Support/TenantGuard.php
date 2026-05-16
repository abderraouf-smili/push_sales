<?php

namespace App\Support;

use App\Models\Actor;
use App\Models\Client;
use App\Models\Order;
use App\Models\PriceListItem;
use App\Models\PurchaseOrder;
use App\Models\StockOperation;
use App\Models\Warehouse;
use Illuminate\Support\Facades\Auth;

class TenantGuard
{
    protected static $actorsByUserId = [];

    public static function actor($user = null)
    {
        $user = $user ?: Auth::user();

        if (!$user) {
            return null;
        }

        if ($user instanceof Actor) {
            return $user;
        }

        if (!array_key_exists($user->id, self::$actorsByUserId)) {
            self::$actorsByUserId[$user->id] = Actor::where("user_id", $user->id)->first();
        }

        return self::$actorsByUserId[$user->id];
    }

    public static function distributorId($user = null)
    {
        $actor = self::actor($user);

        return $actor ? $actor->distributor_id : null;
    }

    public static function warehouse($warehouseId, $user = null)
    {
        $actor = self::actor($user);

        if (!$actor || !$actor->distributor_id) {
            return null;
        }

        return Warehouse::forDistributor($actor->distributor_id)
            ->where("id", $warehouseId)
            ->first();
    }

    public static function warehouses($warehouseIds, $user = null)
    {
        $actor = self::actor($user);

        if (!$actor || !$actor->distributor_id) {
            return collect();
        }

        $warehouseIds = array_values(array_unique(array_filter($warehouseIds)));

        if (empty($warehouseIds)) {
            return collect();
        }

        return Warehouse::forDistributor($actor->distributor_id)
            ->whereIn("id", $warehouseIds)
            ->get()
            ->keyBy("id");
    }

    public static function purchaseOrders($purchaseOrderIds, $user = null)
    {
        $actor = self::actor($user);

        if (!$actor) {
            return collect();
        }

        $purchaseOrderIds = array_values(array_unique(array_filter($purchaseOrderIds)));

        if (empty($purchaseOrderIds)) {
            return collect();
        }

        return PurchaseOrder::visibleToActor($actor)
            ->whereIn("id", $purchaseOrderIds)
            ->get()
            ->keyBy("id");
    }

    public static function purchaseOrder($purchaseOrderId, $user = null)
    {
        $actor = self::actor($user);

        if (!$actor) {
            return null;
        }

        return PurchaseOrder::visibleToActor($actor)
            ->where("id", $purchaseOrderId)
            ->first();
    }

    public static function order($orderId, $user = null)
    {
        $actor = self::actor($user);

        if (!$actor) {
            return null;
        }

        return Order::visibleToActor($actor)
            ->where("id", $orderId)
            ->first();
    }

    public static function client($clientId, $user = null)
    {
        $actor = self::actor($user);

        if (!$actor) {
            return null;
        }

        $query = Client::where("id", $clientId);

        if ($actor->type == "admin" && $actor->distributor_id) {
            $query->forDistributor($actor->distributor_id);
        } else {
            $query->forActor($actor->id);
        }

        return $query->first();
    }

    public static function stockOperation($operationId, $user = null)
    {
        $actor = self::actor($user);

        if (!$actor) {
            return null;
        }

        return StockOperation::visibleToActor($actor)
            ->where("id", $operationId)
            ->first();
    }

    public static function priceListItem($itemId, $user = null)
    {
        $actor = self::actor($user);

        if (!$actor || !$actor->distributor_id) {
            return null;
        }

        return PriceListItem::forDistributor($actor->distributor_id)
            ->where("id", $itemId)
            ->first();
    }

    public static function forbiddenResponse($message = "Access to entry not allowed")
    {
        return response()->json([
            "status" => "FAIL",
            "code" => "403",
            "message" => $message,
        ], 403);
    }
}
