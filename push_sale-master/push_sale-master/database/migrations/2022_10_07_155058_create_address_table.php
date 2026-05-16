<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateAddressTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('address', function (Blueprint $table) {
            $table->String("id");
            $table->primary("id");
            $table->text("street")->nullable();
            $table->text("commune")->nullable();
            $table->String("zipcode")->nullable();
            $table->double("latitude")->nullable();;
            $table->double("longitude")->nullable();;
            $table->integer("city_id");
            $table->integer("state_id");
            $table->integer("country_id");
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
        Schema::dropIfExists('address');
    }
}
