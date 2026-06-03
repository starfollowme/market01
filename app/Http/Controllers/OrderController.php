<?php

namespace App\Http\Controllers;

use App\Models\Cart;
use App\Models\Order;
use App\Models\OrderItem;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class OrderController extends Controller
{
    public function index()
    {
        $orders = auth()->user()->orders()->latest()->paginate(10);

        return view('orders.index', compact('orders'));
    }

    public function show(Order $order)
    {
        $this->authorize('view', $order);

        $order->load('items.product');

        return view('orders.show', compact('order'));
    }

    public function checkout()
    {
        $carts = auth()->user()->carts()->with('product')->get();

        if ($carts->isEmpty()) {
            return redirect()->route('cart.index')->with('error', 'Keranjang kosong.');
        }

        $total = $carts->sum(fn ($c) => $c->product->price * $c->quantity);

        return view('orders.checkout', compact('carts', 'total'));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'shipping_address' => ['required', 'string'],
            'phone'            => ['required', 'string', 'max:20'],
            'notes'            => ['nullable', 'string'],
        ]);

        $carts = auth()->user()->carts()->with('product')->get();

        if ($carts->isEmpty()) {
            return redirect()->route('cart.index')->with('error', 'Keranjang kosong.');
        }

        // Check stock availability
        foreach ($carts as $cart) {
            if ($cart->product->stock < $cart->quantity) {
                return back()->with('error', "Stok '{$cart->product->name}' tidak mencukupi.");
            }
        }

        $total = $carts->sum(fn ($c) => $c->product->price * $c->quantity);

        DB::transaction(function () use ($carts, $data, $total) {
            $order = Order::create([
                'user_id'          => auth()->id(),
                'order_number'     => 'ORD-' . strtoupper(uniqid()),
                'total_price'      => $total,
                'status'           => 'pending',
                'shipping_address' => $data['shipping_address'],
                'phone'            => $data['phone'],
                'notes'            => $data['notes'] ?? null,
            ]);

            foreach ($carts as $cart) {
                OrderItem::create([
                    'order_id'   => $order->id,
                    'product_id' => $cart->product_id,
                    'quantity'   => $cart->quantity,
                    'price'      => $cart->product->price,
                ]);

                // Decrease stock
                $cart->product->decrement('stock', $cart->quantity);
            }

            // Clear cart
            auth()->user()->carts()->delete();
        });

        return redirect()->route('orders.index')->with('success', 'Pesanan berhasil dibuat.');
    }
}
