<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateCouponTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('coupon', function (Blueprint $table) {
            $table->String("id");
            $table->primary("id");
            $table->String("description");
            $table->String("code");
            $table->boolean("is_pourcentage");
            $table->double("discount");
            $table->integer("count");
            $table->date("start_date");
            $table->date("end_date");
            $table->double("min_amount");
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
        Schema::dropIfExists('coupon');
    }
}
