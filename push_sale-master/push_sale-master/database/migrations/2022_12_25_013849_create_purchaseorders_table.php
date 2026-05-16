<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreatePurchaseordersTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('purchase_order', function (Blueprint $table) {
            $table->String("id");
            $table->primary("id");
            $table->String("code");
            $table->String("order_id")->nullable();
            $table->String("actor_id")->nullable(); // Livreur
            $table->String("client_id")->nullable(); // Livreur
            $table->String("type"); // SaleOrder / Purchase order (invoice_out,invoice_in)
            $table->String("warehouse_id");
            $table->double("total_amount");
            $table->double("residual");
            $table->dateTime("purchase_date");
            $table->dateTime("planned_delivery_date")->nullable();
            $table->dateTime("delivery_date")->nullable();
            $table->String("state");
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
        Schema::dropIfExists('purchase_order');
    }
}
