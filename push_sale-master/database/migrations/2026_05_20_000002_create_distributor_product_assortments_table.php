<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateDistributorProductAssortmentsTable extends Migration
{
    public function up()
    {
        if (!Schema::hasTable('distributor_product_assortments')) {
            Schema::create('distributor_product_assortments', function (Blueprint $table) {
                $table->id();
                $table->string('distributor_id')->index();
                $table->unsignedBigInteger('product_id')->index();
                $table->unsignedBigInteger('variant_id')->index();
                $table->boolean('is_active')->default(true)->index();
                $table->timestamps();

                $table->unique(['distributor_id', 'variant_id'], 'distributor_variant_assortment_unique');
            });
        }
    }

    public function down()
    {
        Schema::dropIfExists('distributor_product_assortments');
    }
}
