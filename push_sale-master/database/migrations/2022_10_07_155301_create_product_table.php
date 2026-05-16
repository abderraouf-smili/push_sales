<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateProductTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('product', function (Blueprint $table) {
            $table->id();
            $table->String("ssin")->unique(); // Soft Starter  Identifier Number
            $table->integer("rate");
            $table->text("short_description_ar");
            $table->longtext("long_description_ar");
            $table->text("short_description_fr");
            $table->longtext("long_description_fr");
            $table->string("image"); // URL
            $table->integer("category_id");
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
        Schema::dropIfExists('product');
    }
}
