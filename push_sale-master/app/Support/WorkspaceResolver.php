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
                'global_dashboard',
                'distributors',
                'actors',
                'global_catalog',
                'settings',
                'audit',
                'profile',
            ],
            self::DISTRIBUTEUR => [
                'dashboard',
                'products',
                'variants',
                'prices_promotions',
                'warehouses',
                'stock',
                'clients',
                'orders',
                'deliveries',
                'cash',
                'actors',
                'reports',
                'profile',
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
                'transfers',
                'profile',
            ],
            self::POINT_VENTE => [
                'home',
                'catalog',
                'cart',
                'my_orders',
                'deliveries',
                'credit',
                'promotions',
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
                'update_distributor',
                'suspend_distributor',
                'create_distributor_manager',
                'view_global_dashboard',
                'view_audit_logs',
                'manage_global_settings',
            ],
            self::DISTRIBUTEUR => [
                'manage_actors',
                'manage_warehouses',
                'manage_products',
                'manage_variants',
                'manage_prices',
                'manage_promotions',
                'manage_coupons',
                'manage_stock',
                'view_reports',
            ],
            self::LIVREUR => [
                'view_mobile_stock',
                'generate_reception_note',
                'confirm_delivery',
                'collect_cash',
                'upload_delivery_proof',
                'manage_returns',
                'open_routes',
            ],
            self::DEPOT => [
                'prepare_order',
                'assign_driver',
                'generate_loading_note',
                'confirm_loading',
                'adjust_warehouse_stock',
            ],
            self::POINT_VENTE => [
                'create_order_request',
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
