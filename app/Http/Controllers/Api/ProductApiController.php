<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\Product;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProductApiController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Product::with('category')->where('is_active', true);

        if ($request->filled('category')) {
            $query->whereHas('category', fn ($q) => $q->where('slug', $request->category));
        }

        if ($request->filled('search')) {
            $query->where('name', 'like', '%' . $request->search . '%');
        }

        $products = $query->latest()->paginate($request->get('per_page', 12));

        return response()->json($products);
    }

    public function show(Product $product): JsonResponse
    {
        if (! $product->is_active) {
            return response()->json(['message' => 'Produk tidak ditemukan.'], 404);
        }

        $product->load('category');

        $related = Product::with('category')
            ->where('category_id', $product->category_id)
            ->where('id', '!=', $product->id)
            ->where('is_active', true)
            ->take(4)
            ->get();

        return response()->json([
            'product' => $product,
            'related' => $related,
        ]);
    }

    public function categories(): JsonResponse
    {
        $categories = Category::withCount(['products' => fn ($q) => $q->where('is_active', true)])->get();

        return response()->json($categories);
    }
}
