<?php

namespace App\Http\Controllers;

use App\Models\Actor;
use App\Models\ActorProfile;
use App\Models\Address;
use App\Models\Category;
use App\Models\Client;
use App\Models\Distributor;
use App\Models\Order;
use App\Models\PriceList;
use App\Models\PriceListItem;
use App\Models\Product;
use App\Models\Coupon;
use App\Models\Promotion;
use App\Models\PromotionItem;
use App\Models\PromotionType;
use App\Models\PurchaseOrder;
use App\Models\StockMobile;
use App\Models\StockQuantity;
use App\Models\Transactions;
use App\Models\TypePV;
use App\Models\User;
use App\Models\Variant;
use App\Models\Warehouse;
use App\Support\WorkspaceResolver;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;
use Throwable;

class WorkspaceMvpController extends Controller
{
    public function index(Request $request)
    {
        try {
            $user = Auth::user();
            $actor = Actor::with(['Profile', 'Distributor', 'StockMobile'])->where('user_id', $user->id)->first();

            if (!$actor) {
                return response()->json(['status' => 'FAIL', 'message' => 'Actor profile not found']);
            }

            $workspace = WorkspaceResolver::type($actor);
            $section = (string) $request->input('section', 'dashboard');
            $dashboardDistributorId = $this->dashboardDistributorScope($workspace, $actor, $section, $request);

            return response()->json([
                'status' => 'SUCCESS',
                'data' => [
                    'workspace_type' => $workspace,
                    'section' => $section,
                    'title' => $this->title($workspace, $section),
                    'subtitle' => $this->subtitle($workspace, $section),
                    'user' => [
                        'id' => $user->id,
                        'name' => $user->name,
                        'email' => $user->email,
                    ],
                    'actor' => $this->actorPayload($actor),
                    'dashboard_filters' => $this->dashboardFilters($workspace, $actor, $dashboardDistributorId),
                    'stats' => $this->stats($workspace, $actor, $section, $dashboardDistributorId),
                    'lists' => $this->lists($workspace, $actor, $section),
                    'actions' => $this->actions($workspace, $actor, $section),
                ],
            ]);
        } catch (Throwable $e) {
            Log::error('Workspace MVP payload failed', [
                'user_id' => optional(Auth::user())->id,
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'status' => 'FAIL',
                'message' => 'Unable to load workspace data',
            ]);
        }
    }

    public function distributorContext()
    {
        $actor = $this->currentDistributorActor();
        if (!$actor) {
            return $this->fail('Workspace distributeur requis.');
        }

        $workspace = WorkspaceResolver::DISTRIBUTEUR;
        $productsQuery = Product::with(['allVariants', 'category', 'Distributor'])->limit(100);
        if ($this->actorDistributorId($actor) && Schema::hasColumn('product', 'distributor_id')) {
            $distributorId = $this->actorDistributorId($actor);
            $productsQuery->where(function ($query) use ($distributorId) {
                $query->whereNull('distributor_id')
                    ->orWhere('distributor_id', $distributorId);
            });
        }
        $products = $productsQuery->get();
        $warehouseIds = $this->warehouseIds($workspace, $actor);

        return response()->json([
            'status' => 'SUCCESS',
            'message' => 'Referentiels distributeur charges.',
            'data' => [
                'distributor_id' => $this->actorDistributorId($actor),
                'warehouses_count' => count($warehouseIds),
                'warehouses' => $this->warehousesQuery($workspace, $actor)
                    ->limit(100)
                    ->get()
                    ->map(fn ($warehouse) => [
                        'id' => $warehouse->id,
                        'title' => $warehouse->name,
                        'subtitle' => optional($warehouse->address)->commune,
                    ])
                    ->values(),
                'products' => $products->map(fn ($product) => [
                    'id' => $product->id,
                    'title' => $product->short_description_fr ?: $product->name ?: ('Produit ' . $product->id),
                    'subtitle' => optional($product->category)->short_description_fr ?: ($product->ssin ?: 'Catalogue'),
                    'category_id' => $product->category_id,
                    'category_name' => optional($product->category)->short_description_fr,
                ])->values(),
                'variants' => $products->flatMap(function ($product) use ($warehouseIds, $actor) {
                    return $product->allVariants->map(function ($variant) use ($product, $warehouseIds, $actor) {
                        $stock = StockQuantity::where('variant_id', $variant->id)
                            ->whereIn('emplacement_id', $warehouseIds)
                            ->sum('quantity');
                        $price = $this->priceForVariant($variant->id, $this->actorDistributorId($actor));

                        return [
                            'id' => $variant->id,
                            'title' => trim(($product->name ?: 'Produit') . ' - ' . ($variant->variant1_fr ?: $variant->variant2_fr ?: $variant->barcode ?: $variant->id)),
                            'subtitle' => 'Stock ' . (int) $stock . ' - prix ' . ($price !== null ? $this->money((float) $price) : 'a definir'),
                            'product_id' => $product->id,
                            'product_name' => $product->name,
                            'price' => $price,
                            'stock_quantity' => (int) $stock,
                        ];
                    });
                })->values(),
                'type_pv' => TypePV::query()
                    ->limit(100)
                    ->get()
                    ->map(fn ($type) => [
                        'id' => $type->id,
                        'title' => $type->name,
                    ])
                    ->values(),
                'categories' => Category::query()
                    ->limit(100)
                    ->get()
                    ->map(fn ($category) => [
                        'id' => $category->id,
                        'title' => $category->short_description_fr
                            ?? $category->short_description
                            ?? $category->name
                            ?? $category->label
                            ?? $category->id,
                    ])
                    ->values(),
                'promotion_types' => PromotionType::query()
                    ->limit(100)
                    ->get()
                    ->map(fn ($type) => [
                        'id' => $type->id,
                        'title' => $type->name ?? $type->description ?? $type->id,
                    ])
                    ->values(),
                'actor_profiles' => ActorProfile::query()
                    ->whereIn('workspace_type', ['distributeur', 'commercial', 'depot', 'livreur'])
                    ->orWhereIn('code', ['distributeur', 'commercial', 'depot', 'livreur'])
                    ->limit(50)
                    ->get()
                    ->map(fn ($profile) => [
                        'id' => $profile->id,
                        'title' => $profile->name ?? $profile->code ?? $profile->type ?? 'Profil',
                        'workspace_type' => $profile->workspace_type ?? $profile->code,
                    ])
                    ->values(),
            ],
        ]);
    }

    public function createDistributorActor(Request $request)
    {
        $manager = $this->currentDistributorActor();
        if (!$manager) {
            return $this->fail('Workspace distributeur requis.');
        }

        $workspace = (string) $request->input('workspace_type', 'commercial');
        if (!in_array($workspace, ['distributeur', 'commercial', 'depot', 'livreur'], true)) {
            return $this->fail('Workspace acteur non autorise pour le distributeur.');
        }

        $email = trim((string) $request->input('email'));
        $firstname = trim((string) $request->input('firstname'));
        if ($email === '' || $firstname === '') {
            return $this->fail('Prenom et email sont obligatoires.');
        }
        if (User::where('email', $email)->exists()) {
            return $this->fail('Un utilisateur existe deja avec cet email.');
        }

        $profile = $this->profileForWorkspace($workspace);
        if (!$profile) {
            return $this->fail('Profil acteur introuvable pour ' . $workspace . '.');
        }

        $password = (string) $request->input('password', 'Test@123456');
        $userId = $this->makeId('USR', $email);
        $actorId = $this->makeId('ACT', $email);
        $addressId = $this->makeId('ADDR', $email);

        $user = User::create([
            'id' => $userId,
            'name' => trim($firstname . ' ' . (string) $request->input('lastname')),
            'email' => $email,
            'email_verified_at' => $request->boolean('email_verified', true) ? now() : null,
            'password' => Hash::make($password),
        ]);

        $address = Address::create([
            'id' => $addressId,
            'street' => (string) $request->input('street', ''),
            'commune' => (string) $request->input('commune', ''),
        ]);

        $actor = Actor::create([
            'id' => $actorId,
            'type' => 'distributor_staff',
            'firstname' => $firstname,
            'lastname' => (string) $request->input('lastname', ''),
            'mail' => $email,
            'phone' => (string) $request->input('phone', ''),
            'user_id' => $user->id,
            'profile_id' => $profile->id,
            'distributor_id' => $this->actorDistributorId($manager),
            'address_id' => $address->id,
            'is_active' => $request->boolean('is_active', true),
        ]);

        if (Schema::hasColumn('actor', 'id_distributor')) {
            Actor::where('id', $actor->id)->update(['id_distributor' => $this->actorDistributorId($manager)]);
        }

        if (($profile->has_stock_mobile ?? false) && Schema::hasTable('stock_mobile')) {
            StockMobile::firstOrCreate(['actor_id' => $actor->id], [
                'id' => $this->makeId('MOB', $actor->id),
                'name' => 'Stock mobile ' . trim($actor->firstname . ' ' . $actor->lastname),
                'code' => $actor->id,
            ]);
        }

        $this->auditDistributorAction('create_actor', 'actor', $actor->id, $actor->toArray(), $this->actorDistributorId($manager));

        return $this->ok(['actor' => $actor->load(['Profile', 'Distributor'])], 'Acteur cree et rattache au distributeur.');
    }

    public function createDistributorWarehouse(Request $request)
    {
        $actor = $this->currentDistributorActor();
        if (!$actor) {
            return $this->fail('Workspace distributeur requis.');
        }
        $name = trim((string) $request->input('name'));
        if ($name === '') {
            return $this->fail('Nom depot obligatoire.');
        }

        $warehouseId = $this->makeId('WH', $name);
        $address = Address::create([
            'id' => $this->makeId('ADDR', $warehouseId),
            'street' => (string) $request->input('street', ''),
            'commune' => (string) $request->input('commune', ''),
        ]);
        $warehouse = Warehouse::create([
            'id' => $warehouseId,
            'name' => $name,
            'code' => $this->uniqueCode(
                'warehouse',
                'code',
                (string) ($request->input('code') ?: $name),
                'WH'
            ),
            'distributor_id' => $this->actorDistributorId($actor),
            'address_id' => $address->id,
        ]);

        $this->auditDistributorAction('create_warehouse', 'warehouse', $warehouse->id, $warehouse->toArray(), $this->actorDistributorId($actor));

        return $this->ok(['warehouse' => $warehouse], 'Depot cree pour le distributeur.');
    }

