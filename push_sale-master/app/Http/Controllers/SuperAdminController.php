<?php

namespace App\Http\Controllers;

use App\Models\Actor;
use App\Models\ActorProfile;
use App\Models\Address;
use App\Models\AuditLog;
use App\Models\Category;
use App\Models\Distributor;
use App\Models\Order;
use App\Models\Product;
use App\Models\User;
use App\Models\Variant;
use App\Models\Warehouse;
use App\Support\WorkspaceResolver;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;
use Throwable;

class SuperAdminController extends Controller
{
    public function dashboard(Request $request)
    {
        $guard = $this->guard();
        if ($guard) {
            return $guard;
        }

        $distributorActiveColumn = Schema::hasColumn('distributor', 'is_active') ? 'is_active' : null;
        $actorActiveColumn = Schema::hasColumn('actor', 'is_active') ? 'is_active' : null;

        $distributors = Distributor::query();
        $actors = Actor::query();

        return $this->success([
            'stats' => [
                'total_distributors' => (clone $distributors)->count(),
                'active_distributors' => $distributorActiveColumn
                    ? (clone $distributors)->where($distributorActiveColumn, true)->count()
                    : (clone $distributors)->count(),
                'inactive_distributors' => $distributorActiveColumn
                    ? (clone $distributors)->where($distributorActiveColumn, false)->count()
                    : 0,
                'total_actors' => (clone $actors)->count(),
                'active_actors' => $actorActiveColumn
                    ? (clone $actors)->where($actorActiveColumn, true)->count()
                    : (clone $actors)->count(),
                'orders' => Schema::hasTable('order') ? Order::count() : 0,
                'stock_total' => Schema::hasTable('stock_quantity')
                    ? (int) DB::table('stock_quantity')->sum('quantity')
                    : 0,
                'revenue' => Schema::hasTable('transactions')
                    ? (float) DB::table('transactions')->sum('debit')
                    : 0,
            ],
            'alerts' => $this->systemAlerts(),
            'latest_audit_logs' => $this->auditQuery($request)->limit(10)->get(),
        ]);
    }

    public function distributors(Request $request)
    {
        $guard = $this->guard();
        if ($guard) {
            return $guard;
        }

        $query = Distributor::with('Address')->orderBy('name');
        $this->applySearch($query, $request, ['name', 'code', 'email', 'phone', 'contact_name']);
        $this->applyStatus($query, $request, 'distributor');

        return $this->success($query->limit(100)->get()->map(fn ($item) => $this->distributorPayload($item))->values());
    }

    public function createDistributor(Request $request)
    {
        $guard = $this->guard();
        if ($guard) {
            return $guard;
        }

        $data = $request->validate([
            'name' => 'required|string|max:255',
            'code' => 'nullable|string|max:80',
            'phone' => 'nullable|string|max:80',
            'email' => 'nullable|email|max:255',
            'contact_name' => 'nullable|string|max:255',
            'street' => 'nullable|string|max:500',
            'commune' => 'nullable|string|max:255',
            'is_active' => 'nullable|boolean',
        ]);

        return DB::transaction(function () use ($request, $data) {
            $address = $this->createAddress($request);
            $payload = [
                'id' => $this->shortId('DIST'),
                'name' => $data['name'],
                'code' => $data['code'] ?? $this->nextCode('DIST'),
                'private' => true,
                'address_id' => $address->id,
            ];
            $this->addColumnPayload($payload, 'distributor', 'phone', $data['phone'] ?? null);
            $this->addColumnPayload($payload, 'distributor', 'email', $data['email'] ?? null);
            $this->addColumnPayload($payload, 'distributor', 'contact_name', $data['contact_name'] ?? null);
            $this->addColumnPayload($payload, 'distributor', 'is_active', $request->boolean('is_active', true));

            $distributor = Distributor::create($payload);
            $this->audit('create_distributor', 'distributor', $distributor->id, null, $this->safeAudit($distributor));

            return $this->success($this->distributorPayload($distributor->fresh('Address')), 'Distributeur cree.');
        });
    }

    public function distributorDetail($id)
    {
        $guard = $this->guard();
        if ($guard) {
            return $guard;
        }

        $distributor = Distributor::with('Address')->find($id);
        if (!$distributor) {
            return $this->fail('Distributeur introuvable.', 404);
        }

        return $this->success([
            'distributor' => $this->distributorPayload($distributor),
            'stats' => $this->distributorStats($id),
            'actors' => $this->actorsForDistributor($id)->limit(20)->get()->map(fn ($actor) => $this->actorPayload($actor))->values(),
            'warehouses' => $this->warehousesForDistributor($id)->limit(20)->get(),
            'products' => $this->productsForDistributor($id)->limit(20)->get()->map(fn ($product) => $this->productPayload($product))->values(),
            'orders' => $this->ordersForDistributor($id)->limit(20)->get(),
        ]);
    }

