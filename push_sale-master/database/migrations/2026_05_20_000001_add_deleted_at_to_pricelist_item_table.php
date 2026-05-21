<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddDeletedAtToPricelistItemTable extends Migration
{
    public function up()
    {
        if (Schema::hasTable('pricelist_item') && !Schema::hasColumn('pricelist_item', 'deleted_at')) {
            Schema::table('pricelist_item', function (Blueprint $table) {
                $table->timestamp('deleted_at')->nullable()->after('updated_at');
            });
        }
    }

    public function down()
    {
        if (Schema::hasTable('pricelist_item') && Schema::hasColumn('pricelist_item', 'deleted_at')) {
            Schema::table('pricelist_item', function (Blueprint $table) {
                $table->dropColumn('deleted_at');
            });
        }
    }
}
