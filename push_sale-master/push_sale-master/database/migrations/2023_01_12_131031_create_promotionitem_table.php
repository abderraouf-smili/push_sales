<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreatePromotionitemTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('promotion_item', function (Blueprint $table) {
            $table->String("id");
            $table->primary("id");
            $table->String("promotion_id");
            $table->integer("category_id")->nullable()->unsigned();
            $table->integer("product_id")->nullable()->unsigned();
            $table->integer("variant_id")->nullable()->unsigned();
            $table->double("discount");
            $table->double("minimum")->default(1.0);
            $table->String("unite");
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
        Schema::dropIfExists('promotion_item');
    }
}