    public function updateDistributor(Request $request, $id)
    {
        $guard = $this->guard();
        if ($guard) {
            return $guard;
        }

        $distributor = Distributor::find($id);
        if (!$distributor) {
            return $this->fail('Distributeur introuvable.', 404);
        }

        $data = $request->validate([
            'name' => 'nullable|string|max:255',
            'code' => 'nullable|string|max:80',
            'phone' => 'nullable|string|max:80',
            'email' => 'nullable|email|max:255',
            'contact_name' => 'nullable|string|max:255',
            'street' => 'nullable|string|max:500',
            'commune' => 'nullable|string|max:255',
            'is_active' => 'nullable|boolean',
        ]);

        return DB::transaction(function () use ($request, $distributor, $data) {
            $old = $this->safeAudit($distributor);
            $payload = [];
            foreach (['name', 'code', 'phone', 'email', 'contact_name'] as $field) {
                if (array_key_exists($field, $data) && Schema::hasColumn('distributor', $field)) {
                    $payload[$field] = $data[$field];
                }
            }
            if ($request->has('is_active') && Schema::hasColumn('distributor', 'is_active')) {
                $payload['is_active'] = $request->boolean('is_active');
            }
            if (!empty($payload)) {
                $distributor->update($payload);
            }
            if ($distributor->address_id) {
                $this->updateAddress($distributor->address_id, $request);
            }

            $this->audit('update_distributor', 'distributor', $distributor->id, $old, $this->safeAudit($distributor->fresh()));

            return $this->success($this->distributorPayload($distributor->fresh('Address')), 'Distributeur modifie.');
        });
    }

    public function activateDistributor($id)
    {
        return $this->setDistributorStatus($id, true);
    }

    public function deactivateDistributor($id)
    {
        return $this->setDistributorStatus($id, false);
    }

    public function distributorActors($id)
    {
        return $this->guardedList(fn () => $this->actorsForDistributor($id)->limit(100)->get()->map(fn ($actor) => $this->actorPayload($actor))->values());
    }

    public function distributorWarehouses($id)
    {
        return $this->guardedList(fn () => $this->warehousesForDistributor($id)->limit(100)->get());
    }

    public function distributorProducts($id)
    {
        return $this->guardedList(fn () => $this->productsForDistributor($id)->limit(100)->get()->map(fn ($product) => $this->productPayload($product))->values());
    }

    public function distributorOrders($id)
    {
        return $this->guardedList(fn () => $this->ordersForDistributor($id)->limit(100)->get());
    }

    public function distributorStatsEndpoint($id)
    {
        return $this->guardedList(fn () => $this->distributorStats($id));
    }

    public function actors(Request $request)
    {
        $guard = $this->guard();
        if ($guard) {
            return $guard;
        }

        $query = Actor::with(['Profile', 'Distributor', 'User'])->orderBy('firstname');
        $this->applySearch($query, $request, ['firstname', 'lastname', 'mail', 'phone', 'type']);
        $this->applyStatus($query, $request, 'actor');

        if ($request->filled('workspace_type')) {
            $workspace = $request->input('workspace_type');
            $query->whereHas('Profile', fn ($profile) => $profile->where('workspace_type', $workspace));
        }
        if ($request->filled('distributor_id')) {
            $distributorId = $request->input('distributor_id');
            $query->where(function ($actorQuery) use ($distributorId) {
                $actorQuery->where('distributor_id', $distributorId);
                if (Schema::hasColumn('actor', 'id_distributor')) {
                    $actorQuery->orWhere('id_distributor', $distributorId);
                }
            });
        }

        return $this->success($query->limit(150)->get()->map(fn ($actor) => $this->actorPayload($actor))->values());
    }