    public function createDistributorClient(Request $request)
    {
        $actor = $this->currentDistributorActor();
        if (!$actor) {
            return $this->fail('Workspace distributeur requis.');
        }
        $name = trim((string) $request->input('name'));
        if ($name === '') {
            return $this->fail('Nom client obligatoire.');
        }

        $typePv = $request->input('typepv_id') ?: optional(TypePV::query()->first())->id;
        if (!$typePv) {
            return $this->fail('Type de point de vente indisponible. Creez au moins un type PV avant de creer un client.');
        }
        $address = Address::create([
            'id' => $this->makeId('ADDR', $name),
            'street' => (string) $request->input('street', ''),
            'commune' => (string) $request->input('commune', ''),
        ]);
        $clientPayload = [
            'id' => $this->makeId('CL', $name),
            'name' => $name,
            'mobile' => (string) $request->input('phone', ''),
            'actor_id' => $actor->id,
            'address_id' => $address->id,
            'typepv_id' => $typePv,
        ];
        if (Schema::hasColumn('client', 'code')) {
            $clientPayload['code'] = $this->uniqueCode('client', 'code', $name, 'CL');
        }
        $client = Client::create($clientPayload);

        $this->auditDistributorAction('create_client', 'client', $client->id, $client->toArray(), $this->actorDistributorId($actor));

        return $this->ok(['client' => $client], 'Client cree pour le distributeur.');
    }

    public function createDistributorCoupon(Request $request)
    {
        $actor = $this->currentDistributorActor();
        if (!$actor) {
            return $this->fail('Workspace distributeur requis.');
        }

        $code = trim((string) $request->input('code'));
        if ($code === '') {
            return $this->fail('Code coupon obligatoire.');
        }

        $coupon = Coupon::create([
            'id' => $this->makeId('CPN', $code),
            'description' => (string) $request->input('description', $code),
            'code' => $code,
            'is_pourcentage' => $request->boolean('is_pourcentage', true),
            'discount' => (float) $request->input('discount', 0),
            'count' => (int) $request->input('count', 100),
            'min_amount' => (float) $request->input('min_amount', 0),
            'start_date' => $request->input('start_date') ?: now(),
            'end_date' => $request->input('end_date') ?: now()->addMonth(),
            'distributor_id' => $this->actorDistributorId($actor),
        ]);

        $this->auditDistributorAction('create_coupon', 'coupon', $coupon->id, $coupon->toArray(), $this->actorDistributorId($actor));

        return $this->ok(['coupon' => $coupon], 'Coupon cree.');
    }

    public function createDistributorPromotion(Request $request)
    {
        $actor = $this->currentDistributorActor();
        if (!$actor) {
            return $this->fail('Workspace distributeur requis.');
        }

        $description = trim((string) $request->input('description'));
        if ($description === '') {
            return $this->fail('Description promotion obligatoire.');
        }

        $typePv = $request->input('typepv_id') ?: optional(TypePV::query()->first())->id;
        $typePromotion = $request->input('type_promotion_id') ?: optional(PromotionType::query()->first())->id;
        if (!$typePv || !$typePromotion) {
            return $this->fail('Configuration promotion incomplete. Type PV et type promotion sont requis.');
        }
        $discount = (float) $request->input('discount', 0);
        if ($discount <= 0) {
            return $this->fail('La remise doit etre superieure a 0.');
        }

        $promotion = Promotion::create([
            'id' => $this->makeId('PROM', $description),
            'description' => $description,
            'start_date' => $request->input('start_date') ?: now(),
            'end_date' => $request->input('end_date') ?: now()->addMonth(),
            'typepv_id' => $typePv,
            'type_promotion_id' => $typePromotion,
            'distributor_id' => $this->actorDistributorId($actor),
        ]);

        $lines = $request->input('lines', []);
        if (!is_array($lines) || empty($lines)) {
            $lines = [[
                'category_id' => $request->input('category_id'),
                'product_id' => $request->input('product_id'),
                'variant_id' => $request->input('variant_id'),
                'discount' => $discount,
                'unite' => $request->input('unite', '%'),
                'minimum' => (int) $request->input('minimum', 1),
            ]];
        }

        $createdLines = [];
        foreach ($lines as $index => $line) {
            $createdLines[] = PromotionItem::create([
                'id' => $this->makeId('PROMITEM', $promotion->id . $index . json_encode($line)),
                'promotion_id' => $promotion->id,
                'category_id' => $line['category_id'] ?? null,
                'product_id' => $line['product_id'] ?? null,
                'variant_id' => $line['variant_id'] ?? null,
                'discount' => (float) ($line['discount'] ?? $discount),
                'unite' => (string) ($line['unite'] ?? $request->input('unite', '%')),
                'minimum' => (int) ($line['minimum'] ?? $request->input('minimum', 1)),
            ]);
        }

        $this->auditDistributorAction('create_promotion', 'promotion', $promotion->id, [
            ...$promotion->toArray(),
            'lines_count' => count($createdLines),
        ], $this->actorDistributorId($actor));

        return $this->ok(['promotion' => $promotion, 'items' => $createdLines], 'Promotion creee avec lignes applicables.');
    }

    public function adjustDistributorStock(Request $request)
    {
        $actor = $this->currentDistributorActor();
        if (!$actor) {
            return $this->fail('Workspace distributeur requis.');
        }

        $warehouseId = (string) $request->input('warehouse_id');
        $variantId = (string) $request->input('variant_id');
        if ($warehouseId === '' || $variantId === '') {
            return $this->fail('Depot et variant obligatoires.');
        }

        $warehouse = $this->warehousesQuery(WorkspaceResolver::DISTRIBUTEUR, $actor)->where('id', $warehouseId)->first();
        if (!$warehouse) {
            return $this->fail('Depot non autorise pour ce distributeur.');
        }
        if (!Variant::where('id', $variantId)->exists()) {
            return $this->fail('Variant introuvable.');
        }

        $quantity = (int) $request->input('quantity', 0);
        $mode = (string) $request->input('mode', 'set');
        $stock = StockQuantity::firstOrCreate([
            'emplacement_id' => $warehouseId,
            'is_mobile' => false,
            'variant_id' => $variantId,
        ], [
            'id' => $this->makeId('STK', $warehouseId . $variantId),
            'quantity' => 0,
            'previsionnel' => 0,
            'lastpurchaseprice' => (float) $request->input('lastpurchaseprice', 0),
            'stock_price' => (float) $request->input('stock_price', 0),
        ]);

        $old = (int) $stock->quantity;
        $new = match ($mode) {
            'add' => $old + $quantity,
            'sub' => max(0, $old - $quantity),
            default => max(0, $quantity),
        };
        $stock->quantity = $new;
        $stock->previsionnel = $new;
        if ($request->has('lastpurchaseprice')) {
            $stock->lastpurchaseprice = (float) $request->input('lastpurchaseprice', 0);
        }
        $stock->save();

        $this->auditDistributorAction('adjust_stock', 'stock_quantity', $stock->id, ['old_quantity' => $old, 'new_quantity' => $new, 'variant_id' => $variantId, 'warehouse_id' => $warehouseId], $this->actorDistributorId($actor));

        return $this->ok(['stock' => $stock], 'Stock ajuste.');
    }

    public function saveDistributorVariantPrice(Request $request, $id)
    {
        $actor = $this->currentDistributorActor();
        if (!$actor) {
            return $this->fail('Workspace distributeur requis.');
        }
        if (!Variant::where('id', $id)->exists()) {
            return $this->fail('Variant introuvable.');
        }

        $price = (float) $request->input('price', 0);
        if ($price <= 0) {
            return $this->fail('Prix de vente obligatoire.');
        }

        $typePvId = $request->input('typepv_id') ?: optional(TypePV::query()->first())->id;
        $priceList = PriceList::firstOrCreate([
            'distributor_id' => $this->actorDistributorId($actor),
            'typepv_id' => $typePvId,
        ], [
            'id' => $this->makeId('PL', $this->actorDistributorId($actor) . $typePvId),
            'code' => 'DEFAULT-' . $this->actorDistributorId($actor),
            'name' => 'Liste prix distributeur',
            'description' => 'Liste prix creee depuis workspace distributeur',
            'start_date' => now(),
            'end_date' => now()->addYear(),
            'active' => true,
        ]);

        $item = PriceListItem::where('pricelist_id', $priceList->id)
            ->where('variant_id', $id)
            ->first();
        if (!$item) {
            $item = new PriceListItem([
                'id' => $this->makeId('PLI', $priceList->id . $id),
                'pricelist_id' => $priceList->id,
                'variant_id' => $id,
            ]);
        }
        $item->sku = (string) $request->input('sku', $id);
        $item->price = $price;
        $item->save();

        $this->auditDistributorAction('save_variant_price', 'pricelist_item', $item->id, $item->toArray(), $this->actorDistributorId($actor));

        return $this->ok(['price' => $item], 'Prix variant enregistre.');
    }

    private function title(string $workspace, string $section): string
    {
        $map = [
            'dashboard' => match ($workspace) {
                WorkspaceResolver::SUPERADMIN => 'Dashboard global',
                WorkspaceResolver::DISTRIBUTEUR => 'Dashboard distributeur',
                WorkspaceResolver::DEPOT => 'Dashboard depot',
                WorkspaceResolver::LIVREUR => 'Dashboard livreur',
                WorkspaceResolver::POINT_VENTE => 'Accueil point de vente',
                default => 'Dashboard commercial',
            },
            'distributors' => 'Distributeurs',
            'actors' => 'Acteurs',
            'warehouses' => 'Depots',
            'warehouse_stock' => 'Stock depot',
            'stock' => 'Stock',
            'stock_mobile' => 'Stock mobile',
            'prepare_orders' => 'Commandes a preparer',
            'loadings' => 'Chargements',
            'delivery' => 'Delivery',
            'routes' => 'Trajets',
            'products' => 'Produits',
            'catalog' => 'Catalogue',
            'cart' => 'Panier',
            'clients' => 'Clients',
            'orders' => 'Commandes',
            'my_orders' => 'Mes commandes',
            'deliveries' => 'Livraisons',
            'payments' => 'Encaissements',
            'credit' => 'Credit et solde',
            'support' => 'Support',
            'reports' => 'Rapports',
            'audit_logs' => 'Audit logs',
            'settings' => 'Parametres',
            'profile' => 'Profil',
            'promotions' => 'Promotions',
            'coupons' => 'Coupons',
            'more' => 'Plus',
        ];

        return $map[$section] ?? ucfirst(str_replace('_', ' ', $section));
    }

