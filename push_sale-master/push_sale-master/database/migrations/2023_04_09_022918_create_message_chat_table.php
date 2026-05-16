<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateMessageChatTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('message_chat', function (Blueprint $table) {
            $table->String("id");
            $table->primary("id");
            $table->String("from_actor_id");
            $table->String("to_actor_id");
            $table->String("message");
            $table->boolean("sent")->default(0);
            $table->boolean("read")->default(0);
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
        Schema::dropIfExists('message_chat');
    }
}
