<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateStockOperationItemsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('stock_operation_items', function (Blueprint $table) {
            $table->String("id");
            $table->primary("id");
            $table->String("operation_id");
            $table->integer("variant_id");
            $table->String("image");
            $table->String("product_name");
            $table->String("variant_1");
            $table->String("variant_2");
            $table->double("quantity");
            $table->integer("package");
            $table->double("saleprice");
            $table->double("stockprice");
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
        Schema::dropIfExists('stock_operation_items');
    }
}
