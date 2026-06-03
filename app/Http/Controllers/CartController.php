<?php

namespace App\Http\Controllers;

use App\Models\Cart;
use App\Models\Product;
use Illuminate\Http\Request;

class CartController extends Controller
{
    public function index()
    {
        $carts = auth()->user()->carts()->with('product')->get();
        $total = $carts->sum(fn ($c) => $c->product->price * $c->quantity);

        return view('cart.index', compact('carts', 'total'));
    }

    public function add(Request $request, Product $product)
    {
        $request->validate(['quantity' => ['required', 'integer', 'min:1']]);

        if ($product->stock < $request->quantity) {
            return back()->with('error', 'Stok tidak mencukupi.');
        }

        $cart = Cart::where('user_id', auth()->id())
            ->where('product_id', $product->id)
            ->first();

        if ($cart) {
            $newQty = $cart->quantity + $request->quantity;
            if ($product->stock < $newQty) {
                return back()->with('error', 'Stok tidak mencukupi.');
            }
            $cart->update(['quantity' => $newQty]);
        } else {
            Cart::create([
                'user_id'    => auth()->id(),
                'product_id' => $product->id,
                'quantity'   => $request->quantity,
            ]);
        }

        return redirect()->route('cart.index')->with('success', 'Produk ditambahkan ke keranjang.');
    }

    public function update(Request $request, Cart $cart)
    {
        $this->authorize('update', $cart);

        $request->validate(['quantity' => ['required', 'integer', 'min:1']]);

        if ($cart->product->stock < $request->quantity) {
            return back()->with('error', 'Stok tidak mencukupi.');
        }

        $cart->update(['quantity' => $request->quantity]);

        return back()->with('success', 'Keranjang diperbarui.');
    }

    public function remove(Cart $cart)
    {
        $this->authorize('delete', $cart);
        $cart->delete();

        return back()->with('success', 'Produk dihapus dari keranjang.');
    }
}
