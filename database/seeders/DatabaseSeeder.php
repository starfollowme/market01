<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Product;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // Admin/demo user
        User::firstOrCreate(
            ['email' => 'admin@market.test'],
            [
                'name'     => 'Admin',
                'password' => bcrypt('password'),
            ]
        );

        // Categories
        $categories = [
            ['name' => 'Elektronik',  'slug' => 'elektronik'],
            ['name' => 'Fashion',     'slug' => 'fashion'],
            ['name' => 'Makanan',     'slug' => 'makanan'],
            ['name' => 'Olahraga',    'slug' => 'olahraga'],
            ['name' => 'Rumah Tangga','slug' => 'rumah-tangga'],
        ];

        foreach ($categories as $cat) {
            Category::firstOrCreate(['slug' => $cat['slug']], $cat);
        }

        // Sample products
        $products = [
            ['category' => 'elektronik', 'name' => 'Smartphone Android 5G',     'price' => 3500000, 'stock' => 20],
            ['category' => 'elektronik', 'name' => 'Laptop Core i5 16GB',        'price' => 8900000, 'stock' => 10],
            ['category' => 'elektronik', 'name' => 'TWS Earbuds Bluetooth',      'price' => 250000,  'stock' => 50],
            ['category' => 'elektronik', 'name' => 'Powerbank 20000mAh',         'price' => 185000,  'stock' => 30],
            ['category' => 'fashion',    'name' => 'Kaos Polos Premium',         'price' => 75000,   'stock' => 100],
            ['category' => 'fashion',    'name' => 'Sepatu Running Pria',        'price' => 320000,  'stock' => 40],
            ['category' => 'fashion',    'name' => 'Jaket Hoodie Fleece',        'price' => 180000,  'stock' => 60],
            ['category' => 'makanan',    'name' => 'Kopi Arabica 500g',          'price' => 95000,   'stock' => 80],
            ['category' => 'makanan',    'name' => 'Madu Hutan Murni 350ml',     'price' => 125000,  'stock' => 45],
            ['category' => 'olahraga',   'name' => 'Matras Yoga Anti-Slip',      'price' => 150000,  'stock' => 35],
            ['category' => 'olahraga',   'name' => 'Dumbbell Set 5kg',           'price' => 220000,  'stock' => 25],
            ['category' => 'rumah-tangga','name' => 'Blender 2 Liter',           'price' => 275000,  'stock' => 20],
        ];

        foreach ($products as $p) {
            $category = Category::where('slug', $p['category'])->first();
            Product::firstOrCreate(
                ['slug' => Str::slug($p['name'])],
                [
                    'category_id' => $category->id,
                    'name'        => $p['name'],
                    'slug'        => Str::slug($p['name']),
                    'description' => 'Deskripsi produk ' . $p['name'] . '. Kualitas terjamin dan harga terjangkau.',
                    'price'       => $p['price'],
                    'stock'       => $p['stock'],
                    'is_active'   => true,
                ]
            );
        }
    }
}
