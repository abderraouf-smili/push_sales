<?php

namespace App\Support;

use App\Models\Actor;

class WorkspaceResolver
{
    public const SUPERADMIN = 'superadmin';
    public const DISTRIBUTEUR = 'distributeur';
    public const COMMERCIAL = 'commercial';
    public const DEPOT = 'depot';
    public const LIVREUR = 'livreur';
    public const POINT_VENTE = 'point_vente';

    public static function type(?Actor $actor): string
    {
        if (!$actor) {
            return 'unknown';
        }

        $profileWorkspace = optional($actor->Profile)->workspace_type;
        if (is_string($profileWorkspace) && trim($profileWorkspace) !== '') {
            return trim($profileWorkspace);
        }

        $profileCode = strtolower((string) optional($actor->Profile)->code);
        $profileName = strtolower((string) optional($actor->Profile)->name);
        $actorType = strtolower((string) $actor->type);

        if (str_contains($profileCode, 'superadmin') || $actorType === 'superadmin') {
            return self::SUPERADMIN;
        }

        if (str_contains($profileCode, 'pointvente') || str_contains($profileCode, 'point-vente') || $actorType === 'point_vente') {
            return self::POINT_VENTE;
        }

        if (str_contains($profileCode, 'livreur') || str_contains($profileName, 'livreur')) {
            return self::LIVREUR;
        }

        if (str_contains($profileCode, 'depot') || str_contains($profileName, 'depot')) {
            return self::DEPOT;
        }

        if (str_contains($profileCode, 'commercial') || str_contains($profileName, 'commercial')) {
            return self::COMMERCIAL;
        }

        if ($actorType === 'admin' || str_contains($profileCode, 'manager') || str_contains($profileCode, 'distributeur')) {
            return self::DISTRIBUTEUR;
        }

        return self::COMMERCIAL;
    }

    public static function menus(string $workspaceType): array
    {
        return match ($workspaceType) {
            self::SUPERADMIN => [
                'dashboard',
                'distributors',
                'actors',
                'warehouses',
                'products',
                'reports',
                'audit_logs',
                'settings',
            ],
            self::DISTRIBUTEUR => [
                'dashboard',
                'actors',
                'warehouses',
                'products',
                'stock',
                'clients',
                'orders',
                'deliveries',
                'payments',
                'reports',
            ],
            self::LIVREUR => [
                'dashboard',
                'stock_mobile',
                'delivery',
                'routes',
                'profile',
            ],
            self::DEPOT => [
                'dashboard',
                'prepare_orders',
                'loadings',
                'warehouse_stock',
                'profile',
            ],
            self::POINT_VENTE => [
                'dashboard',
                'catalog',
                'cart',
                'my_orders',
                'credit',
                'support',
                'profile',
            ],
            default => [
                'dashboard',
                'clients',
                'tracking',
                'products',
                'profile',
            ],
        };
    }

    public static function actions(string $workspaceType): array
    {
        return match ($workspaceType) {
            self::SUPERADMIN => [
                'create_distributor',
                'create_actor',
                'create_warehouse',
                'create_product',
                'view_global_stats',
            ],
            self::DISTRIBUTEUR => [
                'create_actor',
                'create_warehouse',
                'create_product',
                'create_variant',
                'adjust_stock',
                'view_orders',
            ],
            self::LIVREUR => [
                'view_mobile_stock',
                'confirm_delivery',
                'collect_cash',
                'upload_delivery_proof',
                'manage_returns',
            ],
            self::DEPOT => [
                'prepare_order',
                'assign_driver',
                'confirm_loading',
                'view_warehouse_stock',
            ],
            self::POINT_VENTE => [
                'create_order_request',
                'create_order',
                'track_order',
                'view_credit',
                'view_promotions',
                'contact_support',
            ],
            default => [
                'create_client',
                'update_client',
                'create_order',
                'view_balance',
                'apply_coupon',
                'track_order',
            ],
        };
    }

    public static function legacyMenusFromPermissions(array $enabledPermissions): array
    {
        $map = [
            'HomePage.StatsPage' => 'dashboard',
            'HomePage.Clients' => 'clients',
            'HomePage.MainTrackingOrder' => 'tracking',
            'HomePage.ProductMainPage' => 'products',
            'HomePage.MainDeliveryPage' => 'delivery',
            'HomePage.MainTransferPage' => 'loadings',
            'HomePage.CompteSetting' => 'profile',
        ];

        return array_values(array_unique(array_filter(array_map(
            fn ($permission) => $map[$permission] ?? null,
            $enabledPermissions
        ))));
    }
}