    public function createActor(Request $request)
    {
        $guard = $this->guard();
        if ($guard) {
            return $guard;
        }

        $data = $request->validate([
            'firstname' => 'nullable|string|max:120',
            'lastname' => 'nullable|string|max:120',
            'name' => 'nullable|string|max:240',
            'email' => 'required|email|max:255',
            'phone' => 'nullable|string|max:80',
            'workspace_type' => 'required|string|max:40',
            'distributor_id' => 'nullable|string',
            'password' => 'nullable|string|min:8',
            'is_active' => 'nullable|boolean',
            'email_verified' => 'nullable|boolean',
        ]);

        if (empty($data['firstname'])) {
            $parts = preg_split('/\s+/', trim($data['name'] ?? ''), 2);
            $data['firstname'] = $parts[0] ?? strtok($data['email'], '@');
            $data['lastname'] = $data['lastname'] ?? ($parts[1] ?? '');
        }

        if ($data['workspace_type'] !== WorkspaceResolver::SUPERADMIN && empty($data['distributor_id'])) {
            return $this->fail('Un acteur non SuperAdmin doit etre lie a un distributeur.');
        }

        return DB::transaction(function () use ($request, $data) {
            $profile = $this->profileForWorkspace($data['workspace_type']);
            $user = User::updateOrCreate(
                ['email' => $data['email']],
                [
                    'name' => trim($data['firstname'] . ' ' . ($data['lastname'] ?? '')),
                    'device_id' => 'superadmin-created',
                    'fcmtoken' => 'superadmin-created',
                    'fbuid' => 'superadmin-created',
                    'provider' => 'email',
                    'password' => Hash::make($data['password'] ?? 'Test@123456'),
                    'email_verified_at' => $request->boolean('email_verified', true) ? now() : null,
                ]
            );

            $actor = Actor::updateOrCreate(
                ['mail' => $data['email']],
                [
                    'id' => Actor::where('mail', $data['email'])->value('id') ?: (string) Str::uuid(),
                    'type' => $data['workspace_type'] === WorkspaceResolver::SUPERADMIN ? 'superadmin' : 'user',
                    'firstname' => $data['firstname'],
                    'lastname' => $data['lastname'] ?? '',
                    'phone' => $data['phone'] ?? null,
                    'user_id' => $user->id,
                    'profile_id' => $profile->id,
                    'distributor_id' => $data['workspace_type'] === WorkspaceResolver::SUPERADMIN ? null : $data['distributor_id'],
                    'rate' => 0,
                    'is_active' => Schema::hasColumn('actor', 'is_active') ? $request->boolean('is_active', true) : null,
                ]
            );

            $this->audit('create_actor', 'actor', $actor->id, null, $this->safeAudit($actor), $actor->distributor_id);

            return $this->success($this->actorPayload($actor->fresh(['Profile', 'Distributor', 'User'])), 'Acteur cree.');
        });
    }

    public function actorDetail($id)
    {
        return $this->guardedList(function () use ($id) {
            $actor = Actor::with(['Profile', 'Distributor', 'User'])->find($id);
            if (!$actor) {
                return null;
            }

            return $this->actorPayload($actor);
        }, 'Acteur introuvable.');
    }

    public function updateActor(Request $request, $id)
    {
        $guard = $this->guard();
        if ($guard) {
            return $guard;
        }

        $actor = Actor::with('User')->find($id);
        if (!$actor) {
            return $this->fail('Acteur introuvable.', 404);
        }

        $data = $request->validate([
            'firstname' => 'nullable|string|max:120',
            'lastname' => 'nullable|string|max:120',
            'email' => 'nullable|email|max:255',
            'phone' => 'nullable|string|max:80',
            'workspace_type' => 'nullable|string|max:40',
            'distributor_id' => 'nullable|string',
            'is_active' => 'nullable|boolean',
            'email_verified' => 'nullable|boolean',
        ]);

        return DB::transaction(function () use ($request, $actor, $data) {
            $old = $this->safeAudit($actor);
            $payload = [];
            foreach (['firstname', 'lastname', 'phone', 'distributor_id'] as $field) {
                if (array_key_exists($field, $data)) {
                    $payload[$field] = $data[$field];
                }
            }
            if (!empty($data['email'])) {
                $payload['mail'] = $data['email'];
                if ($actor->User) {
                    $actor->User->update(['email' => $data['email'], 'name' => trim(($data['firstname'] ?? $actor->firstname) . ' ' . ($data['lastname'] ?? $actor->lastname))]);
                }
            }
            if (!empty($data['workspace_type'])) {
                $payload['profile_id'] = $this->profileForWorkspace($data['workspace_type'])->id;
                $payload['type'] = $data['workspace_type'] === WorkspaceResolver::SUPERADMIN ? 'superadmin' : 'user';
                if ($data['workspace_type'] === WorkspaceResolver::SUPERADMIN) {
                    $payload['distributor_id'] = null;
                }
            }
            $targetWorkspace = $data['workspace_type'] ?? WorkspaceResolver::type($actor);
            $targetDistributor = array_key_exists('distributor_id', $data)
                ? $data['distributor_id']
                : ($payload['distributor_id'] ?? $actor->distributor_id);
            if ($targetWorkspace !== WorkspaceResolver::SUPERADMIN && empty($targetDistributor)) {
                return $this->fail('Un acteur non SuperAdmin doit etre lie a un distributeur.');
            }
            if ($request->has('is_active') && Schema::hasColumn('actor', 'is_active')) {
                $payload['is_active'] = $request->boolean('is_active');
            }
            if ($actor->User && $request->has('email_verified')) {
                $actor->User->update(['email_verified_at' => $request->boolean('email_verified') ? now() : null]);
            }

            $actor->update($payload);
            $this->audit('update_actor', 'actor', $actor->id, $old, $this->safeAudit($actor->fresh()), $actor->distributor_id);

            return $this->success($this->actorPayload($actor->fresh(['Profile', 'Distributor', 'User'])), 'Acteur modifie.');
        });
    }

