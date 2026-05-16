<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreatePricelistTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('pricelist', function (Blueprint $table) {
            $table->id();
            $table->String("name");
            $table->String("description");
            $table->integer("typepv_id")->nullable();
            $table->date("start_date")->nullable();
            $table->date("end_date")->nullable();
            $table->boolean("active");
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
        Schema::dropIfExists('pricelist');
    }
}
