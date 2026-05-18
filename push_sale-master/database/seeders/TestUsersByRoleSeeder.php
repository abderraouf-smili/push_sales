<?php

namespace Database\Seeders;

use App\Models\Actor;
use App\Models\ActorProfile;
use App\Models\User;
use App\Support\WorkspaceResolver;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Schema;

class TestUsersByRoleSeeder extends Seeder
{
    private const PASSWORD = 'Test@123456';
    private const DISTRIBUTOR_ID = 'DIST-TEST';
    private const ADDRESS_ID = 'ADDR-TEST';

    public function run()
    {
        if (app()->environment('production')) {
            $this->command?->warn('TestUsersByRoleSeeder skipped in production.');
            return;
        }

        DB::transaction(function () {
            $now = now();

            DB::table('address')->updateOrInsert(
                ['id' => self::ADDRESS_ID],
                [
                    'street' => 'Adresse de test',
                    'commune' => 'Dev',
                    'zipcode' => '00000',
                    'latitude' => 36.7538,
                    'longitude' => 3.0588,
                    'city_id' => 1,
                    'state_id' => 1,
                    'country_id' => 1,
                    'created_at' => $now,
                    'updated_at' => $now,
                ]
            );

            DB::table('distributor')->updateOrInsert(
                ['id' => self::DISTRIBUTOR_ID],
                [
                    'name' => 'Distributeur Test',
                    'code' => 'DIST-TEST',
                    'private' => false,
                    'address_id' => self::ADDRESS_ID,
                    'created_at' => $now,
                    'updated_at' => $now,
                ]
            );

            $profiles = [
                'superadmin' => ActorProfile::updateOrCreate(
                    ['code' => 'superadmin-test'],
                    $this->profilePayload([
                        'name' => 'SuperAdmin Test',
                        'name_ar' => 'SuperAdmin Test',
                        'workspace_type' => WorkspaceResolver::SUPERADMIN,
                        'has_stock_mobile' => false,
                        'add_client' => false,
                    ])
                ),
                'manager' => ActorProfile::updateOrCreate(
                    ['code' => 'manager-distributeur-test'],
                    $this->profilePayload([
                        'name' => 'Manager Distributeur Test',
                        'name_ar' => 'Manager Distributeur Test',
                        'workspace_type' => WorkspaceResolver::DISTRIBUTEUR,
                        'has_stock_mobile' => false,
                        'add_client' => true,
                    ])
                ),
                'admin' => ActorProfile::updateOrCreate(
                    ['code' => 'admin-test'],
                    $this->profilePayload([
                        'name' => 'Admin Test',
                        'name_ar' => 'Admin Test',
                        'workspace_type' => WorkspaceResolver::DISTRIBUTEUR,
                        'has_stock_mobile' => false,
                        'add_client' => true,
                    ])
                ),
                'commercial' => ActorProfile::updateOrCreate(
                    ['code' => 'commercial-test'],
                    $this->profilePayload([
                        'name' => 'Commercial Test',
                        'name_ar' => 'Commercial Test',
                        'workspace_type' => WorkspaceResolver::COMMERCIAL,
                        'has_stock_mobile' => false,
                        'add_client' => true,
                    ])
                ),
                'livreur' => ActorProfile::updateOrCreate(
                    ['code' => 'livreur-test'],
                    $this->profilePayload([
                        'name' => 'Livreur Test',
                        'name_ar' => 'Livreur Test',
                        'workspace_type' => WorkspaceResolver::LIVREUR,
                        'has_stock_mobile' => true,
                        'add_client' => false,
                    ])
                ),
                'depot' => ActorProfile::updateOrCreate(
                    ['code' => 'depot-test'],
                    $this->profilePayload([
                        'name' => 'Depot Test',
                        'name_ar' => 'Depot Test',
                        'workspace_type' => WorkspaceResolver::DEPOT,
                        'has_stock_mobile' => true,
                        'add_client' => false,
                    ])
                ),
                'pointvente' => ActorProfile::updateOrCreate(
                    ['code' => 'pointvente-test'],
                    $this->profilePayload([
                        'name' => 'Point de Vente Test',
                        'name_ar' => 'Point de Vente Test',
                        'workspace_type' => WorkspaceResolver::POINT_VENTE,
                        'has_stock_mobile' => false,
                        'add_client' => false,
                    ])
                ),
            ];

            $permissionSets = [
                'superadmin' => [
                    'HomePage.StatsPage',
                    'HomePage.ProductMainPage',
                    'HomePage.CompteSetting',
                    'SuperAdmin.dashboard',
                    'SuperAdmin.distributors',
                    'SuperAdmin.actors',
                    'SuperAdmin.audit',
                    'SuperAdmin.settings',
                ],
                'manager' => [
                    'HomePage.StatsPage',
                    'HomePage.Clients',
                    'HomePage.MainTrackingOrder',
                    'HomePage.MainTransferPage',
                    'HomePage.ProductMainPage',
                    'HomePage.CompteSetting',
                    'Clients.add',
                    'Distributor.dashboard',
                    'Distributor.actors',
                    'Distributor.warehouses',
                    'Distributor.products',
                    'Distributor.stock',
                    'Distributor.orders',
                    'Distributor.reports',
                ],
                'admin' => [
                    'HomePage.StatsPage',
                    'HomePage.Clients',
                    'HomePage.MainTrackingOrder',
                    'HomePage.ProductMainPage',
                    'HomePage.CompteSetting',
                    'Clients.add',
                    'StatsPage.TournoverDashboard',
                    'StatePage.OrdersStatus',
                    'StatsPage.DeliveryOrdersDashboard',
                    'StatsPage.lineChart',
                    'StatsPage.pieChart',
                    'StatsPage.barChart',
                    'StatsPage.PromotionSlide',
                ],
                'commercial' => [
                    'HomePage.StatsPage',
                    'HomePage.Clients',
                    'HomePage.MainTrackingOrder',
                    'HomePage.ProductMainPage',
                    'HomePage.CompteSetting',
                    'Clients.add',
                    'StatsPage.TournoverDashboard',
                    'StatePage.OrdersStatus',
                    'StatsPage.lineChart',
                    'StatsPage.pieChart',
                    'StatsPage.barChart',
                    'StatsPage.PromotionSlide',
                ],
                'livreur' => [
                    'HomePage.StatsPage',
                    'HomePage.MainDeliveryPage',
                    'HomePage.ProductMainPage',
                    'HomePage.CompteSetting',
                    'StatsPage.DeliveryOrdersDashboard',
                ],
                'depot' => [
                    'HomePage.StatsPage',
                    'HomePage.MainTransferPage',
                    'HomePage.ProductMainPage',
                    'HomePage.CompteSetting',
                    'StatsPage.DeliveryOrdersDashboard',
                ],
                'pointvente' => [
                    'HomePage.StatsPage',
                    'HomePage.MainTrackingOrder',
                    'HomePage.ProductMainPage',
                    'HomePage.CompteSetting',
                    'PointVente.home',
                    'PointVente.catalog',
                    'PointVente.cart',
                    'PointVente.my_orders',
                    'PointVente.credit',
                    'PointVente.support',
                ],
            ];

            foreach ($permissionSets as $role => $permissions) {
                $this->syncPermissions($profiles[$role]->id, $permissions, $now);
            }

            $this->upsertUserActor(
                'superadmin',
                'superadmin@pushsales.local',
                'SuperAdmin',
                'PushSales',
                'superadmin',
                $profiles['superadmin']->id,
                null
            );
            $this->upsertUserActor(
                'manager',
                'manager.distributeur@pushsales.local',
                'Manager',
                'Distributeur',
                'admin',
                $profiles['manager']->id
            );
            $this->upsertUserActor(
                'admin',
                'admin.test@pushsales.local',
                'Admin',
                'Test',
                'admin',
                $profiles['admin']->id
            );
            $this->upsertUserActor(
                'commercial',
                'commercial.test@pushsales.local',
                'Commercial',
                'Test',
                'user',
                $profiles['commercial']->id
            );
            $this->upsertUserActor(
                'livreur',
                'livreur.test@pushsales.local',
                'Livreur',
                'Test',
                'user',
                $profiles['livreur']->id
            );
            $this->upsertUserActor(
                'depot',
                'depot.test@pushsales.local',
                'Depot',
                'Test',
                'user',
                $profiles['depot']->id
            );
            $this->upsertUserActor(
                'pointvente',
                'pointvente.test@pushsales.local',
                'Point',
                'Vente',
                'point_vente',
                $profiles['pointvente']->id
            );
        });
    }

