<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Cart;
use App\Models\Product;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CartApiController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $carts = $request->user()->carts()->with('product.category')->get();

        $total = $carts->sum(fn ($c) => $c->product->price * $c->quantity);

        return response()->json([
            'items' => $carts,
            'total' => $total,
            'total_formatted' => 'Rp ' . number_format($total, 0, ',', '.'),
        ]);
    }

    public function add(Request $request, Product $product): JsonResponse
    {
        $request->validate(['quantity' => ['required', 'integer', 'min:1']]);

        if (! $product->is_active) {
            return response()->json(['message' => 'Produk tidak tersedia.'], 422);
        }

        if ($product->stock < $request->quantity) {
            return response()->json(['message' => 'Stok tidak mencukupi.'], 422);
        }

        $cart = Cart::where('user_id', $request->user()->id)
            ->where('product_id', $product->id)
            ->first();

        if ($cart) {
            $newQty = $cart->quantity + $request->quantity;
            if ($product->stock < $newQty) {
                return response()->json(['message' => 'Stok tidak mencukupi.'], 422);
            }
            $cart->update(['quantity' => $newQty]);
        } else {
            $cart = Cart::create([
                'user_id'    => $request->user()->id,
                'product_id' => $product->id,
                'quantity'   => $request->quantity,
            ]);
        }

        return response()->json([
            'message' => 'Produk ditambahkan ke keranjang.',
            'cart'    => $cart->load('product'),
        ], 201);
    }

    public function update(Request $request, Cart $cart): JsonResponse
    {
        if ($cart->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized.'], 403);
        }

        $request->validate(['quantity' => ['required', 'integer', 'min:1']]);

        if ($cart->product->stock < $request->quantity) {
            return response()->json(['message' => 'Stok tidak mencukupi.'], 422);
        }

        $cart->update(['quantity' => $request->quantity]);

        return response()->json([
            'message' => 'Keranjang diperbarui.',
            'cart'    => $cart->load('product'),
        ]);
    }

    public function remove(Request $request, Cart $cart): JsonResponse
    {
        if ($cart->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized.'], 403);
        }

        $cart->delete();

        return response()->json(['message' => 'Produk dihapus dari keranjang.']);
    }
}
