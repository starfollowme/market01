<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Models\Category;
use Illuminate\Http\Request;

class ProductRentalApiController extends Controller
{
    public function index(Request $request)
    {
        $query = Product::with(['category', 'images', 'rentals', 'shop'])
            ->where('is_maintenance', false)
            ->whereHas('rentals'); // Hanya produk yang bisa disewa

        if ($request->has('category') && $request->category != '') {
            $query->whereHas('category', function($q) use ($request) {
                $q->where('slug', $request->category);
            });
        }

        if ($request->has('search') && $request->search != '') {
            $query->where('name', 'like', '%' . $request->search . '%');
        }

        $products = $query->paginate($request->get('per_page', 12));

        return response()->json($products);
    }

    public function categories()
    {
        $categories = Category::all();
        return response()->json($categories);
    }

    public function show($id)
    {
        $product = Product::with(['category', 'images', 'rentals', 'shop'])
            ->where('is_maintenance', false)
            ->findOrFail($id);
            
        return response()->json([
            'success' => true,
            'data' => $product
        ]);
    }
}
