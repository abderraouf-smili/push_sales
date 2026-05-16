<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateStockOperationTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('stock_operation', function (Blueprint $table) {
            $table->String("id");
            $table->primary("id");
            $table->String("type");
            $table->dateTime("operation_date");
            $table->boolean("force_package")->default(false);
            $table->String("code");
            $table->String("state")->default("new");
            $table->String("actor_id");
            $table->String("operation_id")->nullable();
            $table->String("location_id");
            $table->String("warehouse_id");
            $table->String("distributor_id");
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
        Schema::dropIfExists('stock_operation');
    }
}
