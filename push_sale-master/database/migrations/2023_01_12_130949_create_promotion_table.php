<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreatePromotionTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('promotion', function (Blueprint $table) {
            $table->String("id");
            $table->primary("id");
            $table->String("description");
            $table->Date("start_date");
            $table->Date("end_date");
            $table->integer("distributor_id");
            $table->integer("typepv_id")->nullable()->unsigned();
            $table->integer("type_promotion_id");
            $table->String("image")->nullable();
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
        Schema::dropIfExists('promotion');
    }
}
