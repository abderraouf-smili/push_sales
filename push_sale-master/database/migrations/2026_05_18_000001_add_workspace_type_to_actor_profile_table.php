<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddWorkspaceTypeToActorProfileTable extends Migration
{
    public function up()
    {
        if (!Schema::hasColumn('actor_profile', 'workspace_type')) {
            Schema::table('actor_profile', function (Blueprint $table) {
                $table->string('workspace_type')->nullable()->after('name_ar')->index();
            });
        }
    }

    public function down()
    {
        if (Schema::hasColumn('actor_profile', 'workspace_type')) {
            Schema::table('actor_profile', function (Blueprint $table) {
                $table->dropColumn('workspace_type');
            });
        }
    }
}
