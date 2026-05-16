<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application"s database.
     *
     * @return void
     */
    public function run()
    {
        DB::table("transaction_type")->insert([
            "name" => "initiale",
            "sens" => -1,
            "created_at" => date("Y/m/d H:i:s"),
            "updated_at" => date("Y/m/d H:i:s"),
        ]);
        DB::table("transaction_type")->insert([
            "name" => "sale",
            "sens" => -1,
            "created_at" => date("Y/m/d H:i:s"),
            "updated_at" => date("Y/m/d H:i:s"),
        ]);
        DB::table("transaction_type")->insert([
            "name" => "cash",
            "sens" => 1,
            "created_at" => date("Y/m/d H:i:s"),
            "updated_at" => date("Y/m/d H:i:s"),
        ]);
        DB::table("transaction_type")->insert([
            "name" => "purchase",
            "sens" => 1,
            "created_at" => date("Y/m/d H:i:s"),
            "updated_at" => date("Y/m/d H:i:s"),
        ]);


    }
}
