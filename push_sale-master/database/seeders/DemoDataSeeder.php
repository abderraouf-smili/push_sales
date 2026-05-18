<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Client;
use App\Models\Product;
use App\Models\Variant;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class DemoDataSeeder extends Seeder
{
    private const DISTRIBUTOR_ID = 'DIST-TEST';
    private const WAREHOUSE_ID = 'WH-DEMO-CENTRAL';
    private const STOCK_LIVREUR_ID = 'SM-DEMO-LIVREUR';
    private const STOCK_DEPOT_ID = 'SM-DEMO-DEPOT';

    public function run(): void
    {
        if (app()->environment('production')) {
            $this->command?->warn('DemoDataSeeder skipped in production.');
            return;
        }

        DB::transaction(function () {
            $now = now();

            $this->seedLocations($now);
            $this->seedCommercialSetup($now);
            $this->ensureCompatibilityViews();

            $category = $this->seedCategory();
            $variants = $this->seedProductsAndVariants($category->id, $now);
            $this->seedWarehousesAndStock($variants, $now);
            $this->seedPromotionsAndCoupons($category->id, $variants, $now);
            $clients = $this->seedClients($now);
            $this->seedOrdersAndTransactions($clients, $variants, $now);
            $this->seedProductionValidationData($clients, $now);
        });
    }

    private function seedLocations($now): void
    {
        DB::table('country')->updateOrInsert(
            ['id' => 1],
            ['name' => 'Algerie', 'code' => 'DZ', 'created_at' => $now, 'updated_at' => $now]
        );

        DB::table('state')->updateOrInsert(
            ['id' => 1],
            [
                'name' => 'Alger',
                'name_ar' => 'Alger',
                'code' => '16',
                'country_id' => 1,
                'created_at' => $now,
                'updated_at' => $now,
            ]
        );

        DB::table('city')->updateOrInsert(
            ['id' => 1],
            ['name' => 'Alger Centre', 'name_ar' => 'Alger Centre', 'state_id' => 1, 'created_at' => $now, 'updated_at' => $now]
        );

        DB::table('typepv')->updateOrInsert(
            ['id' => 1],
            ['name' => 'Epicerie', 'name_ar' => 'Epicerie', 'created_at' => $now, 'updated_at' => $now]
        );

        DB::table('typepv')->updateOrInsert(
            ['id' => 2],
            ['name' => 'Superette', 'name_ar' => 'Superette', 'created_at' => $now, 'updated_at' => $now]
        );
    }

    private function seedCommercialSetup($now): void
    {
        DB::table('address')->updateOrInsert(
            ['id' => 'ADDR-DEMO-WH'],
            [
                'street' => 'Depot central demo',
                'commune' => 'Alger Centre',
                'zipcode' => '16000',
                'latitude' => 36.7538,
                'longitude' => 3.0588,
                'city_id' => 1,
                'state_id' => 1,
                'country_id' => 1,
                'created_at' => $now,
                'updated_at' => $now,
            ]
        );

        DB::table('warehouse')->updateOrInsert(
            ['id' => self::WAREHOUSE_ID],
            [
                'name' => 'Depot central demo',
                'code' => 'WH-DEMO',
                'distributor_id' => self::DISTRIBUTOR_ID,
                'address_id' => 'ADDR-DEMO-WH',
                'created_at' => $now,
                'updated_at' => $now,
            ]
        );

        DB::table('distributor')->where('id', self::DISTRIBUTOR_ID)->update(['private' => true, 'updated_at' => $now]);

        foreach (['ACT-TEST-ADMIN', 'ACT-TEST-COMMERCIAL', 'ACT-TEST-LIVREUR', 'ACT-TEST-DEPOT'] as $actorId) {
            DB::table('sequence')->updateOrInsert(
                ['id' => "SEQ-CLIENT-$actorId"],
                [
                    'resource' => 'Client',
                    'res_id' => $actorId,
                    'prefix' => 'CL-DEMO-',
                    'current' => 10,
                    'position' => 4,
                    'created_at' => $now,
                    'updated_at' => $now,
                ]
            );

            DB::table('sequence')->updateOrInsert(
                ['id' => "SEQ-ORDER-$actorId"],
                [
                    'resource' => 'Order',
                    'res_id' => $actorId,
                    'prefix' => 'CMD-DEMO-',
                    'current' => 10,
                    'position' => 4,
                    'created_at' => $now,
                    'updated_at' => $now,
                ]
            );
        }

        DB::table('stock_mobile')->updateOrInsert(
            ['id' => self::STOCK_LIVREUR_ID],
            ['name' => 'Stock mobile livreur demo', 'code' => 'SML-DEMO', 'actor_id' => 'ACT-TEST-LIVREUR', 'created_at' => $now, 'updated_at' => $now]
        );

        DB::table('stock_mobile')->updateOrInsert(
            ['id' => self::STOCK_DEPOT_ID],
            ['name' => 'Stock mobile depot demo', 'code' => 'SMD-DEMO', 'actor_id' => 'ACT-TEST-DEPOT', 'created_at' => $now, 'updated_at' => $now]
        );

        DB::table('transaction_type')->updateOrInsert(
            ['id' => 1],
            ['name' => 'Vente demo', 'sens' => true, 'created_at' => $now, 'updated_at' => $now]
        );

        DB::table('transaction_type')->updateOrInsert(
            ['id' => 2],
            ['name' => 'Encaissement demo', 'sens' => false, 'created_at' => $now, 'updated_at' => $now]
        );
    }

    private function seedCategory(): Category
    {
        return Category::updateOrCreate(
            ['code' => 'DEMO-BOISSONS'],
            [
                'image' => '/storage/demo/category-boissons.png',
                'short_description_ar' => 'Boissons demo',
                'long_description_ar' => 'Categorie de demonstration',
                'short_description_fr' => 'Boissons',
                'long_description_fr' => 'Categorie de demonstration pour valider le catalogue',
            ]
        );
    }

    private function seedProductsAndVariants(int $categoryId, $now): array
    {
        $products = [
            [
                'ssin' => 'DEMO-EAU-15',
                'name' => 'Eau minerale 1.5L',
                'variant' => 'Pack 6',
                'barcode' => 'DEMO000001',
                'price' => 180,
                'stock' => 120,
                'package' => 6,
            ],
            [
                'ssin' => 'DEMO-JUS-1L',
                'name' => 'Jus orange 1L',
                'variant' => 'Carton 12',
                'barcode' => 'DEMO000002',
                'price' => 240,
                'stock' => 85,
                'package' => 12,
            ],
            [
                'ssin' => 'DEMO-SODA-33',
                'name' => 'Soda 33cl',
                'variant' => 'Fardeau 24',
                'barcode' => 'DEMO000003',
                'price' => 95,
                'stock' => 220,
                'package' => 24,
            ],
            [
                'ssin' => 'DEMO-LAIT-1L',
                'name' => 'Lait UHT entier 1L',
                'variant' => 'Carton 12',
                'barcode' => 'DEMO000004',
                'price' => 99,
                'stock' => 180,
                'package' => 12,
            ],
            [
                'ssin' => 'DEMO-HUILE-1L',
                'name' => 'Huile tournesol 1L',
                'variant' => 'Carton 12',
                'barcode' => 'DEMO000005',
                'price' => 210,
                'stock' => 70,
                'package' => 12,
            ],
            [
                'ssin' => 'DEMO-SUCRE-1KG',
                'name' => 'Sucre blanc 1kg',
                'variant' => 'Sac 10',
                'barcode' => 'DEMO000006',
                'price' => 135,
                'stock' => 45,
                'package' => 10,
            ],
            [
                'ssin' => 'DEMO-RIZ-5KG',
                'name' => 'Riz long grain 5kg',
                'variant' => 'Sac',
                'barcode' => 'DEMO000007',
                'price' => 680,
                'stock' => 32,
                'package' => 1,
            ],
            [
                'ssin' => 'DEMO-TOMATE-400',
                'name' => 'Pulpe de tomate 400g',
                'variant' => 'Carton 24',
                'barcode' => 'DEMO000008',
                'price' => 85,
                'stock' => 210,
                'package' => 24,
            ],
            [
                'ssin' => 'DEMO-THON-160',
                'name' => 'Thon huile vegetale 160g',
                'variant' => 'Carton 48',
                'barcode' => 'DEMO000009',
                'price' => 155,
                'stock' => 28,
                'package' => 48,
            ],
            [
                'ssin' => 'DEMO-CAFE-200',
                'name' => 'Cafe moulu 200g',
                'variant' => 'Carton 20',
                'barcode' => 'DEMO000010',
                'price' => 320,
                'stock' => 55,
                'package' => 20,
            ],
            [
                'ssin' => 'DEMO-BISCUIT-12',
                'name' => 'Biscuits fourres',
                'variant' => 'Pack 12',
                'barcode' => 'DEMO000011',
                'price' => 145,
                'stock' => 160,
                'package' => 12,
            ],
            [
                'ssin' => 'DEMO-DETERGENT-2L',
                'name' => 'Detergent liquide 2L',
                'variant' => 'Carton 6',
                'barcode' => 'DEMO000012',
                'price' => 390,
                'stock' => 50,
                'package' => 6,
            ],
            [
                'ssin' => 'DEMO-SAVON-4',
                'name' => 'Savon toilette x4',
                'variant' => 'Pack 4',
                'barcode' => 'DEMO000013',
                'price' => 165,
                'stock' => 90,
                'package' => 4,
            ],
            [
                'ssin' => 'DEMO-LINGETTES',
                'name' => 'Lingettes bebe',
                'variant' => 'Paquet',
                'barcode' => 'DEMO000014',
                'price' => 260,
                'stock' => 64,
                'package' => 1,
            ],
            [
                'ssin' => 'DEMO-PATES-500',
                'name' => 'Pates 500g',
                'variant' => 'Carton 20',
                'barcode' => 'DEMO000015',
                'price' => 75,
                'stock' => 140,
                'package' => 20,
            ],
            [
                'ssin' => 'DEMO-COUSCOUS-1KG',
                'name' => 'Couscous moyen 1kg',
                'variant' => 'Sac 10',
                'barcode' => 'DEMO000016',
                'price' => 125,
                'stock' => 110,
                'package' => 10,
            ],
            [
                'ssin' => 'DEMO-FARINE-1KG',
                'name' => 'Farine 1kg',
                'variant' => 'Sac 10',
                'barcode' => 'DEMO000017',
                'price' => 95,
                'stock' => 80,
                'package' => 10,
            ],
            [
                'ssin' => 'DEMO-CHIPS-50',
                'name' => 'Chips salees 50g',
                'variant' => 'Carton 36',
                'barcode' => 'DEMO000018',
                'price' => 45,
                'stock' => 240,
                'package' => 36,
            ],
            [
                'ssin' => 'DEMO-CHOCOLAT-100',
                'name' => 'Chocolat lait 100g',
                'variant' => 'Carton 24',
                'barcode' => 'DEMO000019',
                'price' => 130,
                'stock' => 75,
                'package' => 24,
            ],
            [
                'ssin' => 'DEMO-EAU-05',
                'name' => 'Eau minerale 0.5L',
                'variant' => 'Pack 12',
                'barcode' => 'DEMO000020',
                'price' => 145,
                'stock' => 260,
                'package' => 12,
            ],
        ];

        $priceListId = DB::table('pricelist')->updateOrInsert(
            ['name' => 'Tarif demo Push Sales'],
            [
                'description' => 'Tarif dev/test',
                'typepv_id' => null,
                'start_date' => null,
                'end_date' => null,
                'active' => true,
                'distributor_id' => self::DISTRIBUTOR_ID,
                'created_at' => $now,
                'updated_at' => $now,
            ]
        );
        $priceListId = DB::table('pricelist')->where('name', 'Tarif demo Push Sales')->value('id');

        $variants = [];
        foreach ($products as $item) {
            $product = Product::updateOrCreate(
                ['ssin' => $item['ssin']],
                [
                    'rate' => 0,
                    'short_description_ar' => $item['name'],
                    'long_description_ar' => $item['name'] . ' demo',
                    'short_description_fr' => $item['name'],
                    'long_description_fr' => $item['name'] . ' - produit de demonstration',
                    'image' => '/storage/demo/product.png',
                    'category_id' => $categoryId,
                ]
            );

            $variant = Variant::updateOrCreate(
                ['barcode' => $item['barcode']],
                [
                    'image' => '/storage/demo/product.png',
                    'package' => $item['package'],
                    'option1_ar' => 'Conditionnement',
                    'option1_fr' => 'Conditionnement',
                    'variant1_ar' => $item['variant'],
                    'variant1_fr' => $item['variant'],
                    'option2_ar' => null,
                    'option2_fr' => null,
                    'variant2_ar' => null,
                    'variant2_fr' => null,
                    'product_id' => $product->id,
                ]
            );

            DB::table('pricelist_item')->updateOrInsert(
                ['pricelist_id' => $priceListId, 'variant_id' => $variant->id],
                ['sku' => $item['ssin'] . '-' . $variant->id, 'price' => $item['price'], 'created_at' => $now, 'updated_at' => $now]
            );

            $variants[] = [
                'model' => $variant,
                'product' => $product,
                'name' => $item['name'],
                'variant' => $item['variant'],
                'price' => $item['price'],
                'stock' => $item['stock'],
                'package' => $item['package'],
            ];
        }

        return $variants;
    }

    private function seedWarehousesAndStock(array $variants, $now): void
    {
        foreach ($variants as $index => $item) {
            $variant = $item['model'];
            DB::table('stock_quantity')->updateOrInsert(
                ['emplacement_id' => self::WAREHOUSE_ID, 'is_mobile' => false, 'variant_id' => $variant->id],
                $this->stockQuantityPayload([
                    'quantity' => $item['stock'],
                    'previsionnel' => $item['stock'],
                    'stock_price' => $item['price'] * 0.72,
                    'created_at' => $now,
                    'updated_at' => $now,
                ], $item['price'] * 0.72)
            );

            foreach ([self::STOCK_LIVREUR_ID, self::STOCK_DEPOT_ID] as $mobileStockId) {
                $mobileQuantity = $mobileStockId === self::STOCK_LIVREUR_ID
                    ? [120, 85, 30][$index] ?? 12
                    : 12;
                $mobilePrevisionnel = $mobileStockId === self::STOCK_LIVREUR_ID
                    ? [96, 85, 45][$index] ?? 12
                    : 12;
                DB::table('stock_quantity')->updateOrInsert(
                    ['emplacement_id' => $mobileStockId, 'is_mobile' => true, 'variant_id' => $variant->id],
                    $this->stockQuantityPayload([
                        'quantity' => $mobileQuantity,
                        'previsionnel' => $mobilePrevisionnel,
                        'stock_price' => $item['price'] * 0.72,
                        'created_at' => $now,
                        'updated_at' => $now,
                    ], $item['price'] * 0.72)
                );
            }
        }
    }

    private function stockQuantityPayload(array $payload, float $lastPurchasePrice): array
    {
        if (Schema::hasColumn('stock_quantity', 'lastpurchaseprice')) {
            $payload['lastpurchaseprice'] = $lastPurchasePrice;
        }

        return $payload;
    }

    private function seedPromotionsAndCoupons(int $categoryId, array $variants, $now): void
    {
        if (Schema::hasTable('promotion_type')) {
            DB::table('promotion_type')->updateOrInsert(
                ['id' => 1],
                [
                    'description' => 'Remise demo',
                    'type' => 'discount',
                    'created_at' => $now,
                    'updated_at' => $now,
                ]
            );
        }

        if (Schema::hasTable('promotion')) {
            DB::table('promotion')->updateOrInsert(
                ['id' => 'PROMO-DEMO-BOISSONS'],
                [
                    'description' => 'Promotion demo boissons -10%',
                    'start_date' => $now->copy()->subDays(3)->format('Y-m-d'),
                    'end_date' => $now->copy()->addDays(30)->format('Y-m-d'),
                    'distributor_id' => self::DISTRIBUTOR_ID,
                    'typepv_id' => 1,
                    'type_promotion_id' => 1,
                    'image' => '/storage/demo/promo-boissons.png',
                    'created_at' => $now,
                    'updated_at' => $now,
                ]
            );
        }

        if (Schema::hasTable('promotion_item') && !empty($variants)) {
            $variant = $variants[0]['model'];
            DB::table('promotion_item')->updateOrInsert(
                ['id' => 'PROMOITEM-DEMO-001'],
                [
                    'promotion_id' => 'PROMO-DEMO-BOISSONS',
                    'category_id' => $categoryId,
                    'product_id' => $variant->product_id,
                    'variant_id' => $variant->id,
                    'discount' => 10,
                    'minimum' => 1,
                    'unite' => 'U',
                    'created_at' => $now,
                    'updated_at' => $now,
                ]
            );
        }

        if (Schema::hasTable('coupon')) {
            DB::table('coupon')->updateOrInsert(
                ['id' => 'COUPON-DEMO-10'],
                [
                    'description' => 'Coupon demo validation commande',
                    'code' => 'DEMO10',
                    'is_pourcentage' => true,
                    'discount' => 10,
                    'count' => 100,
                    'start_date' => $now->copy()->subDays(3)->format('Y-m-d'),
                    'end_date' => $now->copy()->addDays(30)->format('Y-m-d'),
                    'min_amount' => 500,
                    'distributor_id' => self::DISTRIBUTOR_ID,
                    'created_at' => $now,
                    'updated_at' => $now,
                ]
            );
        }
    }

    private function seedClients($now): array
    {
        $clients = [
            ['id' => 'CL-DEMO-001', 'actor' => 'ACT-TEST-COMMERCIAL', 'name' => 'Epicerie El Amane', 'typepv' => 1, 'lat' => 36.7602, 'lng' => 3.0501, 'days' => ['Lundi', 'Mercredi']],
            ['id' => 'CL-DEMO-002', 'actor' => 'ACT-TEST-COMMERCIAL', 'name' => 'Superette Atlas', 'typepv' => 2, 'lat' => 36.7489, 'lng' => 3.0721, 'days' => ['Dimanche', 'Jeudi']],
            ['id' => 'CL-DEMO-003', 'actor' => 'ACT-TEST-ADMIN', 'name' => 'Client Admin Demo', 'typepv' => 1, 'lat' => 36.7550, 'lng' => 3.0600, 'days' => ['Mardi']],
            ['id' => 'CL-DEMO-004', 'actor' => 'ACT-TEST-COMMERCIAL', 'name' => 'Cafe Al Amal', 'typepv' => 1, 'lat' => 36.7641, 'lng' => 3.0442, 'days' => ['Samedi', 'Mardi']],
            ['id' => 'CL-DEMO-005', 'actor' => 'ACT-TEST-COMMERCIAL', 'name' => 'Supermarche Marjane', 'typepv' => 2, 'lat' => 36.7415, 'lng' => 3.0861, 'days' => ['Lundi']],
            ['id' => 'CL-DEMO-006', 'actor' => 'ACT-TEST-COMMERCIAL', 'name' => 'Epicerie Badr', 'typepv' => 1, 'lat' => 36.7322, 'lng' => 3.0913, 'days' => ['Mercredi', 'Vendredi']],
            ['id' => 'CL-DEMO-007', 'actor' => 'ACT-TEST-COMMERCIAL', 'name' => 'Depot Al Ittihad', 'typepv' => 2, 'lat' => 36.7247, 'lng' => 3.1048, 'days' => ['Jeudi']],
            ['id' => 'CL-DEMO-008', 'actor' => 'ACT-TEST-COMMERCIAL', 'name' => 'Boulangerie Les Delices', 'typepv' => 1, 'lat' => 36.7698, 'lng' => 3.0664, 'days' => ['Dimanche']],
            ['id' => 'CL-DEMO-009', 'actor' => 'ACT-TEST-COMMERCIAL', 'name' => 'Pharmacie Andalous', 'typepv' => 2, 'lat' => 36.7509, 'lng' => 3.0385, 'days' => ['Mardi', 'Samedi']],
            ['id' => 'CL-DEMO-010', 'actor' => 'ACT-TEST-COMMERCIAL', 'name' => 'Alimentation Rahma', 'typepv' => 1, 'lat' => 36.7399, 'lng' => 3.0562, 'days' => ['Vendredi']],
        ];

        $created = [];
        foreach ($clients as $client) {
            $addressId = 'ADDR-' . $client['id'];
            DB::table('address')->updateOrInsert(
                ['id' => $addressId],
                [
                    'street' => $client['name'],
                    'commune' => 'Alger Centre',
                    'zipcode' => '16000',
                    'latitude' => $client['lat'],
                    'longitude' => $client['lng'],
                    'city_id' => 1,
                    'state_id' => 1,
                    'country_id' => 1,
                    'created_at' => $now,
                    'updated_at' => $now,
                ]
            );

            Client::updateOrCreate(
                ['id' => $client['id']],
                [
                    'name' => $client['name'],
                    'code' => $client['id'],
                    'mobile' => '0555000000',
                    'image' => '/storage/demo/client.png',
                    'rate' => 0,
                    'actor_id' => $client['actor'],
                    'typepv_id' => $client['typepv'],
                    'address_id' => $addressId,
                ] + (Schema::hasColumn('client', 'credit_limit')
                    ? ['credit_limit' => $client['typepv'] === 2 ? 25000 : 12000]
                    : [])
            );

            foreach ($client['days'] as $day) {
                DB::table('visit_days')->updateOrInsert(
                    ['client_id' => $client['id'], 'day' => $day],
                    ['created_at' => $now, 'updated_at' => $now]
                );
            }
            $created[] = $client['id'];
        }

        return $created;
    }

    private function seedOrdersAndTransactions(array $clients, array $variants, $now): void
    {
        if (empty($clients) || empty($variants)) {
            return;
        }

        $variant = $variants[0]['model'];
        $orderId = 'ORD-DEMO-001';
        DB::table('order')->updateOrInsert(
            ['id' => $orderId],
            [
                'code' => 'CMD-DEMO-0001',
                'actor_id' => 'ACT-TEST-COMMERCIAL',
                'client_id' => $clients[0],
                'total_amount' => 1080,
                'residual' => 1080,
                'order_date' => $now,
                'planned_delivery_date' => $now->copy()->addDay(),
                'delivery_date' => $now->copy()->addDay(),
                'state' => 'new',
                'created_at' => $now,
                'updated_at' => $now,
            ] + $this->tablePayload('order', [
                'order_source' => 'commercial',
                'payment_due_date' => $now->copy()->addDays(15)->format('Y-m-d'),
            ])
        );

        DB::table('orderitem')->updateOrInsert(
            ['id' => 'ORDITEM-DEMO-001'],
            [
                'image' => '/storage/demo/product.png',
                'order_id' => $orderId,
                'variant_id' => $variant->id,
                'sku' => 'DEMO-EAU-15-' . $variant->id,
                'product_name' => $variants[0]['name'],
                'variant_name_1' => $variants[0]['variant'],
                'option_1' => 'Conditionnement',
                'variant_name_2' => null,
                'option_2' => null,
                'promotion_id' => null,
                'promotionitem_id' => null,
                'unite' => 'U',
                'warehouse_id' => self::WAREHOUSE_ID,
                'quantity' => 6,
                'confirmed_quantity' => null,
                'cancelled_quantity' => null,
                'package' => $variants[0]['package'],
                'discount' => 0,
                'price' => $variants[0]['price'],
                'created_at' => $now,
                'updated_at' => $now,
            ]
        );

        $this->seedPurchaseOrder(
            'PO-DEMO-PACK',
            'BL-DEMO-PACK',
            $orderId,
            null,
            $clients[0],
            'new',
            $variant->id,
            $variants[0],
            $now
        );

        $this->seedPurchaseOrder(
            'PO-DEMO-SHIP',
            'BL-DEMO-SHIP',
            $orderId,
            'ACT-TEST-LIVREUR',
            $clients[0],
            'in_way',
            $variant->id,
            $variants[0],
            $now
        );

        $this->seedPurchaseOrder(
            'PO-DEMO-SHIP-002',
            'BL-DEMO-SHIP-002',
            $orderId,
            'ACT-TEST-LIVREUR',
            $clients[1] ?? $clients[0],
            'in_way',
            $variants[1]['model']->id,
            $variants[1],
            $now,
            quantity: 4,
            amount: $variants[1]['price'] * 4,
            deliveryPosition: 2
        );

        $this->seedPurchaseOrder(
            'PO-DEMO-SHIP-003',
            'BL-DEMO-SHIP-003',
            $orderId,
            'ACT-TEST-LIVREUR',
            $clients[2] ?? $clients[0],
            'shipped',
            $variants[2]['model']->id,
            $variants[2],
            $now,
            quantity: 5,
            confirmedQuantity: 4,
            amount: $variants[2]['price'] * 5,
            deliveryPosition: 3
        );

        $this->seedPurchaseOrder(
            'PO-DEMO-SHIP-004',
            'BL-DEMO-SHIP-004',
            $orderId,
            'ACT-TEST-LIVREUR',
            $clients[0],
            'paid',
            $variants[1]['model']->id,
            $variants[1],
            $now,
            quantity: 2,
            confirmedQuantity: 2,
            amount: $variants[1]['price'] * 2,
            deliveryPosition: 4
        );

        DB::table('tracking_orders')->updateOrInsert(
            ['id' => 'TRACK-DEMO-001'],
            [
                'actor_id' => 'ACT-TEST-COMMERCIAL',
                'order_id' => $orderId,
                'purchaseorder_id' => 'PO-DEMO-SHIP',
                'state' => 'in_way',
                'amount' => 1080,
                'image' => '/storage/demo/product.png',
                'is_last' => true,
                'created_at' => $now,
                'updated_at' => $now,
            ]
        );

        DB::table('transactions')->updateOrInsert(
            ['id' => 'TRX-DEMO-001'],
            [
                'client_id' => $clients[0],
                'actor_id' => 'ACT-TEST-COMMERCIAL',
                'order_id' => $orderId,
                'purchaseorder_id' => 'PO-DEMO-SHIP',
                'type_id' => 1,
                'credit' => 0,
                'debit' => 1080,
                'account_date' => $now->format('Y-m-d'),
                'created_at' => $now,
                'updated_at' => $now,
            ]
        );
    }

    private function seedPurchaseOrder(
        string $id,
        string $code,
        string $orderId,
        ?string $actorId,
        string $clientId,
        string $state,
        int $variantId,
        array $variantData,
        $now,
        float $quantity = 6,
        ?float $confirmedQuantity = null,
        ?float $amount = null,
        ?int $deliveryPosition = null
    ): void {
        $totalAmount = $amount ?? 1080;
        $confirmed = in_array($state, ['shipped', 'paid'], true)
            ? ($confirmedQuantity ?? $quantity)
            : $confirmedQuantity;
        DB::table('purchase_order')->updateOrInsert(
            ['id' => $id],
            [
                'code' => $code,
                'order_id' => $orderId,
                'actor_id' => $actorId,
                'client_id' => $clientId,
                'type' => 'invoice_out',
                'warehouse_id' => self::WAREHOUSE_ID,
                'total_amount' => $totalAmount,
                'residual' => $state === 'paid' ? 0 : $totalAmount,
                'purchase_date' => $now,
                'planned_delivery_date' => $now,
                'delivery_date' => in_array($state, ['shipped', 'paid'], true) ? $now : null,
                'state' => $state,
                'created_at' => $now,
                'updated_at' => $now,
            ]
        );

        DB::table('purchase_orderitem')->updateOrInsert(
            ['id' => 'POITEM-' . $id],
            $this->tablePayload('purchase_orderitem', [
                'purchaseorder_id' => $id,
                'image' => '/storage/demo/product.png',
                'product_name' => $variantData['name'],
                'variant_name_1' => $variantData['variant'],
                'option_1' => 'Conditionnement',
                'variant_name_2' => null,
                'option_2' => null,
                'promotion_id' => null,
                'promotionitem_id' => null,
                'unite' => 'U',
                'discount' => 0,
                'variant_id' => $variantId,
                'sku' => 'DEMO-EAU-15-' . $variantId,
                'quantity' => $quantity,
                'confirmed_quantity' => $confirmed,
                'cancelled_quantity' => $confirmed === null ? null : max(0, $quantity - $confirmed),
                'package' => $variantData['package'],
                'price' => $variantData['price'],
                'created_at' => $now,
                'updated_at' => $now,
            ])
        );
    }

    private function seedProductionValidationData(array $clients, $now): void
    {
        if (Schema::hasTable('client_user_access') && !empty($clients)) {
            $pointVenteUserId = DB::table('users')
                ->where('email', 'pointvente.test@pushsales.local')
                ->value('id');

            if ($pointVenteUserId) {
                DB::table('client_user_access')->updateOrInsert(
                    ['user_id' => $pointVenteUserId, 'client_id' => $clients[0]],
                    [
                        'distributor_id' => self::DISTRIBUTOR_ID,
                        'access_type' => 'owner',
                        'is_primary' => true,
                        'is_active' => true,
                        'created_at' => $now,
                        'updated_at' => $now,
                    ]
                );
            }
        }

        if (Schema::hasTable('delivery_trips') && !empty($clients)) {
            $tripId = DB::table('delivery_trips')->updateOrInsert(
                [
                    'actor_id' => 'ACT-TEST-LIVREUR',
                    'trip_date' => $now->format('Y-m-d'),
                ],
                [
                    'distributor_id' => self::DISTRIBUTOR_ID,
                    'status' => 'planned',
                    'route_summary' => json_encode([
                        'mode' => 'demo',
                        'summary' => 'Route demo Alger Centre',
                    ]),
                    'total_distance' => 24.50,
                    'estimated_duration' => 95,
                    'created_at' => $now,
                    'updated_at' => $now,
                ]
            );

            $tripId = DB::table('delivery_trips')
                ->where('actor_id', 'ACT-TEST-LIVREUR')
                ->where('trip_date', $now->format('Y-m-d'))
                ->value('id');

            if ($tripId && Schema::hasTable('delivery_trip_stops')) {
                foreach (array_slice($clients, 0, 4) as $index => $clientId) {
                    $address = DB::table('client')
                        ->join('address', 'address.id', '=', 'client.address_id')
                        ->where('client.id', $clientId)
                        ->select('address.latitude', 'address.longitude')
                        ->first();

                    DB::table('delivery_trip_stops')->updateOrInsert(
                        ['delivery_trip_id' => $tripId, 'client_id' => $clientId],
                        [
                            'purchase_order_id' => $index === 0 ? 'PO-DEMO-SHIP' : null,
                            'order_id' => 'ORD-DEMO-001',
                            'sequence' => $index + 1,
                            'status' => $index === 0 ? 'in_route' : 'planned',
                            'latitude' => $address->latitude ?? null,
                            'longitude' => $address->longitude ?? null,
                            'estimated_arrival' => $now->copy()->addMinutes(30 * ($index + 1)),
                            'actual_arrival' => null,
                            'created_at' => $now,
                            'updated_at' => $now,
                        ]
                    );
                }
            }
        }

        if (Schema::hasTable('audit_logs')) {
            DB::table('audit_logs')->updateOrInsert(
                [
                    'workspace_type' => 'superadmin',
                    'action' => 'demo_seeded',
                    'entity_type' => 'demo_data',
                    'entity_id' => 'push-sales-demo',
                ],
                [
                    'user_id' => DB::table('users')->where('email', 'superadmin@pushsales.local')->value('id'),
                    'actor_id' => 'ACT-TEST-SUPERADMIN',
                    'distributor_id' => self::DISTRIBUTOR_ID,
                    'old_values' => null,
                    'new_values' => json_encode(['demo' => true, 'version' => 'production-validation']),
                    'ip_address' => '127.0.0.1',
                    'user_agent' => 'DemoDataSeeder',
                    'created_at' => $now,
                    'updated_at' => $now,
                ]
            );
        }
    }

    private function tablePayload(string $table, array $payload): array
    {
        return array_filter(
            $payload,
            fn ($key) => Schema::hasColumn($table, $key),
            ARRAY_FILTER_USE_KEY
        );
    }

    private function ensureCompatibilityViews(): void
    {
        if (!$this->relationExists('stock_warehouse')) {
            DB::statement($this->stockWarehouseViewSql());
        }

        if (!$this->relationExists('purchase_variants')) {
            DB::statement($this->purchaseVariantsViewSql());
        }

        if (!$this->relationExists('full_variant')) {
            DB::statement($this->fullVariantViewSql());
        }
    }

    private function relationExists(string $name): bool
    {
        if (Schema::hasTable($name)) {
            return true;
        }

        $rows = DB::select(
            'select table_name from information_schema.views where table_schema = database() and table_name = ?',
            [$name]
        );

        return count($rows) > 0;
    }

    private function stockWarehouseViewSql(): string
    {
        return <<<'SQL'
create view stock_warehouse as
select
  sq.id,
  w.distributor_id,
  sq.emplacement_id as warehouse_id,
  sq.variant_id,
  v.image,
  p.short_description_fr,
  p.short_description_ar,
  v.variant1_fr,
  v.variant1_ar,
  v.variant2_fr,
  v.variant2_ar,
  v.package,
  sq.quantity,
  sq.previsionnel,
  sq.stock_price,
  sq.is_mobile,
  sq.created_at,
  sq.updated_at
from stock_quantity sq
join variant v on v.id = sq.variant_id
join product p on p.id = v.product_id
left join warehouse w on w.id = sq.emplacement_id
SQL;
    }

    private function purchaseVariantsViewSql(): string
    {
        return <<<'SQL'
create view purchase_variants as
select
  sq.id,
  concat(p.ssin, '-', v.id) as sku,
  sq.stock_price as lastpurchaseprice,
  sq.quantity,
  v.barcode,
  v.image,
  v.package,
  v.option1_ar,
  v.option1_fr,
  v.variant1_ar,
  v.variant1_fr,
  v.option2_ar,
  v.option2_fr,
  v.variant2_ar,
  v.variant2_fr,
  v.product_id,
  sq.emplacement_id as warehouse_id,
  w.distributor_id,
  sq.created_at,
  sq.updated_at
from stock_quantity sq
join variant v on v.id = sq.variant_id
join product p on p.id = v.product_id
left join warehouse w on w.id = sq.emplacement_id
where sq.is_mobile = 0
SQL;
    }

    private function fullVariantViewSql(): string
    {
        return <<<'SQL'
create view full_variant as
select
  sq.id,
  concat(p.ssin, '-', v.id) as sku,
  coalesce(pli.price, 0) as price,
  sq.quantity,
  sq.previsionnel,
  0 as discount,
  0 as minimum,
  'U' as unite,
  null as promo_type,
  v.barcode,
  v.image,
  v.package,
  v.option1_ar,
  v.option1_fr,
  v.variant1_ar,
  v.variant1_fr,
  v.option2_ar,
  v.option2_fr,
  v.variant2_ar,
  v.variant2_fr,
  v.product_id,
  null as promotion_typepv_id,
  pl.typepv_id as pricelits_typepv_id,
  pl.typepv_id as pricelist_typepv_id,
  sq.emplacement_id as warehouse_id,
  w.distributor_id,
  0 as private,
  sq.created_at,
  sq.updated_at
from stock_quantity sq
join variant v on v.id = sq.variant_id
join product p on p.id = v.product_id
left join warehouse w on w.id = sq.emplacement_id
left join pricelist_item pli on pli.variant_id = v.id
left join pricelist pl on pl.id = pli.pricelist_id and (pl.distributor_id = w.distributor_id or w.distributor_id is null)
where sq.is_mobile = 0
SQL;
    }
}
