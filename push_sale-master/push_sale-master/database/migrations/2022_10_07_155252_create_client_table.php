<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateClientTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('client', function (Blueprint $table) {
            $table->String("id");
            $table->primary("id");
            $table->String("name");
            $table->String("code");
            $table->String("mobile")->nullable();
            $table->String("image")->nullable();
            $table->integer("rate")->default(0);
            $table->String("actor_id");
            $table->integer("typepv_id");
            $table->String("address_id");
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
        Schema::dropIfExists('client');
    }
}
