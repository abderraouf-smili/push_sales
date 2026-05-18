<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddProductionValidationTables extends Migration
{
    public function up()
    {
        if (!Schema::hasTable('audit_logs')) {
            Schema::create('audit_logs', function (Blueprint $table) {
                $table->bigIncrements('id');
                $table->unsignedBigInteger('user_id')->nullable()->index();
                $table->string('actor_id')->nullable()->index();
                $table->string('distributor_id')->nullable()->index();
                $table->string('workspace_type')->nullable()->index();
                $table->string('action')->index();
                $table->string('entity_type')->nullable()->index();
                $table->string('entity_id')->nullable()->index();
                $table->json('old_values')->nullable();
                $table->json('new_values')->nullable();
                $table->string('ip_address')->nullable();
                $table->text('user_agent')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('client_user_access')) {
            Schema::create('client_user_access', function (Blueprint $table) {
                $table->bigIncrements('id');
                $table->unsignedBigInteger('user_id')->index();
                $table->string('client_id')->index();
                $table->string('distributor_id')->nullable()->index();
                $table->string('access_type')->default('owner');
                $table->boolean('is_primary')->default(false);
                $table->boolean('is_active')->default(true);
                $table->timestamps();

                $table->unique(['user_id', 'client_id'], 'client_user_access_unique');
            });
        }

        if (Schema::hasTable('order')) {
            Schema::table('order', function (Blueprint $table) {
                if (!Schema::hasColumn('order', 'order_source')) {
                    $table->string('order_source')->default('commercial')->index();
                }

                if (!Schema::hasColumn('order', 'payment_due_date')) {
                    $table->date('payment_due_date')->nullable()->index();
                }
            });
        }

        if (Schema::hasTable('client') && !Schema::hasColumn('client', 'credit_limit')) {
            Schema::table('client', function (Blueprint $table) {
                $table->decimal('credit_limit', 16, 2)->nullable();
            });
        }

        if (!Schema::hasTable('delivery_trips')) {
            Schema::create('delivery_trips', function (Blueprint $table) {
                $table->bigIncrements('id');
                $table->string('actor_id')->index();
                $table->string('distributor_id')->nullable()->index();
                $table->date('trip_date')->index();
                $table->string('status')->default('planned')->index();
                $table->json('route_summary')->nullable();
                $table->decimal('total_distance', 10, 2)->nullable();
                $table->integer('estimated_duration')->nullable();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('delivery_trip_stops')) {
            Schema::create('delivery_trip_stops', function (Blueprint $table) {
                $table->bigIncrements('id');
                $table->unsignedBigInteger('delivery_trip_id')->index();
                $table->string('purchase_order_id')->nullable()->index();
                $table->string('order_id')->nullable()->index();
                $table->string('client_id')->index();
                $table->unsignedInteger('sequence')->default(1);
                $table->string('status')->default('planned')->index();
                $table->decimal('latitude', 10, 7)->nullable();
                $table->decimal('longitude', 10, 7)->nullable();
                $table->dateTime('estimated_arrival')->nullable();
                $table->dateTime('actual_arrival')->nullable();
                $table->timestamps();
            });
        }
    }

    public function down()
    {
        if (Schema::hasTable('delivery_trip_stops')) {
            Schema::dropIfExists('delivery_trip_stops');
        }

        if (Schema::hasTable('delivery_trips')) {
            Schema::dropIfExists('delivery_trips');
        }

        if (Schema::hasTable('client') && Schema::hasColumn('client', 'credit_limit')) {
            Schema::table('client', function (Blueprint $table) {
                $table->dropColumn('credit_limit');
            });
        }

        if (Schema::hasTable('order')) {
            Schema::table('order', function (Blueprint $table) {
                if (Schema::hasColumn('order', 'payment_due_date')) {
                    $table->dropColumn('payment_due_date');
                }

                if (Schema::hasColumn('order', 'order_source')) {
                    $table->dropColumn('order_source');
                }
            });
        }

        if (Schema::hasTable('client_user_access')) {
            Schema::dropIfExists('client_user_access');
        }

        if (Schema::hasTable('audit_logs')) {
            Schema::dropIfExists('audit_logs');
        }
    }
}
