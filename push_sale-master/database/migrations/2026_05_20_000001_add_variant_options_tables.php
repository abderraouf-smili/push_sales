<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddVariantOptionsTables extends Migration
{
    public function up()
    {
        if (!Schema::hasTable('variant_options')) {
            Schema::create('variant_options', function (Blueprint $table) {
                $table->bigIncrements('id');
                $table->string('key', 80)->unique();
                $table->string('label', 120);
                $table->unsignedInteger('sort_order')->default(0)->index();
                $table->boolean('is_active')->default(true)->index();
                $table->timestamps();
            });
        }

        if (!Schema::hasTable('variant_option_values')) {
            Schema::create('variant_option_values', function (Blueprint $table) {
                $table->bigIncrements('id');
                $table->unsignedBigInteger('option_id')->index();
                $table->string('value', 160);
                $table->string('normalized_value', 160)->index();
                $table->boolean('is_active')->default(true)->index();
                $table->timestamps();

                $table->unique(['option_id', 'normalized_value'], 'variant_option_values_unique');
            });
        }

        if (!Schema::hasTable('variant_option_assignments')) {
            Schema::create('variant_option_assignments', function (Blueprint $table) {
                $table->bigIncrements('id');
                $table->unsignedBigInteger('variant_id')->index();
                $table->unsignedBigInteger('option_id')->index();
                $table->unsignedBigInteger('option_value_id')->index();
                $table->timestamps();

                $table->unique(['variant_id', 'option_id'], 'variant_option_assignments_unique');
            });
        }

        if (Schema::hasTable('variant') && !Schema::hasColumn('variant', 'option_signature')) {
            Schema::table('variant', function (Blueprint $table) {
                $table->string('option_signature', 700)->nullable()->after('product_id');
            });
        }
    }

    public function down()
    {
        if (Schema::hasTable('variant') && Schema::hasColumn('variant', 'option_signature')) {
            Schema::table('variant', function (Blueprint $table) {
                $table->dropColumn('option_signature');
            });
        }

        Schema::dropIfExists('variant_option_assignments');
        Schema::dropIfExists('variant_option_values');
        Schema::dropIfExists('variant_options');
    }
}
