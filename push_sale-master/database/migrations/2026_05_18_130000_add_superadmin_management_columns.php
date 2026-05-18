<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddSuperadminManagementColumns extends Migration
{
    public function up()
    {
        if (Schema::hasTable('distributor')) {
            Schema::table('distributor', function (Blueprint $table) {
                if (!Schema::hasColumn('distributor', 'is_active')) {
                    $table->boolean('is_active')->default(true)->after('private')->index();
                }
                if (!Schema::hasColumn('distributor', 'phone')) {
                    $table->string('phone')->nullable()->after('name');
                }
                if (!Schema::hasColumn('distributor', 'email')) {
                    $table->string('email')->nullable()->after('phone');
                }
                if (!Schema::hasColumn('distributor', 'contact_name')) {
                    $table->string('contact_name')->nullable()->after('email');
                }
            });
        }

        if (Schema::hasTable('actor')) {
            Schema::table('actor', function (Blueprint $table) {
                if (!Schema::hasColumn('actor', 'is_active')) {
                    $table->boolean('is_active')->default(true)->after('rate')->index();
                }
            });
        }

        if (Schema::hasTable('product')) {
            Schema::table('product', function (Blueprint $table) {
                if (!Schema::hasColumn('product', 'distributor_id')) {
                    $table->string('distributor_id')->nullable()->after('category_id')->index();
                }
                if (!Schema::hasColumn('product', 'is_active')) {
                    $table->boolean('is_active')->default(true)->after('distributor_id')->index();
                }
            });
        }
    }

    public function down()
    {
        if (Schema::hasTable('product')) {
            Schema::table('product', function (Blueprint $table) {
                foreach (['is_active', 'distributor_id'] as $column) {
                    if (Schema::hasColumn('product', $column)) {
                        $table->dropColumn($column);
                    }
                }
            });
        }

        if (Schema::hasTable('actor') && Schema::hasColumn('actor', 'is_active')) {
            Schema::table('actor', function (Blueprint $table) {
                $table->dropColumn('is_active');
            });
        }

        if (Schema::hasTable('distributor')) {
            Schema::table('distributor', function (Blueprint $table) {
                foreach (['contact_name', 'email', 'phone', 'is_active'] as $column) {
                    if (Schema::hasColumn('distributor', $column)) {
                        $table->dropColumn($column);
                    }
                }
            });
        }
    }
}
