<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateOrderitemTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('orderitem', function (Blueprint $table) {
            $table->String("id");
            $table->primary("id");
            $table->String("image");
            $table->String("order_id");
            $table->integer("variant_id");
            $table->String("sku");
            $table->String("product_name");
            $table->String("variant_name_1");
            $table->String("option_1")->nullable();
            $table->String("variant_name_2")->nullable();
            $table->String("option_2")->nullable();
            $table->String("promotion_id")->nullable();
            $table->String("promotionitem_id")->nullable();
            $table->String("unite");
            $table->String("warehouse_id");
            $table->double("quantity");
            $table->double("confirmed_quantity")->nullable();
            $table->double("cancelled_quantity")->nullable();
            $table->integer("package");
            $table->double("discount");
            $table->double("price");
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
        Schema::dropIfExists('orderitem');
    }
}