    private function subtitle(string $workspace, string $section): string
    {
        return match ($section) {
            'dashboard' => match ($workspace) {
                WorkspaceResolver::SUPERADMIN => 'Vue globale de la plateforme et des distributeurs',
                WorkspaceResolver::DISTRIBUTEUR => 'Pilotage commercial, logistique et encaissement',
                WorkspaceResolver::DEPOT => 'Preparation, chargements et stock depot',
                WorkspaceResolver::LIVREUR => 'Stock camion, livraisons, trajets et encaissements',
                WorkspaceResolver::POINT_VENTE => 'Catalogue, commandes, credit et support',
                default => 'Commandes, visites, clients et performance du jour',
            },
            'delivery' => 'Demandes preparees, a livrer, en cours et livrees',
            'routes' => 'Clients a livrer et ordre recommande',
            'stock_mobile' => 'Produits dans le camion groupes par produit, etat ou client',
            'catalog', 'products' => 'Catalogue, variants, prix et disponibilite',
            'distributors' => 'Gestion des distributeurs de la plateforme',
            'actors' => 'Gestion des utilisateurs, roles et workspaces',
            'profile', 'settings' => $workspace === WorkspaceResolver::SUPERADMIN
                ? 'Parametres application, securite et services externes'
                : 'Compte, preferences et securite',
            'clients' => 'Liste claire avec visites, commandes et acces carte',
            'promotions' => 'Promotions terrain gerees par le distributeur',
            'coupons' => 'Coupons et remises controles par le distributeur',
            'more' => 'Operations avancees du distributeur',
            default => 'Donnees reelles de la base pour valider le workflow',
        };
    }

    private function dashboardDistributorScope(string $workspace, Actor $actor, string $section, Request $request): ?string
    {
        if ($section !== 'dashboard') {
            return null;
        }

        if ($workspace === WorkspaceResolver::DISTRIBUTEUR) {
            return $this->actorDistributorId($actor);
        }

        if ($workspace !== WorkspaceResolver::SUPERADMIN) {
            return null;
        }

        $id = trim((string) $request->input('distributor_id', ''));
        if ($id === '' || $id === 'all') {
            return null;
        }

        return Distributor::query()->where('id', $id)->exists() ? $id : null;
    }

    private function dashboardFilters(string $workspace, Actor $actor, ?string $selectedDistributorId): array
    {
        if ($workspace !== WorkspaceResolver::SUPERADMIN) {
            return [];
        }

        $items = [[
            'id' => 'all',
            'title' => 'Tous les distributeurs',
            'subtitle' => 'Vue globale plateforme',
            'selected' => $selectedDistributorId === null,
        ]];

        Distributor::query()
            ->orderBy('name')
            ->limit(100)
            ->get()
            ->each(function ($distributor) use (&$items, $selectedDistributorId) {
                $items[] = [
                    'id' => (string) $distributor->id,
                    'title' => $distributor->name ?: ('Distributeur ' . $distributor->id),
                    'subtitle' => 'Code ' . ($distributor->code ?: $distributor->id),
                    'selected' => (string) $selectedDistributorId === (string) $distributor->id,
                ];
            });

        return ['distributors' => $items];
    }

    private function actorPayload(Actor $actor): array
    {
        $distributorId = $this->actorDistributorId($actor);
        return [
            'id' => $actor->id,
            'name' => trim(($actor->firstname ?? '') . ' ' . ($actor->lastname ?? '')) ?: $actor->mail,
            'email' => $actor->mail,
            'type' => $actor->type,
            'profile' => optional($actor->Profile)->name,
            'workspace_type' => WorkspaceResolver::type($actor),
            'distributor_id' => $distributorId,
            'distributor' => optional($actor->Distributor)->name,
        ];
    }

    private function stats(string $workspace, Actor $actor, string $section, ?string $dashboardDistributorId = null): array
    {
        if (
            in_array($workspace, [WorkspaceResolver::SUPERADMIN, WorkspaceResolver::DISTRIBUTEUR], true)
            && $section !== 'dashboard'
        ) {
            return [];
        }

        $warehouseIds = $dashboardDistributorId
            ? Warehouse::query()->where('distributor_id', $dashboardDistributorId)->pluck('id')->all()
            : $this->warehouseIds($workspace, $actor);
        $purchaseBase = $dashboardDistributorId
            ? PurchaseOrder::query()
                ->with(['client.Address', 'warehouse', 'orderitem'])
                ->whereHas('warehouse', fn ($q) => $q->where('distributor_id', $dashboardDistributorId))
            : $this->purchaseOrdersQuery($workspace, $actor);

        $stockQuery = StockQuantity::query();
        if ($workspace === WorkspaceResolver::LIVREUR && $actor->StockMobile) {
            $stockQuery->where('is_mobile', true)->where('emplacement_id', $actor->StockMobile->id);
        } elseif (!empty($warehouseIds)) {
            $stockQuery->whereIn('emplacement_id', $warehouseIds);
        }

        $ordersCount = (string) ($dashboardDistributorId
            ? Order::query()->whereHas('PurchaseOrders.warehouse', fn ($q) => $q->where('distributor_id', $dashboardDistributorId))->count()
            : $this->ordersQuery($workspace, $actor)->count());
        $stockUnits = (string) (int) (clone $stockQuery)->sum('quantity');
        $deliveriesCount = (string) (clone $purchaseBase)->count();
        $toDeliverCount = (string) (clone $purchaseBase)->whereIn('state', ['new', 'prepared', 'packed', 'taken', 'in_way'])->count();
        $deliveredCount = (string) (clone $purchaseBase)->whereIn('state', ['shipped', 'paid', 'partially_paid'])->count();
        $cashQuery = $dashboardDistributorId
            ? Transactions::query()->whereHas('client.Actor', function ($q) use ($dashboardDistributorId) {
                $q->where('distributor_id', $dashboardDistributorId);
                if (Schema::hasColumn('actor', 'id_distributor')) {
                    $q->orWhere('id_distributor', $dashboardDistributorId);
                }
            })
            : $this->transactionsQuery($workspace, $actor);
        $cashTotal = $this->money((float) $cashQuery->sum('debit'));

        return match ($workspace) {
            WorkspaceResolver::SUPERADMIN => [
                $this->stat('Distributeurs', (string) ($dashboardDistributorId ? 1 : $this->distributorsQuery($workspace, $actor)->count()), $dashboardDistributorId ? 'scope selectionne' : 'actifs', 'blue', 'business'),
                $this->stat('Acteurs', (string) ($dashboardDistributorId ? $this->actorsForDistributorCount($dashboardDistributorId) : $this->actorsQuery($workspace, $actor)->count()), 'comptes lies', 'purple', 'users'),
                $this->stat('Commandes', $ordersCount, 'global', 'orange', 'orders'),
                $this->stat('Stock total', $stockUnits, 'unites suivies', 'green', 'inventory'),
            ],
            WorkspaceResolver::DISTRIBUTEUR => [
                $this->stat('Commandes', $ordersCount, 'dans le reseau', 'orange', 'orders'),
                $this->stat('Livraisons', $deliveriesCount, $toDeliverCount . ' a traiter', 'purple', 'delivery'),
                $this->stat('Encaissements', $cashTotal, 'transactions', 'green', 'cash'),
                $this->stat('Stock faible', (string) (clone $stockQuery)->where('quantity', '<=', 10)->count(), 'a surveiller', 'red', 'inventory'),
            ],
            WorkspaceResolver::LIVREUR => [
                $this->stat('Stock camion', $stockUnits, 'unites a bord', 'green', 'inventory'),
                $this->stat('A livrer', $toDeliverCount, 'reste terrain', 'blue', 'route'),
                $this->stat('Livrees', $deliveredCount, 'terminees', 'purple', 'delivery'),
                $this->stat('Encaissements', $cashTotal, 'cash attendu', 'green', 'cash'),
            ],
            WorkspaceResolver::COMMERCIAL => [
                $this->stat('Commandes', $ordersCount, 'dans le portefeuille', 'orange', 'orders'),
                $this->stat('Clients', (string) $this->clientsQuery($workspace, $actor)->count(), 'affectes', 'blue', 'users'),
                $this->stat('Livraisons', $deliveriesCount, 'suivi client', 'purple', 'delivery'),
                $this->stat('CA / soldes', $cashTotal, 'transactions', 'green', 'cash'),
            ],
            WorkspaceResolver::DEPOT => [
                $this->stat('Stock depot', $stockUnits, 'unites disponibles', 'green', 'inventory'),
                $this->stat('A preparer', $toDeliverCount, 'bons en attente', 'orange', 'orders'),
                $this->stat('Chargements', $deliveriesCount, 'operations', 'purple', 'delivery'),
                $this->stat('Livrees', $deliveredCount, 'sorties confirmees', 'blue', 'route'),
            ],
            WorkspaceResolver::POINT_VENTE => [
                $this->stat('Mes commandes', $ordersCount, 'demandes suivies', 'orange', 'orders'),
                $this->stat('En livraison', $toDeliverCount, 'reste a recevoir', 'blue', 'route'),
                $this->stat('Solde', $cashTotal, 'transactions', 'green', 'cash'),
                $this->stat('Catalogue', (string) Product::count(), 'articles visibles', 'purple', 'inventory'),
            ],
            default => [
                $this->stat('Commandes', $ordersCount, 'dans le perimetre', 'orange', 'orders'),
                $this->stat('Stock total', $stockUnits, 'unites', 'green', 'inventory'),
                $this->stat('Livraisons', $deliveriesCount, 'bons operationnels', 'purple', 'delivery'),
                $this->stat('Encaissements', $cashTotal, 'transactions', 'green', 'cash'),
            ],
        };
    }

    private function stat(string $label, string $value, string $detail, string $color, string $icon): array
    {
        return compact('label', 'value', 'detail', 'color', 'icon');
    }