    public function activateActor($id)
    {
        return $this->setActorStatus($id, true);
    }

    public function deactivateActor($id)
    {
        return $this->setActorStatus($id, false);
    }

    public function resetActorPassword(Request $request, $id)
    {
        $guard = $this->guard();
        if ($guard) {
            return $guard;
        }

        $actor = Actor::with('User')->find($id);
        if (!$actor || !$actor->User) {
            return $this->fail('Acteur ou compte utilisateur introuvable.', 404);
        }

        $password = $request->input('password', 'Test@123456');
        $actor->User->update([
            'password' => Hash::make($password),
            'email_verified_at' => $actor->User->email_verified_at ?: now(),
        ]);
        $this->audit('reset_actor_password', 'actor', $actor->id, null, ['mail' => $actor->mail], $actor->distributor_id);

        return $this->success([
            'actor' => $this->actorPayload($actor->fresh(['Profile', 'Distributor', 'User'])),
            'temporary_password' => app()->environment('production') ? null : $password,
        ], 'Mot de passe reinitialise.');
    }

    public function workspaces()
    {
        return $this->guardedList(fn () => [
            WorkspaceResolver::SUPERADMIN,
            WorkspaceResolver::DISTRIBUTEUR,
            WorkspaceResolver::COMMERCIAL,
            WorkspaceResolver::DEPOT,
            WorkspaceResolver::LIVREUR,
            WorkspaceResolver::POINT_VENTE,
        ]);
    }

    public function actorProfiles()
    {
        return $this->guardedList(fn () => ActorProfile::orderBy('name')->get());
    }

    public function products(Request $request)
    {
        $guard = $this->guard();
        if ($guard) {
            return $guard;
        }

        $query = Product::with(['category', 'Distributor', 'allVariants'])->orderBy('short_description_fr');
        $this->applySearch($query, $request, ['ssin', 'short_description_fr', 'long_description_fr']);
        $this->applyStatus($query, $request, 'product');
        if ($request->filled('category_id')) {
            $query->where('category_id', $request->input('category_id'));
        }
        if ($request->filled('distributor_id') && Schema::hasColumn('product', 'distributor_id')) {
            $query->where('distributor_id', $request->input('distributor_id'));
        }

        return $this->success($query->limit(150)->get()->map(fn ($product) => $this->productPayload($product))->values());
    }

    public function createProduct(Request $request)
    {
        $guard = $this->guard();
        if ($guard) {
            return $guard;
        }

        $data = $request->validate([
            'name' => 'required|string|max:255',
            'ssin' => 'nullable|string|max:120',
            'category_id' => 'nullable|integer',
            'rate' => 'nullable|integer',
            'image' => 'nullable|string|max:500',
            'distributor_id' => 'nullable|string',
            'is_active' => 'nullable|boolean',
        ]);

        $payload = $this->productWritePayload($request, $data);
        $product = Product::create($payload);
        $this->audit('create_product', 'product', $product->id, null, $this->safeAudit($product), $product->distributor_id ?? null);

        return $this->success($this->productPayload($product->fresh(['category', 'Distributor', 'allVariants'])), 'Produit cree.');
    }

    public function productDetail($id)
    {
        return $this->guardedList(function () use ($id) {
            $product = Product::with(['category', 'Distributor', 'allVariants.pricing', 'allVariants.promotion'])->find($id);
            if (!$product) {
                return null;
            }

            return [
                'product' => $this->productPayload($product),
                'variants' => $product->allVariants,
            ];
        }, 'Produit introuvable.');
    }

