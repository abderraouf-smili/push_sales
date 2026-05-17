<?php

namespace Database\Seeders;

use App\Models\Actor;
use App\Models\ActorProfile;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

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
                'admin' => ActorProfile::updateOrCreate(
                    ['code' => 'admin-test'],
                    [
                        'name' => 'Admin Test',
                        'name_ar' => 'Admin Test',
                        'has_stock_mobile' => false,
                        'add_client' => true,
                    ]
                ),
                'commercial' => ActorProfile::updateOrCreate(
                    ['code' => 'commercial-test'],
                    [
                        'name' => 'Commercial Test',
                        'name_ar' => 'Commercial Test',
                        'has_stock_mobile' => false,
                        'add_client' => true,
                    ]
                ),
                'livreur' => ActorProfile::updateOrCreate(
                    ['code' => 'livreur-test'],
                    [
                        'name' => 'Livreur Test',
                        'name_ar' => 'Livreur Test',
                        'has_stock_mobile' => true,
                        'add_client' => false,
                    ]
                ),
                'depot' => ActorProfile::updateOrCreate(
                    ['code' => 'depot-test'],
                    [
                        'name' => 'Depot Test',
                        'name_ar' => 'Depot Test',
                        'has_stock_mobile' => true,
                        'add_client' => false,
                    ]
                ),
            ];

            $permissionSets = [
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
            ];

            foreach ($permissionSets as $role => $permissions) {
                $this->syncPermissions($profiles[$role]->id, $permissions, $now);
            }

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
        int $profileId
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
                'distributor_id' => self::DISTRIBUTOR_ID,
                'rate' => 0,
            ]
        );
    }
}
