<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateVariantTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('variant', function (Blueprint $table) {
            $table->id();
            $table->string("barcode");
            $table->String("image");
            $table->integer("package"); // dimension Carton
            $table->String("option1_ar")->nullable(); // le type de vraiant (taille, couleur, type)
            $table->String("option1_fr")->nullable(); // le type de vraiant (taille, couleur, type)
            $table->String("option2_ar")->nullable(); // le type de vraiant (taille, couleur, type)
            $table->String("option2_fr")->nullable(); // le type de vraiant (taille, couleur, type)
            $table->String("variant1_ar")->nullable(); // la valeur de l'option (Vert, Orange, ...) ou (Mini, Midi, Maxi, Junior) ou (Aleo verra, Comcombre, ...)
            $table->String("variant1_fr")->nullable(); // la valeur de l'option (Vert, Orange, ...) ou (Mini, Midi, Maxi, Junior) ou (Aleo verra, Comcombre, ...)
            $table->String("variant2_ar")->nullable(); // la valeur de l'option (Vert, Orange, ...) ou (Mini, Midi, Maxi, Junior) ou (Aleo verra, Comcombre, ...)
            $table->String("variant2_fr")->nullable(); // la valeur de l'option (Vert, Orange, ...) ou (Mini, Midi, Maxi, Junior) ou (Aleo verra, Comcombre, ...)
            $table->integer("product_id");
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
        Schema::dropIfExists('variant');
    }
}