    public function updateProduct(Request $request, $id)
    {
        $guard = $this->guard();
        if ($guard) {
            return $guard;
        }

        $product = Product::find($id);
        if (!$product) {
            return $this->fail('Produit introuvable.', 404);
        }

        $data = $request->validate([
            'name' => 'nullable|string|max:255',
            'ssin' => 'nullable|string|max:120',
            'category_id' => 'nullable|integer',
            'rate' => 'nullable|integer',
            'image' => 'nullable|string|max:500',
            'distributor_id' => 'nullable|string',
            'is_active' => 'nullable|boolean',
        ]);

        $old = $this->safeAudit($product);
        $product->update($this->productWritePayload($request, $data, false));
        $this->audit('update_product', 'product', $product->id, $old, $this->safeAudit($product->fresh()), $product->distributor_id ?? null);

        return $this->success($this->productPayload($product->fresh(['category', 'Distributor', 'allVariants'])), 'Produit modifie.');
    }

    public function productVariants($id)
    {
        return $this->guardedList(fn () => Variant::where('product_id', $id)->orderBy('variant1_fr')->get());
    }

    public function createVariant(Request $request, $id)
    {
        $guard = $this->guard();
        if ($guard) {
            return $guard;
        }

        if (!Product::whereKey($id)->exists()) {
            return $this->fail('Produit introuvable.', 404);
        }

        $variant = Variant::create([
            'barcode' => $request->input('barcode', $this->nextCode('BAR')),
            'image' => $request->input('image', 'demo.png'),
            'package' => (int) $request->input('package', 1),
            'option1_fr' => $request->input('option1_fr', 'Conditionnement'),
            'variant1_fr' => $request->input('variant1_fr', $request->input('name', 'Unite')),
            'option1_ar' => $request->input('option1_ar'),
            'variant1_ar' => $request->input('variant1_ar'),
            'product_id' => $id,
        ]);
        $this->audit('create_variant', 'variant', $variant->id, null, $this->safeAudit($variant));

        return $this->success($variant, 'Variant cree.');
    }

    public function updateVariant(Request $request, $id)
    {
        $guard = $this->guard();
        if ($guard) {
            return $guard;
        }

        $variant = Variant::find($id);
        if (!$variant) {
            return $this->fail('Variant introuvable.', 404);
        }
        $old = $this->safeAudit($variant);
        $variant->update($request->only([
            'barcode',
            'image',
            'package',
            'option1_ar',
            'option1_fr',
            'variant1_ar',
            'variant1_fr',
            'option2_ar',
            'option2_fr',
            'variant2_ar',
            'variant2_fr',
        ]));
        $this->audit('update_variant', 'variant', $variant->id, $old, $this->safeAudit($variant));

        return $this->success($variant, 'Variant modifie.');
    }

    public function categories()
    {
        return $this->guardedList(fn () => Category::orderBy('short_description_fr')->get());
    }

    public function createCategory(Request $request)
    {
        $guard = $this->guard();
        if ($guard) {
            return $guard;
        }

        $name = $request->input('name', $request->input('short_description_fr', 'Categorie'));
        $category = Category::create([
            'code' => $request->input('code', $this->nextCode('CAT')),
            'image' => $request->input('image', 'demo.png'),
            'short_description_ar' => $request->input('short_description_ar', $name),
            'long_description_ar' => $request->input('long_description_ar', $name),
            'short_description_fr' => $name,
            'long_description_fr' => $request->input('long_description_fr', $name),
        ]);
        $this->audit('create_category', 'category', $category->id, null, $this->safeAudit($category));

        return $this->success($category, 'Categorie creee.');
    }

    public function auditLogs(Request $request)
    {
        $guard = $this->guard();
        if ($guard) {
            return $guard;
        }

        $query = $this->auditQuery($request);
        return $this->success($query->limit(200)->get());
    }

    private function setDistributorStatus($id, bool $active)
    {
        $guard = $this->guard();
        if ($guard) {
            return $guard;
        }

        $distributor = Distributor::find($id);
        if (!$distributor) {
            return $this->fail('Distributeur introuvable.', 404);
        }
        $old = $this->safeAudit($distributor);
        if (Schema::hasColumn('distributor', 'is_active')) {
            $distributor->update(['is_active' => $active]);
        } else {
            $distributor->update(['private' => $active]);
        }
        $this->audit($active ? 'activate_distributor' : 'deactivate_distributor', 'distributor', $id, $old, $this->safeAudit($distributor->fresh()));

        return $this->success($this->distributorPayload($distributor->fresh('Address')), $active ? 'Distributeur active.' : 'Distributeur desactive.');
    }

