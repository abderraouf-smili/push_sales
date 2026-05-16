<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateReasonNoDeliverySaleTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('reason_no_delivery_sale', function (Blueprint $table) {
            $table->id();
            $table->string("type_reason");
            $table->String("code");
            $table->boolean("revisit");
            $table->String("description_ar");
            $table->String("description_fr");
            $table->integer("assortissement");
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
        Schema::dropIfExists('reason_no_delivery_sale');
    }
}