    private function lists(string $workspace, Actor $actor, string $section): array
    {
        return match ($section) {
            'distributors' => [
                ['title' => 'Distributeurs actifs', 'items' => $this->distributorItems($workspace, $actor)],
            ],
            'actors' => [
                ['title' => 'Acteurs et roles', 'items' => $this->actorItems($workspace, $actor)],
            ],
            'warehouses', 'warehouse_stock', 'stock' => [
                ['title' => 'Depots', 'items' => $this->warehouseItems($workspace, $actor)],
                ['title' => 'Articles en stock', 'items' => $this->stockItems($workspace, $actor, false)],
            ],
            'stock_mobile' => [
                ['title' => 'Produits charges', 'items' => $this->stockItems($workspace, $actor, true)],
                ['title' => 'Livraisons liees au stock', 'items' => $this->purchaseOrderItems($workspace, $actor, ['new', 'taken', 'in_way', 'shipped'])],
            ],
            'products', 'catalog' => [
                ['title' => 'Produits disponibles', 'items' => $this->productItems($workspace, $actor)],
            ],
            'clients' => [
                ['title' => 'Clients affectes', 'items' => $this->clientItems($workspace, $actor)],
            ],
            'orders', 'my_orders' => [
                ['title' => 'Commandes', 'items' => $this->orderItems($workspace, $actor)],
                ['title' => 'Suivi operationnel', 'items' => $this->purchaseOrderItems($workspace, $actor)],
            ],
            'prepare_orders', 'loadings', 'delivery', 'deliveries' => [
                ['title' => 'Filtre intelligent', 'items' => $this->deliveryFilterItems($workspace, $actor)],
                ['title' => 'Demandes de livraison', 'items' => $this->purchaseOrderItems($workspace, $actor)],
            ],
            'routes' => [
                ['title' => 'Ordre de passage recommande', 'items' => $this->routeItems($workspace, $actor)],
            ],
            'payments', 'credit' => [
                ['title' => 'Solde et transactions', 'items' => $this->transactionItems($workspace, $actor)],
            ],
            'promotions' => [
                ['title' => 'Promotions', 'items' => $this->promotionItems($workspace, $actor)],
            ],
            'coupons' => [
                ['title' => 'Coupons', 'items' => $this->couponItems($workspace, $actor)],
            ],
            'more' => [
                ['title' => 'Operations distributeur', 'items' => $this->moreItems($workspace, $actor)],
            ],
            'support' => [
                ['title' => 'Support', 'items' => $this->supportItems()],
            ],
            'audit_logs' => [
                ['title' => 'Journal activite', 'items' => $this->auditItems($workspace, $actor)],
            ],
            'profile', 'settings' => [
                ['title' => 'Compte connecte', 'items' => [$this->profileItem($actor)]],
                ...($workspace === WorkspaceResolver::SUPERADMIN ? [
                    ['title' => 'Parametres application', 'items' => $this->superAdminSettingsItems()],
                    ['title' => 'Securite et services externes', 'items' => $this->superAdminSecurityItems()],
                ] : ($workspace === WorkspaceResolver::DISTRIBUTEUR ? [
                    ['title' => 'Informations distributeur', 'items' => $this->distributorProfileItems($actor)],
                    ['title' => 'Configuration terrain', 'items' => $this->distributorConfigurationItems()],
                    ['title' => 'Audit distributeur', 'items' => $this->auditItems($workspace, $actor)],
                ] : [])),
            ],
            default => $this->dashboardLists($workspace, $actor),
        };
    }

    private function dashboardLists(string $workspace, Actor $actor): array
    {
        return match ($workspace) {
            WorkspaceResolver::SUPERADMIN => [
                ['title' => 'Activite recente', 'items' => $this->auditItems($workspace, $actor)],
                ['title' => 'Transactions et alertes', 'items' => $this->superAdminTransactionAlertItems($actor)],
            ],
            WorkspaceResolver::DISTRIBUTEUR => [
                ['title' => 'Alertes operationnelles', 'items' => $this->distributorAlertItems($actor)],
                ['title' => 'Commandes recentes', 'items' => $this->orderItems($workspace, $actor)],
                ['title' => 'Derniers paiements', 'items' => $this->transactionItems($workspace, $actor)],
                ['title' => 'Activite equipe', 'items' => $this->actorItems($workspace, $actor)],
            ],
            WorkspaceResolver::COMMERCIAL => [
                ['title' => 'Clients a visiter', 'items' => $this->clientItems($workspace, $actor)],
                ['title' => 'Commandes a suivre', 'items' => $this->orderItems($workspace, $actor)],
            ],
            WorkspaceResolver::DEPOT => [
                ['title' => 'Preparations prioritaires', 'items' => $this->purchaseOrderItems($workspace, $actor, ['new', 'prepared', 'packed'])],
                ['title' => 'Stock depot', 'items' => $this->stockItems($workspace, $actor, false)],
            ],
            WorkspaceResolver::LIVREUR => [
                ['title' => 'Priorites terrain', 'items' => $this->priorityItems($workspace, $actor)],
                ['title' => 'Stock camion sensible', 'items' => $this->stockItems($workspace, $actor, true)],
            ],
            WorkspaceResolver::POINT_VENTE => [
                ['title' => 'Mes commandes recentes', 'items' => $this->orderItems($workspace, $actor)],
                ['title' => 'Catalogue recommande', 'items' => $this->productItems($workspace, $actor)],
            ],
            default => [
                ['title' => 'Priorites', 'items' => $this->priorityItems($workspace, $actor)],
                ['title' => 'Activite recente', 'items' => $this->orderItems($workspace, $actor)],
            ],
        };
    }

    private function actions(string $workspace, Actor $actor, string $section): array
    {
        $hasWarehouse = $workspace === WorkspaceResolver::DISTRIBUTEUR
            ? $this->warehousesQuery($workspace, $actor)->exists()
            : true;

        $actions = [
            ['label' => 'Actualiser', 'kind' => 'refresh', 'enabled' => true],
        ];

        if (
            in_array($section, ['products', 'catalog'], true)
            && in_array($workspace, [WorkspaceResolver::COMMERCIAL, WorkspaceResolver::POINT_VENTE], true)
        ) {
            $actions[] = ['label' => 'Ajouter au panier', 'kind' => 'cart', 'enabled' => true];
        }

        if ($section === 'cart') {
            $actions[] = ['label' => 'Valider la commande', 'kind' => 'submit_order', 'enabled' => true];
        }

        if (in_array($section, ['delivery', 'deliveries', 'prepare_orders', 'loadings'], true)) {
            if ($workspace === WorkspaceResolver::LIVREUR) {
                $actions[] = ['label' => 'Generer bon de reception', 'kind' => 'reception_note', 'enabled' => true];
                $actions[] = ['label' => 'Confirmer livraison', 'kind' => 'confirm_delivery', 'enabled' => true];
            } elseif ($workspace === WorkspaceResolver::DEPOT) {
                $actions[] = ['label' => 'Preparer', 'kind' => 'prepare_order', 'enabled' => true];
                $actions[] = ['label' => 'Confirmer chargement', 'kind' => 'confirm_loading', 'enabled' => true];
            } else {
                $actions[] = ['label' => 'Voir details', 'kind' => 'view_orders', 'enabled' => true];
            }
        }

        if ($section === 'routes') {
            $actions[] = ['label' => 'Ouvrir Maps', 'kind' => 'maps', 'enabled' => true];
        }

        if (
            in_array($section, ['distributors', 'actors', 'warehouses', 'clients'], true)
            && $workspace !== WorkspaceResolver::DISTRIBUTEUR
        ) {
            if ($workspace === WorkspaceResolver::SUPERADMIN && $section === 'distributors') {
                $actions[] = ['label' => 'Ajouter distributeur', 'kind' => 'create_distributor', 'enabled' => true];
            } elseif ($workspace === WorkspaceResolver::SUPERADMIN && $section === 'actors') {
                $actions[] = ['label' => 'Ajouter acteur', 'kind' => 'create_actor', 'enabled' => true];
            } else {
                $actions[] = ['label' => 'Creer', 'kind' => 'missing_real_api', 'enabled' => true];
            }
        }

        if ($workspace === WorkspaceResolver::SUPERADMIN && $section === 'products') {
            $actions[] = ['label' => 'Ajouter produit', 'kind' => 'create_product', 'enabled' => true];
            $actions[] = ['label' => 'Ajouter categorie', 'kind' => 'create_category', 'enabled' => true];
        }

        if ($workspace === WorkspaceResolver::SUPERADMIN && $section === 'dashboard') {
            $actions[] = ['label' => 'Ajouter distributeur', 'kind' => 'create_distributor', 'enabled' => true];
            $actions[] = ['label' => 'Ajouter manager', 'kind' => 'create_actor', 'enabled' => true];
            $actions[] = ['label' => 'Voir audit logs', 'kind' => 'view_audit_logs', 'enabled' => true];
        }

        if ($workspace === WorkspaceResolver::DISTRIBUTEUR) {
            if ($section === 'dashboard') {
                $actions[] = ['label' => 'Ajouter acteur', 'kind' => 'distributor_create_actor', 'enabled' => true];
                $actions[] = [
                    'label' => 'Ajuster stock',
                    'kind' => 'distributor_adjust_stock',
                    'enabled' => $hasWarehouse,
                    'subtitle' => $hasWarehouse ? 'Stock depot' : 'Creez un depot avant ajustement',
                ];
                $actions[] = ['label' => 'Livraisons urgentes', 'kind' => 'open_delivery', 'enabled' => true];
            } elseif ($section === 'actors') {
                $actions[] = ['label' => 'Ajouter acteur', 'kind' => 'distributor_create_actor', 'enabled' => true];
            } elseif (in_array($section, ['warehouses', 'stock', 'warehouse_stock'], true)) {
                $actions[] = ['label' => 'Ajouter depot', 'kind' => 'distributor_create_warehouse', 'enabled' => true];
                $actions[] = [
                    'label' => 'Ajuster stock',
                    'kind' => 'distributor_adjust_stock',
                    'enabled' => $hasWarehouse,
                    'subtitle' => $hasWarehouse ? 'Stock depot' : 'Creez un depot avant ajustement',
                ];
            } elseif ($section === 'products') {
                $actions[] = ['label' => 'Definir prix', 'kind' => 'distributor_manage_prices', 'enabled' => true];
                $actions[] = [
                    'label' => 'Ajuster stock',
                    'kind' => 'distributor_adjust_stock',
                    'enabled' => $hasWarehouse,
                    'subtitle' => $hasWarehouse ? 'Stock depot' : 'Creez un depot avant ajustement',
                ];
            } elseif ($section === 'clients') {
                $actions[] = ['label' => 'Ajouter client', 'kind' => 'distributor_create_client', 'enabled' => true];
            } elseif ($section === 'promotions') {
                $actions[] = ['label' => 'Creer promotion', 'kind' => 'distributor_create_promotion', 'enabled' => true];
            } elseif ($section === 'coupons') {
                $actions[] = ['label' => 'Creer coupon', 'kind' => 'distributor_create_coupon', 'enabled' => true];
            }
        }

        return $actions;
    }