    private function setActorStatus($id, bool $active)
    {
        $guard = $this->guard();
        if ($guard) {
            return $guard;
        }

        $actor = Actor::find($id);
        if (!$actor) {
            return $this->fail('Acteur introuvable.', 404);
        }
        $old = $this->safeAudit($actor);
        if (Schema::hasColumn('actor', 'is_active')) {
            $actor->update(['is_active' => $active]);
        }
        $this->audit($active ? 'activate_actor' : 'deactivate_actor', 'actor', $id, $old, $this->safeAudit($actor->fresh()), $actor->distributor_id);

        return $this->success($this->actorPayload($actor->fresh(['Profile', 'Distributor', 'User'])), $active ? 'Acteur active.' : 'Acteur desactive.');
    }

    private function guard()
    {
        $actor = $this->currentActor();
        if (!$actor || WorkspaceResolver::type($actor) !== WorkspaceResolver::SUPERADMIN) {
            return $this->fail('Acces SuperAdmin requis.', 403);
        }

        return null;
    }

    private function currentActor(): ?Actor
    {
        $user = Auth::user();
        if (!$user) {
            return null;
        }

        return Actor::with(['Profile', 'Distributor'])->where('user_id', $user->id)->first();
    }

    private function guardedList(callable $callback, string $notFound = 'Donnee introuvable.')
    {
        $guard = $this->guard();
        if ($guard) {
            return $guard;
        }

        $value = $callback();
        if ($value === null) {
            return $this->fail($notFound, 404);
        }

        return $this->success($value);
    }

    private function distributorPayload(Distributor $item): array
    {
        $address = $item->Address;
        $addressLabel = collect([
            optional($address)->street,
            optional($address)->commune,
        ])->filter()->implode(', ');

        return [
            'id' => $item->id,
            'name' => $item->name,
            'code' => $item->code,
            'phone' => $item->phone ?? '',
            'email' => $item->email ?? '',
            'contact_name' => $item->contact_name ?? '',
            'is_active' => Schema::hasColumn('distributor', 'is_active') ? (bool) $item->is_active : (bool) $item->private,
            'status' => (Schema::hasColumn('distributor', 'is_active') ? $item->is_active : $item->private) ? 'Actif' : 'Inactif',
            'address' => [
                'id' => $item->address_id,
                'street' => optional($address)->street,
                'commune' => optional($address)->commune,
            ],
            'address_label' => $addressLabel ?: 'Adresse non renseignee',
            'stats' => $this->distributorStats($item->id),
        ];
    }

    private function actorPayload(Actor $actor): array
    {
        return [
            'id' => $actor->id,
            'firstname' => $actor->firstname,
            'lastname' => $actor->lastname,
            'name' => trim(($actor->firstname ?? '') . ' ' . ($actor->lastname ?? '')) ?: $actor->mail,
            'email' => $actor->mail,
            'phone' => $actor->phone,
            'workspace_type' => WorkspaceResolver::type($actor),
            'profile' => optional($actor->Profile)->name,
            'profile_id' => $actor->profile_id,
            'distributor_id' => $actor->distributor_id,
            'distributor' => optional($actor->Distributor)->name,
            'is_active' => Schema::hasColumn('actor', 'is_active') ? (bool) $actor->is_active : true,
            'status' => (Schema::hasColumn('actor', 'is_active') ? $actor->is_active : true) ? 'Actif' : 'Inactif',
            'email_verified' => $actor->User ? (bool) $actor->User->email_verified_at : false,
            'email_verified_at' => optional(optional($actor->User)->email_verified_at)->toDateTimeString(),
            'user_id' => optional($actor->User)->id,
            'created_at' => optional($actor->created_at)->toDateTimeString(),
            'last_access' => null,
        ];
    }

    private function productPayload(Product $product): array
    {
        $variant = $product->allVariants->first();
        return [
            'id' => $product->id,
            'name' => $product->short_description_fr,
            'ssin' => $product->ssin,
            'rate' => $product->rate,
            'category_id' => $product->category_id,
            'category' => optional($product->category)->short_description_fr,
            'category_label' => optional($product->category)->short_description_fr,
            'distributor_id' => $product->distributor_id ?? null,
            'distributor_label' => optional($product->Distributor)->name,
            'distributor_code' => optional($product->Distributor)->code,
            'is_active' => Schema::hasColumn('product', 'is_active') ? (bool) $product->is_active : true,
            'status' => (Schema::hasColumn('product', 'is_active') ? $product->is_active : true) ? 'Actif' : 'Inactif',
            'variant_count' => $product->allVariants->count(),
            'sample_variant' => optional($variant)->variant1_fr,
            'image' => $product->image,
        ];
    }

