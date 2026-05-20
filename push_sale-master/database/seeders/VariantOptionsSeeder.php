<?php

namespace Database\Seeders;

use App\Models\VariantOption;
use Illuminate\Database\Seeder;

class VariantOptionsSeeder extends Seeder
{
    public function run()
    {
        $options = [
            ['key' => 'couleur', 'label' => 'Couleur', 'sort_order' => 10],
            ['key' => 'marque', 'label' => 'Marque', 'sort_order' => 20],
            ['key' => 'format', 'label' => 'Format', 'sort_order' => 30],
            ['key' => 'taille', 'label' => 'Taille', 'sort_order' => 40],
            ['key' => 'type', 'label' => 'Type', 'sort_order' => 50],
        ];

        foreach ($options as $option) {
            VariantOption::updateOrCreate(
                ['key' => $option['key']],
                [
                    'label' => $option['label'],
                    'sort_order' => $option['sort_order'],
                    'is_active' => true,
                ]
            );
        }
    }
}