    private function moreItems(string $workspace, Actor $actor): array
    {
        if ($workspace !== WorkspaceResolver::DISTRIBUTEUR) {
            return [
                ['title' => 'Profil', 'subtitle' => 'Parametres du compte', 'status' => 'OK', 'kind' => 'workspace_link', 'target_section' => 'profile', 'action' => 'Ouvrir'],
            ];
        }

        return [
            ['title' => 'Acteurs', 'subtitle' => 'Equipes terrain, roles et activite', 'status' => (string) $this->actorsQuery($workspace, $actor)->count(), 'kind' => 'workspace_link', 'target_section' => 'actors', 'action' => 'Ouvrir'],
            ['title' => 'Stock', 'subtitle' => 'Stock depot, alertes et mouvements', 'status' => 'Operationnel', 'kind' => 'workspace_link', 'target_section' => 'stock', 'action' => 'Ouvrir'],
            ['title' => 'Livraisons', 'subtitle' => 'Demandes a livrer, retards et preuves', 'status' => (string) $this->purchaseOrdersQuery($workspace, $actor)->count(), 'kind' => 'workspace_link', 'target_section' => 'deliveries', 'action' => 'Ouvrir'],
            ['title' => 'Promotions', 'subtitle' => 'Promotions par produits, clients et zones', 'status' => (string) count($this->promotionItems($workspace, $actor)), 'kind' => 'workspace_link', 'target_section' => 'promotions', 'action' => 'Ouvrir'],
            ['title' => 'Coupons', 'subtitle' => 'Coupons, remises et utilisations', 'status' => (string) count($this->couponItems($workspace, $actor)), 'kind' => 'workspace_link', 'target_section' => 'coupons', 'action' => 'Ouvrir'],
            ['title' => 'Creances', 'subtitle' => 'Encaissements, solde et clients a relancer', 'status' => 'Finance', 'kind' => 'workspace_link', 'target_section' => 'payments', 'action' => 'Ouvrir'],
            ['title' => 'Audit', 'subtitle' => 'Journal des actions du distributeur', 'status' => Schema::hasTable('audit_logs') ? 'Actif' : 'A faire', 'kind' => 'workspace_link', 'target_section' => 'audit_logs', 'action' => 'Ouvrir'],
            ['title' => 'Profil', 'subtitle' => 'Configuration, services et deconnexion', 'status' => 'Compte', 'kind' => 'workspace_link', 'target_section' => 'profile', 'action' => 'Ouvrir'],
        ];
    }

    private function distributorItems(string $workspace, Actor $actor): array
    {
        return $this->distributorsQuery($workspace, $actor)->limit(20)->get()->map(fn ($item) => [
            'id' => $item->id,
            'title' => $item->name,
            'subtitle' => 'Code ' . ($item->code ?? $item->id),
            'status' => Schema::hasColumn('distributor', 'is_active')
                ? ($item->is_active ? 'Actif' : 'Inactif')
                : ($item->private ? 'Actif' : 'Public'),
            'amount' => '',
            'meta' => trim(($item->contact_name ?? '') . ' ' . ($item->phone ?? '')),
            'action' => 'Ouvrir',
            'kind' => 'distributor',
            'is_active' => Schema::hasColumn('distributor', 'is_active') ? (bool) $item->is_active : (bool) $item->private,
            'code' => $item->code,
            'phone' => $item->phone ?? '',
            'email' => $item->email ?? '',
            'contact_name' => $item->contact_name ?? '',
        ])->values()->all();
    }

    private function actorItems(string $workspace, Actor $actor): array
    {
        return $this->actorsQuery($workspace, $actor)->limit(30)->get()->map(fn ($item) => [
            'id' => $item->id,
            'title' => trim(($item->firstname ?? '') . ' ' . ($item->lastname ?? '')) ?: $item->mail,
            'subtitle' => optional($item->Profile)->name . ' - ' . ($item->phone ?? 'telephone non renseigne'),
            'status' => (Schema::hasColumn('actor', 'is_active') && !$item->is_active) ? 'Inactif' : WorkspaceResolver::type($item),
            'amount' => '',
            'meta' => optional($item->Distributor)->name ?: $item->mail,
            'action' => 'Ouvrir',
            'kind' => 'actor',
            'workspace_type' => WorkspaceResolver::type($item),
            'is_active' => Schema::hasColumn('actor', 'is_active') ? (bool) $item->is_active : true,
            'email' => $item->mail,
            'phone' => $item->phone ?? '',
            'distributor_id' => $item->distributor_id,
        ])->values()->all();
    }

    private function warehouseItems(string $workspace, Actor $actor): array
    {
        return $this->warehousesQuery($workspace, $actor)->limit(20)->get()->map(function ($warehouse) {
            $stock = StockQuantity::where('emplacement_id', $warehouse->id)->where('is_mobile', false);

            return [
                'title' => $warehouse->name,
                'subtitle' => trim(optional($warehouse->address)->commune . ' - ' . optional(optional($warehouse->address)->City)->name, ' -') ?: 'Adresse non renseignee',
                'status' => (clone $stock)->where('quantity', '<=', 10)->exists() ? 'Attention' : 'En bonne sante',
                'amount' => $this->money((float) (clone $stock)->sum('stock_price')),
                'meta' => (string) (clone $stock)->count() . ' articles',
                'action' => 'Voir stock',
                'kind' => 'warehouse',
            ];
        })->values()->all();
    }

    private function stockItems(string $workspace, Actor $actor, bool $preferMobile): array
    {
        $query = StockQuantity::with(['variant.product'])->orderByDesc('quantity')->limit(30);

        if ($preferMobile && $actor->StockMobile) {
            $query->where('is_mobile', true)->where('emplacement_id', $actor->StockMobile->id);
        } else {
            $warehouseIds = $this->warehouseIds($workspace, $actor);
            if (!empty($warehouseIds)) {
                $query->whereIn('emplacement_id', $warehouseIds);
            }
        }

        return $query->get()->map(function ($stock) {
            $variant = $stock->variant;
            $product = optional($variant)->product;
            $name = optional($product)->short_description_fr ?: optional($variant)->variant1_fr ?: 'Produit sans nom';
            $status = $stock->quantity <= 0 ? 'Rupture' : ($stock->quantity <= 10 ? 'Stock faible' : 'En stock');

            return [
                'title' => $name,
                'subtitle' => (optional($variant)->variant1_fr ?: 'Variant') . ' - ' . (int) $stock->quantity . ' unites',
                'status' => $status,
                'amount' => $this->money((float) $stock->stock_price),
                'meta' => 'Previsionnel ' . (int) $stock->previsionnel,
                'action' => 'Details',
                'kind' => 'stock',
            ];
        })->values()->all();
    }

    private function productItems(?string $workspace = null, ?Actor $actor = null): array
    {
        $query = Product::with(['category', 'Distributor', 'allVariants'])->limit(30);
        if (
            $workspace !== WorkspaceResolver::SUPERADMIN
            && $actor
            && $this->actorDistributorId($actor)
            && Schema::hasColumn('product', 'distributor_id')
        ) {
            $distributorId = $this->actorDistributorId($actor);
            $query->where(function ($q) use ($distributorId) {
                $q->whereNull('distributor_id')
                    ->orWhere('distributor_id', $distributorId);
            });
        }

        $warehouseIds = $actor ? $this->warehouseIds($workspace ?? '', $actor) : [];

        return $query->get()->map(function ($product) use ($workspace, $warehouseIds) {
            $variant = $product->allVariants->first();
            $price = data_get($variant, 'price')
                ?? data_get($variant, 'sale_price')
                ?? data_get($variant, 'amount');
            $variants = $product->allVariants->map(function ($variant) use ($warehouseIds) {
                $stockQuery = StockQuantity::where('variant_id', $variant->id);
                if (!empty($warehouseIds)) {
                    $stockQuery->whereIn('emplacement_id', $warehouseIds);
                }
                $stockQuantity = (int) $stockQuery->sum('quantity');
                $group = $variant->variant1_fr
                    ?: $variant->option1_fr
                    ?: $variant->package
                    ?: 'Variants';
                $detail = $variant->variant2_fr
                    ?: $variant->option2_fr
                    ?: $variant->variant1_fr
                    ?: 'Variant';

                return [
                    'id' => $variant->id,
                    'variant1_fr' => $variant->variant1_fr,
                    'variant2_fr' => $variant->variant2_fr,
                    'option1_fr' => $variant->option1_fr,
                    'option2_fr' => $variant->option2_fr,
                    'package' => $variant->package,
                    'barcode' => $variant->barcode,
                    'group_label' => $group,
                    'detail_label' => $detail,
                    'stock_quantity' => $stockQuantity,
                    'stock_label' => $stockQuantity . ' stock',
                    'price_label' => 'Prix distributeur',
                ];
            })->values()->all();

            return [
                'id' => $product->id,
                'title' => $product->short_description_fr ?: 'Produit sans nom',
                'subtitle' => optional($variant)->variant1_fr ?: optional($product->category)->short_description_fr ?: 'Catalogue',
                'status' => Schema::hasColumn('product', 'is_active') && !$product->is_active
                    ? 'Inactif'
                    : ($price ? 'En stock' : 'Prix a verifier'),
                'amount' => $price ? $this->money((float) $price) : '',
                'meta' => 'Ref. ' . ($product->ssin ?? $product->id),
                'action' => in_array($workspace, [WorkspaceResolver::COMMERCIAL, WorkspaceResolver::POINT_VENTE], true)
                    ? 'Ajouter'
                    : 'Ouvrir',
                'kind' => 'product',
                'ssin' => $product->ssin,
                'category_id' => $product->category_id,
                'category_label' => optional($product->category)->short_description_fr,
                'distributor_id' => $product->distributor_id ?? null,
                'distributor_label' => optional($product->Distributor)->name,
                'is_active' => Schema::hasColumn('product', 'is_active') ? (bool) $product->is_active : true,
                'variant_count' => $product->allVariants->count(),
                'variants' => $variants,
            ];
        })->values()->all();
    }

