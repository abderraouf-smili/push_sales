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
            $clients = $this->seedClients($now);
            $this->seedOrdersAndTransactions($clients, $variants, $now);
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

    private function seedClients($now): array
    {
        $clients = [
            ['id' => 'CL-DEMO-001', 'actor' => 'ACT-TEST-COMMERCIAL', 'name' => 'Epicerie El Amane', 'typepv' => 1, 'lat' => 36.7602, 'lng' => 3.0501],
            ['id' => 'CL-DEMO-002', 'actor' => 'ACT-TEST-COMMERCIAL', 'name' => 'Superette Atlas', 'typepv' => 2, 'lat' => 36.7489, 'lng' => 3.0721],
            ['id' => 'CL-DEMO-003', 'actor' => 'ACT-TEST-ADMIN', 'name' => 'Client Admin Demo', 'typepv' => 1, 'lat' => 36.7550, 'lng' => 3.0600],
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
                ]
            );
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
            ]
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
