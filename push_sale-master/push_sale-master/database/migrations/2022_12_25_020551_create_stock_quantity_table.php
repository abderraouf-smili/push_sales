<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateStockQuantityTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('stock_quantity', function (Blueprint $table) {
            $table->id();
            $table->string("emplacement_id");
            $table->boolean("is_mobile")->default(1);
            $table->integer("variant_id");
            $table->double("quantity");
            $table->double("previsionnel");
            $table->double("stock_price");
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('stock_quantity');
    }
}
