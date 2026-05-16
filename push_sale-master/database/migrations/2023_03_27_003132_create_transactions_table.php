<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateTransactionsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('transactions', function (Blueprint $table) {
            $table->String("id");
            $table->primary("id");
            $table->string("client_id");
            $table->string("actor_id")->nullable();
            $table->string("order_id")->nullable();
            $table->string("purchaseorder_id")->nullable();
            $table->integer("type_id");
            $table->double("credit");
            $table->double("debit");
            $table->date("account_date");
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
        Schema::dropIfExists('transactions');
    }
}
