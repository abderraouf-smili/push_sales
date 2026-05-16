<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateTrackingOrdersTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('tracking_orders', function (Blueprint $table) {
            $table->String("id");
            $table->primary("id");
            $table->string("actor_id");
            $table->string("order_id");
            $table->string("purchaseorder_id");
            $table->string("state");
            $table->double("amount");
            $table->string("image");
            $table->boolean("is_last");
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
        Schema::dropIfExists('tracking_orders');
    }
}
