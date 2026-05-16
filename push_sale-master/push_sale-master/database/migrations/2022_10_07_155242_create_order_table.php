<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateOrderTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('order', function (Blueprint $table) {
            $table->String("id");
            $table->primary("id");
            $table->String("code")->unique();
            $table->String("actor_id");
            $table->String("client_id"); // Vendeur / Prenvendeur
            $table->double("total_amount");
            $table->double("residual");
            $table->dateTime("order_date");
            $table->dateTime("planned_delivery_date");
            $table->dateTime("delivery_date");
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
        Schema::dropIfExists('order');
    }
}
