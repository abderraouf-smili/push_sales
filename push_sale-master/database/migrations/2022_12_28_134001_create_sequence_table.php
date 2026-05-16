<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateSequenceTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('sequence', function (Blueprint $table) {
            $table->String("id");
            $table->primary("id");
            $table->String("resource");// client / orders / ...
            $table->String("res_id"); // actor_id
            $table->String("prefix");
            $table->integer("current");
            $table->integer("position");
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
        Schema::dropIfExists('sequence');
    }
}