    private function superAdminTransactionAlertItems(Actor $actor): array
    {
        $items = [];

        foreach ($this->orderItems(WorkspaceResolver::SUPERADMIN, $actor) as $order) {
            $items[] = [
                ...$order,
                'title' => $order['title'],
                'subtitle' => 'Commande globale - ' . ($order['subtitle'] ?? ''),
                'status' => $order['status'] ?? 'Commande',
                'action' => 'Details',
            ];
            if (count($items) >= 3) {
                break;
            }
        }

        $lowStockCount = Schema::hasTable('stock_quantity')
            ? StockQuantity::where('quantity', '<=', 10)->count()
            : 0;
        $items[] = [
            'title' => 'Stock critique',
            'subtitle' => $lowStockCount . ' produits a reapprovisionner',
            'status' => $lowStockCount > 0 ? 'Attention' : 'OK',
            'amount' => '',
            'meta' => '',
            'action' => 'Details',
            'kind' => 'info',
        ];
        $items[] = [
            'title' => 'Firebase / Maps',
            'subtitle' => 'Configuration reelle a verifier avant production',
            'status' => 'A configurer',
            'amount' => '',
            'meta' => '',
            'action' => 'Details',
            'kind' => 'setting',
        ];

        return $items;
    }

    private function distributorAlertItems(Actor $actor): array
    {
        $workspace = WorkspaceResolver::DISTRIBUTEUR;
        $warehouseIds = $this->warehouseIds($workspace, $actor);
        $lowStockCount = empty($warehouseIds)
            ? 0
            : StockQuantity::whereIn('emplacement_id', $warehouseIds)
                ->where('quantity', '<=', 10)
                ->count();
        $lateOrOpen = $this->purchaseOrdersQuery($workspace, $actor)
            ->whereIn('state', ['new', 'prepared', 'packed', 'taken', 'in_way'])
            ->count();
        $receivable = $this->transactionsQuery($workspace, $actor)->sum('debit') - $this->transactionsQuery($workspace, $actor)->sum('credit');

        return [
            [
                'title' => 'Stock faible',
                'subtitle' => $lowStockCount . ' articles a surveiller dans vos depots',
                'status' => $lowStockCount > 0 ? 'Attention' : 'OK',
                'amount' => '',
                'meta' => 'Depots du distributeur',
                'action' => 'Voir stock',
                'kind' => 'workspace_link',
                'target_section' => 'stock',
            ],
            [
                'title' => 'Livraisons ouvertes',
                'subtitle' => $lateOrOpen . ' demandes a preparer ou livrer',
                'status' => $lateOrOpen > 0 ? 'A traiter' : 'OK',
                'amount' => '',
                'meta' => 'Commandes terrain',
                'action' => 'Voir livraisons',
                'kind' => 'workspace_link',
                'target_section' => 'deliveries',
            ],
            [
                'title' => 'Creances clients',
                'subtitle' => 'Solde global a suivre',
                'status' => $receivable > 0 ? 'A recouvrer' : 'OK',
                'amount' => $this->money((float) $receivable),
                'meta' => 'Transactions distributeur',
                'action' => 'Voir encaissements',
                'kind' => 'workspace_link',
                'target_section' => 'payments',
            ],
        ];
    }

    private function promotionItems(string $workspace, Actor $actor): array
    {
        if (!Schema::hasTable('promotion')) {
            return [
                ['title' => 'Promotions non initialisees', 'subtitle' => 'Table promotion absente', 'status' => 'A faire', 'kind' => 'info', 'action' => 'Actualiser'],
            ];
        }

        $query = Promotion::query()->with(['type', 'typePV', 'lines'])->orderByDesc('start_date');
        if ($workspace !== WorkspaceResolver::SUPERADMIN && $this->actorDistributorId($actor)) {
            $query->where('distributor_id', $this->actorDistributorId($actor));
        }

        return $query->limit(20)->get()->map(fn ($promotion) => [
            'id' => $promotion->id,
            'title' => $promotion->description ?: 'Promotion',
            'subtitle' => trim($this->dateLabel($promotion->start_date) . ' - ' . $this->dateLabel($promotion->end_date), ' -'),
            'status' => now()->between($promotion->start_date, $promotion->end_date) ? 'Active' : 'Planifiee',
            'amount' => (string) $promotion->lines->count() . ' lignes',
            'meta' => optional($promotion->typePV)->name ?: optional($promotion->type)->name,
            'action' => 'Details',
            'kind' => 'promotion',
        ])->values()->all();
    }

    private function couponItems(string $workspace, Actor $actor): array
    {
        if (!Schema::hasTable('coupon')) {
            return [
                ['title' => 'Coupons non initialises', 'subtitle' => 'Table coupon absente', 'status' => 'A faire', 'kind' => 'info', 'action' => 'Actualiser'],
            ];
        }

        $query = Coupon::query()->orderByDesc('start_date');
        if ($workspace !== WorkspaceResolver::SUPERADMIN && $this->actorDistributorId($actor)) {
            $query->where('distributor_id', $this->actorDistributorId($actor));
        }

        return $query->limit(20)->get()->map(fn ($coupon) => [
            'id' => $coupon->id,
            'title' => $coupon->code ?: $coupon->description,
            'subtitle' => $coupon->description ?: 'Coupon distributeur',
            'status' => now()->between($coupon->start_date, $coupon->end_date) ? 'Actif' : 'Expire',
            'amount' => $coupon->is_pourcentage ? ((float) $coupon->discount . '%') : $this->money((float) $coupon->discount),
            'meta' => 'Restant ' . (int) $coupon->count . ' - min ' . $this->money((float) $coupon->min_amount),
            'action' => 'Details',
            'kind' => 'coupon',
        ])->values()->all();
    }

    private function distributorProfileItems(Actor $actor): array
    {
        $distributor = $actor->Distributor;
        if (!$distributor) {
            return [
                ['title' => 'Distributeur non rattache', 'subtitle' => 'Associez ce manager a un distributeur', 'status' => 'A corriger', 'kind' => 'info', 'action' => 'Details'],
            ];
        }

        return [
            [
                'title' => $distributor->name,
                'subtitle' => 'Code ' . ($distributor->code ?? $distributor->id),
                'status' => Schema::hasColumn('distributor', 'is_active') && !$distributor->is_active ? 'Inactif' : 'Actif',
                'amount' => $distributor->phone ?? '',
                'meta' => $distributor->email ?? $distributor->contact_name ?? '',
                'kind' => 'distributor',
                'action' => 'Details',
            ],
            [
                'title' => 'Equipes',
                'subtitle' => $this->actorsQuery(WorkspaceResolver::DISTRIBUTEUR, $actor)->count() . ' acteurs - ' . $this->warehousesQuery(WorkspaceResolver::DISTRIBUTEUR, $actor)->count() . ' depots',
                'status' => 'Operationnel',
                'kind' => 'workspace_link',
                'target_section' => 'actors',
                'action' => 'Ouvrir',
            ],
        ];
    }

    private function distributorConfigurationItems(): array
    {
        return [
            ['title' => 'Notifications terrain', 'subtitle' => 'Stock faible, commandes urgentes et paiement recu', 'status' => 'A configurer', 'kind' => 'setting', 'action' => 'Details'],
            ['title' => 'Bluetooth printer', 'subtitle' => 'Bons preparation, livraison et recus paiement', 'status' => 'Materiel requis', 'kind' => 'setting', 'action' => 'Details'],
            ['title' => 'Google Maps', 'subtitle' => 'Trajets commerciaux et livraisons', 'status' => 'Tester', 'kind' => 'setting', 'action' => 'Details'],
            ['title' => 'Offline mode', 'subtitle' => 'Preparation future pour reseau faible', 'status' => 'A planifier', 'kind' => 'setting', 'action' => 'Details'],
        ];
    }

    private function clientItems(string $workspace, Actor $actor): array
    {
        return $this->clientsQuery($workspace, $actor)->limit(30)->get()->map(function ($client) {
            $balance = Transactions::where('client_id', $client->id)->sum('debit') - Transactions::where('client_id', $client->id)->sum('credit');
            return [
                'title' => $client->name,
                'subtitle' => optional($client->TypePV)->name . ' - ' . (optional($client->Address)->commune ?: 'Alger'),
                'status' => $balance > 0 ? 'Solde ouvert' : 'Actif',
                'amount' => $this->money((float) $balance),
                'meta' => (string) Order::where('client_id', $client->id)->count() . ' commandes',
                'action' => 'Ouvrir',
                'kind' => 'client',
            ];
        })->values()->all();
    }

    private function orderItems(string $workspace, Actor $actor): array
    {
        return $this->ordersQuery($workspace, $actor)->limit(30)->get()->map(fn ($order) => [
            'title' => $order->code ?? $order->id,
            'subtitle' => optional($order->client)->name . ' - ' . $this->dateLabel($order->order_date),
            'status' => $this->stateLabel($order->state),
            'amount' => $this->money((float) $order->total_amount),
            'meta' => $this->money((float) $order->residual) . ' restant',
            'action' => 'Tracking',
            'kind' => 'order',
        ])->values()->all();
    }

