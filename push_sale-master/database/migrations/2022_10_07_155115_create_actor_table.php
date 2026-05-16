<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateActorTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('actor', function (Blueprint $table) {
            $table->String("id");
            $table->primary("id");
            $table->String("type")->default("user");
            $table->String("firstname");
            $table->String("lastname");
            $table->String("phone")->nullable();
            $table->String("mail")->unique();
            $table->String("image")->nullable();
            $table->String("address_id")->nullable();
            $table->integer("profile_id");
            $table->integer("user_id");
            $table->String("distributor_id")->nullable();
            $table->integer("rate")->default(0);
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
        Schema::dropIfExists('actor');
    }
}