    private function distributorStats(string $id): array
    {
        return [
            'actors' => $this->actorsForDistributor($id)->count(),
            'warehouses' => $this->warehousesForDistributor($id)->count(),
            'products' => $this->productsForDistributor($id)->count(),
            'orders' => $this->ordersForDistributor($id)->count(),
        ];
    }

    private function actorsForDistributor(string $id)
    {
        $query = Actor::with(['Profile', 'Distributor', 'User'])->orderBy('firstname');

        return $query->where(function ($q) use ($id) {
            $q->where('distributor_id', $id);
            if (Schema::hasColumn('actor', 'id_distributor')) {
                $q->orWhere('id_distributor', $id);
            }
        });
    }

    private function warehousesForDistributor(string $id)
    {
        return Warehouse::with('address')->where('distributor_id', $id)->orderBy('name');
    }

    private function productsForDistributor(string $id)
    {
        $query = Product::with(['category', 'Distributor', 'allVariants'])->orderBy('short_description_fr');
        if (Schema::hasColumn('product', 'distributor_id')) {
            $query->where(function ($q) use ($id) {
                $q->where('distributor_id', $id)->orWhereNull('distributor_id');
            });
        }

        return $query;
    }

    private function ordersForDistributor(string $id)
    {
        return Order::with('client')
            ->whereHas('PurchaseOrders.warehouse', fn ($warehouse) => $warehouse->where('distributor_id', $id))
            ->orderByDesc('order_date');
    }

    private function profileForWorkspace(string $workspace): ActorProfile
    {
        $profile = ActorProfile::where('workspace_type', $workspace)->first();
        if ($profile) {
            return $profile;
        }

        $code = strtoupper(str_replace('_', '-', $workspace));
        return ActorProfile::firstOrCreate(
            ['code' => $code],
            [
                'name' => ucfirst(str_replace('_', ' ', $workspace)),
                'name_ar' => $workspace,
                'workspace_type' => $workspace,
                'has_stock_mobile' => $workspace === WorkspaceResolver::LIVREUR,
                'add_client' => $workspace === WorkspaceResolver::COMMERCIAL,
            ]
        );
    }

    private function productWritePayload(Request $request, array $data, bool $creating = true): array
    {
        $name = $data['name'] ?? null;
        $payload = [];
        if ($creating || array_key_exists('ssin', $data)) {
            $payload['ssin'] = $data['ssin'] ?? $this->nextCode('PROD');
        }
        if ($creating || array_key_exists('rate', $data)) {
            $payload['rate'] = (int) ($data['rate'] ?? 0);
        }
        if ($creating || $name !== null) {
            $payload['short_description_ar'] = $request->input('short_description_ar', $name ?? $request->input('short_description_fr', 'Produit'));
            $payload['long_description_ar'] = $request->input('long_description_ar', $payload['short_description_ar']);
            $payload['short_description_fr'] = $request->input('short_description_fr', $name ?? 'Produit');
            $payload['long_description_fr'] = $request->input('long_description_fr', $payload['short_description_fr']);
        }
        if ($creating || array_key_exists('image', $data)) {
            $payload['image'] = $data['image'] ?? 'demo.png';
        }
        if ($creating || array_key_exists('category_id', $data)) {
            $payload['category_id'] = $data['category_id'] ?? $this->defaultCategoryId();
        }
        if (Schema::hasColumn('product', 'distributor_id') && ($creating || array_key_exists('distributor_id', $data))) {
            $payload['distributor_id'] = $data['distributor_id'] ?? null;
        }
        if (Schema::hasColumn('product', 'is_active') && ($creating || $request->has('is_active'))) {
            $payload['is_active'] = $request->boolean('is_active', true);
        }

        return $payload;
    }

    private function defaultCategoryId(): int
    {
        return Category::query()->value('id') ?: Category::create([
            'code' => $this->nextCode('CAT'),
            'image' => 'demo.png',
            'short_description_ar' => 'Demo',
            'long_description_ar' => 'Demo',
            'short_description_fr' => 'Demo',
            'long_description_fr' => 'Demo',
        ])->id;
    }