    private function purchaseOrderItems(string $workspace, Actor $actor, ?array $states = null): array
    {
        $query = $this->purchaseOrdersQuery($workspace, $actor);
        if ($states !== null) {
            $query->whereIn('state', $states);
        }

        return $query->limit(30)->get()->map(function ($order) use ($workspace) {
            $canReceive = $workspace === WorkspaceResolver::LIVREUR
                && in_array($order->state, ['new', 'prepared', 'packed'], true);

            return [
                'title' => $order->code ?? $order->id,
                'subtitle' => optional($order->client)->name . ' - ' . (optional($order->warehouse)->name ?: 'Depot'),
                'status' => $this->stateLabel($order->state),
                'amount' => $this->money((float) $order->total_amount),
                'meta' => $order->orderitem->count() . ' lignes - ' . $this->money((float) $order->residual) . ' restant',
                'action' => $this->purchaseOrderAction($workspace, $order->state),
                'kind' => 'purchase_order',
                'can_receive' => $canReceive,
                'warehouse_id' => optional($order->warehouse)->id,
                'warehouse_name' => optional($order->warehouse)->name,
                'client_id' => optional($order->client)->id,
            ];
        })->values()->all();
    }

    private function purchaseOrderAction(string $workspace, ?string $state): string
    {
        if ($workspace === WorkspaceResolver::LIVREUR) {
            return in_array($state, ['new', 'prepared', 'packed'], true)
                ? 'Generer bon reception'
                : (in_array($state, ['taken', 'in_way'], true) ? 'Continuer livraison' : 'Voir preuve');
        }

        if ($workspace === WorkspaceResolver::DEPOT) {
            return in_array($state, ['new', 'prepared', 'packed'], true)
                ? 'Preparer'
                : 'Voir chargement';
        }

        return 'Voir details';
    }

    private function deliveryFilterItems(string $workspace, Actor $actor): array
    {
        $query = $this->purchaseOrdersQuery($workspace, $actor);
        return [
            ['title' => 'Toutes', 'subtitle' => 'Toutes les demandes', 'status' => (string) (clone $query)->count(), 'kind' => 'filter', 'action' => 'Filtrer'],
            ['title' => 'Preparees', 'subtitle' => 'Selection possible', 'status' => (string) (clone $query)->whereIn('state', ['new', 'prepared', 'packed'])->count(), 'kind' => 'filter', 'action' => 'Filtrer'],
            ['title' => 'A livrer', 'subtitle' => 'Prises en charge', 'status' => (string) (clone $query)->where('state', 'taken')->count(), 'kind' => 'filter', 'action' => 'Filtrer'],
            ['title' => 'En cours', 'subtitle' => 'En route', 'status' => (string) (clone $query)->where('state', 'in_way')->count(), 'kind' => 'filter', 'action' => 'Filtrer'],
            ['title' => 'Livrees', 'subtitle' => 'Terminees', 'status' => (string) (clone $query)->whereIn('state', ['shipped', 'paid', 'partially_paid'])->count(), 'kind' => 'filter', 'action' => 'Filtrer'],
        ];
    }

    private function routeItems(string $workspace, Actor $actor): array
    {
        if (
            $workspace === WorkspaceResolver::LIVREUR &&
            Schema::hasTable('delivery_trips') &&
            Schema::hasTable('delivery_trip_stops')
        ) {
            $trip = DB::table('delivery_trips')
                ->where('actor_id', $actor->id)
                ->orderByDesc('trip_date')
                ->first();

            if ($trip) {
                $items = DB::table('delivery_trip_stops')
                    ->join('client', 'client.id', '=', 'delivery_trip_stops.client_id')
                    ->leftJoin('address', 'address.id', '=', 'client.address_id')
                    ->where('delivery_trip_id', $trip->id)
                    ->orderBy('sequence')
                    ->limit(12)
                    ->get([
                        'delivery_trip_stops.sequence',
                        'delivery_trip_stops.status',
                        'delivery_trip_stops.estimated_arrival',
                        'client.name',
                        'address.commune',
                        'address.latitude',
                        'address.longitude',
                    ])
                    ->map(fn ($stop) => [
                        'title' => ((int) $stop->sequence) . '. ' . $stop->name,
                        'subtitle' => trim(($stop->commune ?: 'Alger') . ' - arrivee ' . ($stop->estimated_arrival ?: 'a planifier'), ' -'),
                        'status' => $this->stateLabel($stop->status),
                        'amount' => '',
                        'meta' => 'Lat ' . ($stop->latitude ?: '-') . ', Lng ' . ($stop->longitude ?: '-'),
                        'action' => 'Maps',
                        'kind' => 'route',
                    ])
                    ->values()
                    ->all();

                if (!empty($items)) {
                    return $items;
                }
            }
        }

        return $this->purchaseOrdersQuery($workspace, $actor)
            ->whereIn('state', ['new', 'taken', 'in_way'])
            ->limit(10)
            ->get()
            ->values()
            ->map(fn ($order, $index) => [
                'title' => ($index + 1) . '. ' . optional($order->client)->name,
                'subtitle' => $this->money((float) $order->total_amount) . ' - ' . $this->stateLabel($order->state),
                'status' => optional(optional($order->client)->Address)->commune ?: 'Alger',
                'amount' => '',
                'meta' => 'Ouvrir itineraire',
                'action' => 'Maps',
                'kind' => 'route',
            ])->values()->all();
    }

    private function transactionItems(string $workspace, Actor $actor): array
    {
        return $this->transactionsQuery($workspace, $actor)->limit(30)->get()->map(fn ($trx) => [
            'title' => $trx->purchaseorder_id ?: $trx->order_id ?: $trx->id,
            'subtitle' => 'Date ' . ($trx->account_date ?? optional($trx->created_at)->format('Y-m-d')),
            'status' => ((float) $trx->credit) > 0 ? 'Credit' : 'Debit',
            'amount' => $this->money((float) $trx->debit - (float) $trx->credit),
            'meta' => 'Client ' . $trx->client_id,
            'action' => 'Details',
            'kind' => 'transaction',
        ])->values()->all();
    }

    private function priorityItems(string $workspace, Actor $actor): array
    {
        $items = $this->purchaseOrderItems($workspace, $actor, ['new', 'taken', 'in_way']);
        if (!empty($items)) {
            return array_slice($items, 0, 5);
        }

        return [
            ['title' => 'Aucune urgence', 'subtitle' => 'Les donnees de la base sont disponibles', 'status' => 'OK', 'kind' => 'info', 'action' => 'Actualiser'],
        ];
    }

    private function supportItems(): array
    {
        return [
            ['title' => 'Chat support', 'subtitle' => 'Envoyer un message au distributeur', 'status' => 'Disponible', 'kind' => 'support', 'action' => 'Envoyer'],
            ['title' => 'Reclamation livraison', 'subtitle' => 'Signaler une anomalie de livraison', 'status' => 'Disponible', 'kind' => 'support', 'action' => 'Creer'],
        ];
    }

    private function auditItems(string $workspace, Actor $actor): array
    {
        if (!Schema::hasTable('audit_logs')) {
            return [
                ['title' => 'Audit non initialise', 'subtitle' => 'Lancez les migrations production-validation', 'status' => 'A faire', 'kind' => 'info', 'action' => 'Actualiser'],
            ];
        }

        $query = DB::table('audit_logs')->orderByDesc('created_at');
        $distributorId = $this->actorDistributorId($actor);
        if ($workspace !== WorkspaceResolver::SUPERADMIN && $distributorId) {
            $query->where('distributor_id', $distributorId);
        }

        return $query->limit(20)->get()->map(function ($log) {
            return [
                'title' => $log->action,
                'subtitle' => trim(($log->workspace_type ?: 'workspace') . ' - ' . ($log->entity_type ?: 'entite'), ' -'),
                'status' => $this->dateLabel($log->created_at) ?: 'Audit',
                'amount' => '',
                'meta' => $log->entity_id ?: '',
                'action' => 'Details',
                'kind' => 'audit',
            ];
        })->values()->all();
    }

    private function profileItem(Actor $actor): array
    {
        return [
            'title' => trim(($actor->firstname ?? '') . ' ' . ($actor->lastname ?? '')) ?: $actor->mail,
            'subtitle' => optional($actor->Profile)->name . ' - ' . ($actor->mail ?? ''),
            'status' => WorkspaceResolver::type($actor),
            'amount' => optional($actor->Distributor)->name ?: '',
            'meta' => $actor->phone ?? '',
            'action' => 'Deconnexion disponible',
            'kind' => 'profile',
        ];
    }

    private function superAdminSettingsItems(): array
    {
        return [
            ['title' => 'Environnement API', 'subtitle' => app()->environment(), 'status' => config('app.debug') ? 'Debug' : 'Production', 'kind' => 'setting', 'action' => 'Details'],
            ['title' => 'Version API', 'subtitle' => 'Laravel ' . app()->version(), 'status' => 'OK', 'kind' => 'setting', 'action' => 'Details'],
            ['title' => 'Mode maintenance', 'subtitle' => app()->isDownForMaintenance() ? 'Application en maintenance' : 'Application disponible', 'status' => app()->isDownForMaintenance() ? 'Attention' : 'Actif', 'kind' => 'setting', 'action' => 'Details'],
        ];
    }

    private function superAdminSecurityItems(): array
    {
        return [
            ['title' => 'Audit logs', 'subtitle' => Schema::hasTable('audit_logs') ? 'Journalisation active' : 'Migration requise', 'status' => Schema::hasTable('audit_logs') ? 'Actif' : 'A faire', 'kind' => 'audit', 'action' => 'Voir'],
            ['title' => 'Firebase', 'subtitle' => 'Configuration par projet reel requise', 'status' => 'A configurer', 'kind' => 'setting', 'action' => 'Details'],
            ['title' => 'Google Maps', 'subtitle' => 'Cle restreinte package + SHA requise', 'status' => 'A configurer', 'kind' => 'setting', 'action' => 'Details'],
            ['title' => 'Bluetooth printer', 'subtitle' => 'Tester avec imprimante terrain', 'status' => 'Materiel requis', 'kind' => 'setting', 'action' => 'Details'],
        ];
    }

    private function distributorsQuery(string $workspace, Actor $actor): Builder
    {
        $query = Distributor::query()->with('address');
        $distributorId = $this->actorDistributorId($actor);
        if ($workspace !== WorkspaceResolver::SUPERADMIN && $distributorId) {
            $query->where('id', $distributorId);
        }

        return $query;
    }