    private function syncPermissions(int $profileId, array $enabledPermissions, $now): void
    {
        $allPermissions = collect([
            'HomePage.StatsPage',
            'HomePage.Clients',
            'HomePage.MainTransferPage',
            'HomePage.MainTrackingOrder',
            'HomePage.MainDeliveryPage',
            'HomePage.ProductMainPage',
            'HomePage.CompteSetting',
            'Clients.add',
            'StatsPage.TournoverDashboard',
            'StatePage.OrdersStatus',
            'StatsPage.DeliveryOrdersDashboard',
            'StatsPage.lineChart',
            'StatsPage.pieChart',
            'StatsPage.barChart',
            'StatsPage.PromotionSlide',
            'SuperAdmin.dashboard',
            'SuperAdmin.distributors',
            'SuperAdmin.actors',
            'SuperAdmin.audit',
            'SuperAdmin.settings',
            'Distributor.dashboard',
            'Distributor.actors',
            'Distributor.warehouses',
            'Distributor.products',
            'Distributor.stock',
            'Distributor.orders',
            'Distributor.reports',
            'PointVente.home',
            'PointVente.catalog',
            'PointVente.cart',
            'PointVente.my_orders',
            'PointVente.credit',
            'PointVente.support',
        ]);

        foreach ($allPermissions as $permission) {
            DB::table('permissions')->updateOrInsert(
                [
                    'profile_id' => $profileId,
                    'permission' => $permission,
                ],
                [
                    'value' => in_array($permission, $enabledPermissions, true),
                    'created_at' => $now,
                    'updated_at' => $now,
                ]
            );
        }
    }

    private function upsertUserActor(
        string $roleKey,
        string $email,
        string $firstname,
        string $lastname,
        string $actorType,
        int $profileId,
        ?string $distributorId = self::DISTRIBUTOR_ID
    ): void {
        $user = User::updateOrCreate(
            ['email' => $email],
            [
                'name' => "$firstname $lastname",
                'fbuid' => "test-$roleKey",
                'device_id' => 'dev-test-device',
                'fcmtoken' => 'dev-test-token',
                'provider' => 'email',
                'password' => Hash::make(self::PASSWORD),
            ]
        );

        Actor::updateOrCreate(
            ['id' => 'ACT-TEST-' . strtoupper($roleKey)],
            [
                'type' => $actorType,
                'firstname' => $firstname,
                'lastname' => $lastname,
                'phone' => '0000000000',
                'mail' => $email,
                'image' => '/storage/actors/default.png',
                'address_id' => self::ADDRESS_ID,
                'profile_id' => $profileId,
                'user_id' => $user->id,
                'distributor_id' => $distributorId,
                'rate' => 0,
            ]
        );
    }

    private function profilePayload(array $payload): array
    {
        if (!Schema::hasColumn('actor_profile', 'workspace_type')) {
            unset($payload['workspace_type']);
        }

        return $payload;
    }
}
