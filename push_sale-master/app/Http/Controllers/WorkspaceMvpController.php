<?php

namespace App\Http\Controllers;

use App\Models\Actor;
use App\Models\Client;
use App\Models\Distributor;
use App\Models\Order;
use App\Models\Product;
use App\Models\PurchaseOrder;
use App\Models\StockMobile;
use App\Models\StockQuantity;
use App\Models\Transactions;
use App\Models\Warehouse;
use App\Support\WorkspaceResolver;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Schema;
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
                    'stats' => $this->stats($workspace, $actor, $section),
                    'lists' => $this->lists($workspace, $actor, $section),
                    'actions' => $this->actions($workspace, $section),
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
            'clients' => 'Liste claire avec visites, commandes et acces carte',
            default => 'Donnees demo/API disponibles pour valider le workflow',
        };
    }

    private function actorPayload(Actor $actor): array
    {
        return [
            'id' => $actor->id,
            'name' => trim(($actor->firstname ?? '') . ' ' . ($actor->lastname ?? '')) ?: $actor->mail,
            'email' => $actor->mail,
            'type' => $actor->type,
            'profile' => optional($actor->Profile)->name,
            'workspace_type' => WorkspaceResolver::type($actor),
            'distributor_id' => $actor->distributor_id,
            'distributor' => optional($actor->Distributor)->name,
        ];
    }

    private function stats(string $workspace, Actor $actor, string $section): array
    {
        $warehouseIds = $this->warehouseIds($workspace, $actor);
        $purchaseBase = $this->purchaseOrdersQuery($workspace, $actor);

        $stockQuery = StockQuantity::query();
        if ($workspace === WorkspaceResolver::LIVREUR && $actor->StockMobile) {
            $stockQuery->where('is_mobile', true)->where('emplacement_id', $actor->StockMobile->id);
        } elseif (!empty($warehouseIds)) {
            $stockQuery->whereIn('emplacement_id', $warehouseIds);
        }

        $ordersCount = (string) $this->ordersQuery($workspace, $actor)->count();
        $stockUnits = (string) (int) (clone $stockQuery)->sum('quantity');
        $deliveriesCount = (string) (clone $purchaseBase)->count();
        $toDeliverCount = (string) (clone $purchaseBase)->whereIn('state', ['new', 'prepared', 'packed', 'taken', 'in_way'])->count();
        $deliveredCount = (string) (clone $purchaseBase)->whereIn('state', ['shipped', 'paid', 'partially_paid'])->count();
        $cashTotal = $this->money((float) $this->transactionsQuery($workspace, $actor)->sum('debit'));

        return match ($workspace) {
            WorkspaceResolver::SUPERADMIN => [
                $this->stat('Distributeurs', (string) $this->distributorsQuery($workspace, $actor)->count(), 'actifs', 'blue', 'business'),
                $this->stat('Acteurs', (string) $this->actorsQuery($workspace, $actor)->count(), 'comptes lies', 'purple', 'users'),
                $this->stat('Commandes', $ordersCount, 'global demo', 'orange', 'orders'),
                $this->stat('Stock total', $stockUnits, 'unites suivies', 'green', 'inventory'),
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
                ['title' => 'Produits disponibles', 'items' => $this->productItems()],
            ],
            'clients' => [
                ['title' => 'Clients affectes', 'items' => $this->clientItems($workspace, $actor)],
            ],
            'orders', 'my_orders' => [
                ['title' => 'Commandes', 'items' => $this->orderItems($workspace, $actor)],
                ['title' => 'Suivi operationnel', 'items' => $this->purchaseOrderItems($workspace, $actor)],
            ],
            'prepare_orders', 'loadings', 'delivery' => [
                ['title' => 'Filtre intelligent', 'items' => $this->deliveryFilterItems($workspace, $actor)],
                ['title' => 'Demandes de livraison', 'items' => $this->purchaseOrderItems($workspace, $actor)],
            ],
            'routes' => [
                ['title' => 'Ordre de passage recommande', 'items' => $this->routeItems($workspace, $actor)],
            ],
            'payments', 'credit' => [
                ['title' => 'Solde et transactions', 'items' => $this->transactionItems($workspace, $actor)],
            ],
            'support' => [
                ['title' => 'Support demo', 'items' => $this->supportItems()],
            ],
            'audit_logs' => [
                ['title' => 'Journal activite', 'items' => $this->auditItems($workspace, $actor)],
            ],
            'profile', 'settings' => [
                ['title' => 'Compte connecte', 'items' => [$this->profileItem($actor)]],
            ],
            default => $this->dashboardLists($workspace, $actor),
        };
    }

    private function dashboardLists(string $workspace, Actor $actor): array
    {
        return match ($workspace) {
            WorkspaceResolver::SUPERADMIN => [
                ['title' => 'Distributeurs a superviser', 'items' => $this->distributorItems($workspace, $actor)],
                ['title' => 'Acteurs recents', 'items' => array_slice($this->actorItems($workspace, $actor), 0, 5)],
                ['title' => 'Journal activite', 'items' => $this->auditItems($workspace, $actor)],
            ],
            WorkspaceResolver::DISTRIBUTEUR => [
                ['title' => 'Commandes recentes', 'items' => $this->orderItems($workspace, $actor)],
                ['title' => 'Depots sous surveillance', 'items' => $this->warehouseItems($workspace, $actor)],
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
                ['title' => 'Catalogue recommande', 'items' => $this->productItems()],
            ],
            default => [
                ['title' => 'Priorites', 'items' => $this->priorityItems($workspace, $actor)],
                ['title' => 'Activite recente', 'items' => $this->orderItems($workspace, $actor)],
            ],
        };
    }

    private function actions(string $workspace, string $section): array
    {
        $actions = [
            ['label' => 'Actualiser', 'kind' => 'refresh', 'enabled' => true],
        ];

        if (in_array($section, ['products', 'catalog'], true)) {
            $actions[] = ['label' => 'Ajouter au panier', 'kind' => 'cart', 'enabled' => true];
        }

        if ($section === 'cart') {
            $actions[] = ['label' => 'Valider la commande demo', 'kind' => 'submit_order', 'enabled' => true];
        }

        if (in_array($section, ['delivery', 'prepare_orders', 'loadings'], true)) {
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

        if (in_array($section, ['distributors', 'actors', 'warehouses', 'clients'], true)) {
            $actions[] = ['label' => 'Creer en mode demo', 'kind' => 'create_demo', 'enabled' => true];
        }

        return $actions;
    }

    private function distributorItems(string $workspace, Actor $actor): array
    {
        return $this->distributorsQuery($workspace, $actor)->limit(20)->get()->map(fn ($item) => [
            'title' => $item->name,
            'subtitle' => 'Code ' . ($item->code ?? $item->id),
            'status' => $item->private ? 'Actif' : 'Public',
            'amount' => '',
            'action' => 'Ouvrir',
            'kind' => 'distributor',
        ])->values()->all();
    }

    private function actorItems(string $workspace, Actor $actor): array
    {
        return $this->actorsQuery($workspace, $actor)->limit(30)->get()->map(fn ($item) => [
            'title' => trim(($item->firstname ?? '') . ' ' . ($item->lastname ?? '')) ?: $item->mail,
            'subtitle' => optional($item->Profile)->name . ' - ' . ($item->phone ?? 'telephone demo'),
            'status' => WorkspaceResolver::type($item),
            'amount' => '',
            'action' => 'Profil',
            'kind' => 'actor',
        ])->values()->all();
    }

    private function warehouseItems(string $workspace, Actor $actor): array
    {
        return $this->warehousesQuery($workspace, $actor)->limit(20)->get()->map(function ($warehouse) {
            $stock = StockQuantity::where('emplacement_id', $warehouse->id)->where('is_mobile', false);

            return [
                'title' => $warehouse->name,
                'subtitle' => trim(optional($warehouse->address)->commune . ' - ' . optional(optional($warehouse->address)->City)->name, ' -') ?: 'Adresse demo',
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
            $name = optional($product)->short_description_fr ?: optional($variant)->variant1_fr ?: 'Produit demo';
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

    private function productItems(): array
    {
        return Product::with(['category', 'allVariants.pricing'])->limit(30)->get()->map(function ($product) {
            $variant = $product->allVariants->first();
            $price = optional(optional($variant)->pricing->first())->price;
            return [
                'title' => $product->short_description_fr ?: 'Produit demo',
                'subtitle' => optional($variant)->variant1_fr ?: optional($product->category)->short_description_fr ?: 'Catalogue',
                'status' => $price ? 'En stock' : 'Prix a verifier',
                'amount' => $price ? $this->money((float) $price) : '',
                'meta' => 'Ref. ' . ($product->ssin ?? $product->id),
                'action' => 'Ajouter',
                'kind' => 'product',
            ];
        })->values()->all();
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
            ['title' => 'Aucune urgence', 'subtitle' => 'Les donnees demo sont pretes', 'status' => 'OK', 'kind' => 'info', 'action' => 'Actualiser'],
        ];
    }

    private function supportItems(): array
    {
        return [
            ['title' => 'Chat support', 'subtitle' => 'Envoyer un message au distributeur', 'status' => 'Demo', 'kind' => 'support', 'action' => 'Envoyer'],
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
        if ($workspace !== WorkspaceResolver::SUPERADMIN && $actor->distributor_id) {
            $query->where('distributor_id', $actor->distributor_id);
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

    private function distributorsQuery(string $workspace, Actor $actor): Builder
    {
        $query = Distributor::query()->with('address');
        if ($workspace !== WorkspaceResolver::SUPERADMIN && $actor->distributor_id) {
            $query->where('id', $actor->distributor_id);
        }

        return $query;
    }

    private function actorsQuery(string $workspace, Actor $actor): Builder
    {
        $query = Actor::query()->with(['Profile', 'Distributor']);
        if ($workspace !== WorkspaceResolver::SUPERADMIN && $actor->distributor_id) {
            $query->where('distributor_id', $actor->distributor_id);
        } elseif ($workspace !== WorkspaceResolver::SUPERADMIN) {
            $query->where('id', $actor->id);
        }

        return $query;
    }

    private function warehousesQuery(string $workspace, Actor $actor): Builder
    {
        $query = Warehouse::query()->with(['address.City']);
        if ($workspace !== WorkspaceResolver::SUPERADMIN && $actor->distributor_id) {
            $query->where('distributor_id', $actor->distributor_id);
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
        } elseif ($workspace !== WorkspaceResolver::SUPERADMIN && $actor->distributor_id) {
            $query->whereHas('Actor', fn ($q) => $q->where('distributor_id', $actor->distributor_id));
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
        } elseif ($workspace !== WorkspaceResolver::SUPERADMIN && $actor->distributor_id) {
            $query->whereHas('PurchaseOrders.warehouse', fn ($q) => $q->where('distributor_id', $actor->distributor_id));
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
            $query->where(function ($q) use ($actor) {
                $q->where('actor_id', $actor->id);
                if ($actor->distributor_id) {
                    $q->orWhereHas('warehouse', fn ($warehouse) => $warehouse->where('distributor_id', $actor->distributor_id));
                }
            });
        } elseif ($workspace !== WorkspaceResolver::SUPERADMIN && $actor->distributor_id) {
            $query->whereHas('warehouse', fn ($q) => $q->where('distributor_id', $actor->distributor_id));
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
        } elseif ($workspace !== WorkspaceResolver::SUPERADMIN && $actor->distributor_id) {
            $query->whereHas('client.Actor', fn ($q) => $q->where('distributor_id', $actor->distributor_id));
        }

        return $query;
    }

    private function warehouseIds(string $workspace, Actor $actor): array
    {
        return $this->warehousesQuery($workspace, $actor)->pluck('id')->all();
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