    private function actorsQuery(string $workspace, Actor $actor): Builder
    {
        $query = Actor::query()->with(['Profile', 'Distributor']);
        $distributorId = $this->actorDistributorId($actor);
        if ($workspace !== WorkspaceResolver::SUPERADMIN && $distributorId) {
            $query->where(function ($q) use ($distributorId) {
                $q->where('distributor_id', $distributorId);
                if (Schema::hasColumn('actor', 'id_distributor')) {
                    $q->orWhere('id_distributor', $distributorId);
                }
            });
        } elseif ($workspace !== WorkspaceResolver::SUPERADMIN) {
            $query->where('id', $actor->id);
        }

        return $query;
    }

    private function warehousesQuery(string $workspace, Actor $actor): Builder
    {
        $query = Warehouse::query()->with(['address.City']);
        $distributorId = $this->actorDistributorId($actor);
        if ($workspace !== WorkspaceResolver::SUPERADMIN && $distributorId) {
            $query->where('distributor_id', $distributorId);
        }

        return $query;
    }

    private function clientsQuery(string $workspace, Actor $actor): Builder
    {
        $query = Client::query()->with(['Address.City', 'TypePV', 'Actor']);
        if ($workspace === WorkspaceResolver::POINT_VENTE) {
            $query->whereIn('id', $this->pointVenteClientIds($actor));
        } elseif ($workspace === WorkspaceResolver::COMMERCIAL) {
            $query->where('actor_id', $actor->id);
        } elseif ($workspace !== WorkspaceResolver::SUPERADMIN && $this->actorDistributorId($actor)) {
            $distributorId = $this->actorDistributorId($actor);
            $query->whereHas('Actor', function ($q) use ($distributorId) {
                $q->where('distributor_id', $distributorId);
                if (Schema::hasColumn('actor', 'id_distributor')) {
                    $q->orWhere('id_distributor', $distributorId);
                }
            });
        }

        return $query;
    }

    private function ordersQuery(string $workspace, Actor $actor): Builder
    {
        $query = Order::query()->with(['client', 'orderitem'])->orderByDesc('order_date');
        if ($workspace === WorkspaceResolver::POINT_VENTE) {
            $query->whereIn('client_id', $this->pointVenteClientIds($actor));
        } elseif ($workspace === WorkspaceResolver::COMMERCIAL) {
            $query->where('actor_id', $actor->id);
        } elseif ($workspace !== WorkspaceResolver::SUPERADMIN && $this->actorDistributorId($actor)) {
            $distributorId = $this->actorDistributorId($actor);
            $query->whereHas('PurchaseOrders.warehouse', fn ($q) => $q->where('distributor_id', $distributorId));
        }

        return $query;
    }

    private function purchaseOrdersQuery(string $workspace, Actor $actor): Builder
    {
        $query = PurchaseOrder::query()
            ->with(['client.Address', 'warehouse', 'orderitem'])
            ->orderByRaw("FIELD(state, 'new', 'prepared', 'packed', 'taken', 'in_way', 'shipped', 'partially_paid', 'paid')")
            ->orderByDesc('purchase_date');

        if ($workspace === WorkspaceResolver::POINT_VENTE) {
            $query->whereIn('client_id', $this->pointVenteClientIds($actor));
        } elseif ($workspace === WorkspaceResolver::LIVREUR) {
            $distributorId = $this->actorDistributorId($actor);
            $query->where(function ($q) use ($actor, $distributorId) {
                $q->where('actor_id', $actor->id);
                if ($distributorId) {
                    $q->orWhereHas('warehouse', fn ($warehouse) => $warehouse->where('distributor_id', $distributorId));
                }
            });
        } elseif ($workspace !== WorkspaceResolver::SUPERADMIN && $this->actorDistributorId($actor)) {
            $distributorId = $this->actorDistributorId($actor);
            $query->whereHas('warehouse', fn ($q) => $q->where('distributor_id', $distributorId));
        }

        return $query;
    }

    private function transactionsQuery(string $workspace, Actor $actor): Builder
    {
        $query = Transactions::query()->orderByDesc('account_date')->orderByDesc('created_at');
        if ($workspace === WorkspaceResolver::POINT_VENTE) {
            $query->whereIn('client_id', $this->pointVenteClientIds($actor));
        } elseif ($workspace === WorkspaceResolver::COMMERCIAL) {
            $query->where('actor_id', $actor->id);
        } elseif ($workspace !== WorkspaceResolver::SUPERADMIN && $this->actorDistributorId($actor)) {
            $distributorId = $this->actorDistributorId($actor);
            $query->whereHas('client.Actor', function ($q) use ($distributorId) {
                $q->where('distributor_id', $distributorId);
                if (Schema::hasColumn('actor', 'id_distributor')) {
                    $q->orWhere('id_distributor', $distributorId);
                }
            });
        }

        return $query;
    }

    private function warehouseIds(string $workspace, Actor $actor): array
    {
        return $this->warehousesQuery($workspace, $actor)->pluck('id')->all();
    }

    private function actorsForDistributorCount(string $distributorId): int
    {
        return Actor::query()
            ->where(function ($query) use ($distributorId) {
                $query->where('distributor_id', $distributorId);
                if (Schema::hasColumn('actor', 'id_distributor')) {
                    $query->orWhere('id_distributor', $distributorId);
                }
            })
            ->count();
    }

    private function pointVenteClientIds(Actor $actor): array
    {
        if (!$actor->user_id || !Schema::hasTable('client_user_access')) {
            return [];
        }

        return DB::table('client_user_access')
            ->where('user_id', $actor->user_id)
            ->where('is_active', true)
            ->pluck('client_id')
            ->all();
    }

    private function actorDistributorId(?Actor $actor): ?string
    {
        if (!$actor) {
            return null;
        }

        $id = $actor->distributor_id
            ?? (Schema::hasColumn('actor', 'id_distributor') ? $actor->id_distributor : null);

        $id = trim((string) $id);
        return $id === '' ? null : $id;
    }

    private function currentDistributorActor(): ?Actor
    {
        $user = Auth::user();
        if (!$user) {
            return null;
        }

        $actor = Actor::with(['Profile', 'Distributor'])->where('user_id', $user->id)->first();
        if (!$actor || WorkspaceResolver::type($actor) !== WorkspaceResolver::DISTRIBUTEUR) {
            return null;
        }

        return $this->actorDistributorId($actor) ? $actor : null;
    }

    private function ok(array $data = [], string $message = 'Operation reussie')
    {
        return response()->json([
            'status' => 'SUCCESS',
            'message' => $message,
            'data' => $data,
        ]);
    }

    private function fail(string $message, int $code = 422)
    {
        return response()->json([
            'status' => 'FAIL',
            'message' => $message,
        ], $code);
    }

    private function makeId(string $prefix, string $source = ''): string
    {
        $seed = Str::slug($source) ?: Str::random(6);
        return Str::upper($prefix . '-' . now()->format('YmdHis') . '-' . substr($seed, 0, 8) . '-' . Str::random(4));
    }

    private function uniqueCode(string $table, string $column, string $seed, string $prefix): string
    {
        $base = Str::upper(Str::slug($seed, '-'));
        $base = $base ? Str::limit($base, 38, '') : $prefix;
        $candidate = $base;
        $index = 1;

        while (
            Schema::hasTable($table)
            && Schema::hasColumn($table, $column)
            && DB::table($table)->where($column, $candidate)->exists()
        ) {
            $index++;
            $candidate = Str::limit($base, 32, '') . '-' . $index;
        }

        return $candidate;
    }

    private function profileForWorkspace(string $workspace): ?ActorProfile
    {
        return ActorProfile::query()
            ->where('workspace_type', $workspace)
            ->orWhere('code', $workspace)
            ->orWhere('name', $workspace)
            ->first();
    }

    private function priceForVariant($variantId, ?string $distributorId): ?float
    {
        if (!$distributorId || !Schema::hasTable('pricelist') || !Schema::hasTable('pricelist_item')) {
            return null;
        }

        $query = PriceListItem::query()
            ->where('variant_id', $variantId)
            ->whereHas('pricelist', function ($priceList) use ($distributorId) {
                $priceList->where('distributor_id', $distributorId);
                if (Schema::hasColumn('pricelist', 'active')) {
                    $priceList->where(function ($q) {
                        $q->where('active', true)->orWhereNull('active');
                    });
                }
            })
            ->orderByDesc('updated_at');

        $value = $query->value('price');
        return $value === null ? null : (float) $value;
    }

    private function auditDistributorAction(string $action, string $entityType, $entityId = null, $newValues = null, ?string $distributorId = null): void
    {
        if (!Schema::hasTable('audit_logs')) {
            return;
        }

        try {
            $user = Auth::user();
            $actor = $user ? Actor::where('user_id', $user->id)->first() : null;
            DB::table('audit_logs')->insert([
                'user_id' => optional($user)->id,
                'actor_id' => optional($actor)->id,
                'distributor_id' => $distributorId,
                'workspace_type' => WorkspaceResolver::DISTRIBUTEUR,
                'action' => $action,
                'entity_type' => $entityType,
                'entity_id' => $entityId,
                'old_values' => null,
                'new_values' => $newValues ? json_encode($newValues) : null,
                'ip_address' => request()->ip(),
                'user_agent' => substr((string) request()->userAgent(), 0, 500),
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        } catch (Throwable $e) {
            Log::warning('Distributor audit log skipped', [
                'action' => $action,
                'entity_type' => $entityType,
                'error' => $e->getMessage(),
            ]);
        }
    }

    private function stateLabel(?string $state): string
    {
        return [
            'draft' => 'Brouillon',
            'pending_validation' => 'A valider',
            'new' => 'Nouveau',
            'processing' => 'En preparation',
            'prepared' => 'Prepare',
            'packed' => 'Prepare',
            'taken' => 'Pris en charge',
            'planned' => 'Planifie',
            'in_route' => 'En route',
            'in_way' => 'En route',
            'shipped' => 'Livre',
            'delivered' => 'Livre',
            'partially_delivered' => 'Livre partiel',
            'partially_paid' => 'Paye partiel',
            'paid' => 'Paye',
            'returned' => 'Retour',
            'cancelled' => 'Annule',
        ][$state ?? ''] ?? ($state ?: 'Nouveau');
    }

    private function money(float $value): string
    {
        return number_format($value, 2, ',', ' ');
    }

    private function dateLabel($value): string
    {
        if (!$value) {
            return '';
        }

        try {
            return \Carbon\Carbon::parse($value)->format('Y-m-d H:i');
        } catch (Throwable) {
            return (string) $value;
        }
    }
}