    private function createAddress(Request $request): Address
    {
        return Address::create([
            'id' => (string) Str::uuid(),
            'street' => $request->input('street', $request->input('address', 'Adresse non renseignee')),
            'commune' => $request->input('commune', $request->input('city', 'Alger')),
            'zipcode' => $request->input('zipcode'),
            'latitude' => $request->input('latitude'),
            'longitude' => $request->input('longitude'),
            'city_id' => (int) $request->input('city_id', 1),
            'state_id' => (int) $request->input('state_id', 1),
            'country_id' => (int) $request->input('country_id', 1),
        ]);
    }

    private function updateAddress(string $id, Request $request): void
    {
        $payload = [];
        foreach (['street', 'commune', 'zipcode', 'latitude', 'longitude'] as $field) {
            if ($request->has($field)) {
                $payload[$field] = $request->input($field);
            }
        }
        if (!empty($payload)) {
            Address::where('id', $id)->update($payload);
        }
    }

    private function applySearch($query, Request $request, array $columns): void
    {
        $search = trim((string) $request->input('search', ''));
        if ($search === '') {
            return;
        }

        $query->where(function ($q) use ($columns, $search, $query) {
            foreach ($columns as $column) {
                $table = $query->getModel()->getTable();
                if (Schema::hasColumn($table, $column)) {
                    $q->orWhere($column, 'like', '%' . $search . '%');
                }
            }
        });
    }

    private function applyStatus($query, Request $request, string $table): void
    {
        $status = strtolower((string) $request->input('status', 'all'));
        if ($status === 'all' || !Schema::hasColumn($table, 'is_active')) {
            return;
        }

        if (in_array($status, ['active', 'actif', '1'], true)) {
            $query->where('is_active', true);
        }
        if (in_array($status, ['inactive', 'inactif', '0'], true)) {
            $query->where('is_active', false);
        }
    }

    private function auditQuery(Request $request)
    {
        $query = AuditLog::query()->orderByDesc('created_at');
        foreach (['user_id', 'actor_id', 'distributor_id', 'action', 'entity_type', 'workspace_type'] as $field) {
            if ($request->filled($field)) {
                $query->where($field, $request->input($field));
            }
        }
        if ($request->filled('date_from')) {
            $query->whereDate('created_at', '>=', $request->input('date_from'));
        }
        if ($request->filled('date_to')) {
            $query->whereDate('created_at', '<=', $request->input('date_to'));
        }

        return $query;
    }

    private function audit(string $action, string $entityType, $entityId = null, $old = null, $new = null, $distributorId = null): void
    {
        if (!Schema::hasTable('audit_logs')) {
            return;
        }

        $actor = $this->currentActor();
        AuditLog::create([
            'user_id' => optional(Auth::user())->id,
            'actor_id' => optional($actor)->id,
            'distributor_id' => $distributorId,
            'workspace_type' => WorkspaceResolver::SUPERADMIN,
            'action' => $action,
            'entity_type' => $entityType,
            'entity_id' => $entityId,
            'old_values' => $old,
            'new_values' => $new,
            'ip_address' => request()->ip(),
            'user_agent' => substr((string) request()->userAgent(), 0, 500),
        ]);
    }

    private function addColumnPayload(array &$payload, string $table, string $column, $value): void
    {
        if (Schema::hasColumn($table, $column)) {
            $payload[$column] = $value;
        }
    }

    private function safeAudit($model): array
    {
        return collect($model->toArray())
            ->except(['password', 'remember_token', 'fcmtoken'])
            ->all();
    }

    private function systemAlerts(): array
    {
        $alerts = [];
        if (!Schema::hasTable('audit_logs')) {
            $alerts[] = 'Audit logs non initialises';
        }
        if (!Schema::hasColumn('actor_profile', 'workspace_type')) {
            $alerts[] = 'workspace_type manquant dans actor_profile';
        }
        if (empty($alerts)) {
            $alerts[] = 'Systeme operationnel';
        }

        return $alerts;
    }

    private function nextCode(string $prefix): string
    {
        return $prefix . '-' . strtoupper(Str::random(6));
    }

    private function shortId(string $prefix): string
    {
        return substr($prefix . '-' . strtoupper(Str::random(14)), 0, 20);
    }

    private function success($data = null, string $message = 'OK')
    {
        return response()->json([
            'status' => 'SUCCESS',
            'message' => $message,
            'data' => $data,
        ]);
    }

    private function fail(string $message, int $statusCode = 422)
    {
        return response()->json([
            'status' => 'FAIL',
            'message' => $message,
        ], $statusCode);
    }
}
