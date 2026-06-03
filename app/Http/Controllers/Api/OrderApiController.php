<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\OrderItem;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class OrderApiController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $orders = $request->user()
            ->orders()
            ->latest()
            ->paginate($request->get('per_page', 10));

        return response()->json($orders);
    }

    public function show(Request $request, Order $order): JsonResponse
    {
        if ($order->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized.'], 403);
        }

        $order->load('items.product');

        return response()->json([
            'order'        => $order,
            'status_label' => $order->status_label,
            'status_color' => $order->status_color,
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'shipping_address' => ['required', 'string'],
            'phone'            => ['required', 'string', 'max:20'],
            'notes'            => ['nullable', 'string'],
        ]);

        $carts = $request->user()->carts()->with('product')->get();

        if ($carts->isEmpty()) {
            return response()->json(['message' => 'Keranjang kosong.'], 422);
        }

        foreach ($carts as $cart) {
            if ($cart->product->stock < $cart->quantity) {
                return response()->json([
                    'message' => "Stok '{$cart->product->name}' tidak mencukupi.",
                ], 422);
            }
        }

        $total = $carts->sum(fn ($c) => $c->product->price * $c->quantity);

        $order = DB::transaction(function () use ($request, $carts, $data, $total) {
            $order = Order::create([
                'user_id'          => $request->user()->id,
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
                $cart->product->decrement('stock', $cart->quantity);
            }

            $request->user()->carts()->delete();

            return $order;
        });

        return response()->json([
            'message' => 'Pesanan berhasil dibuat.',
            'order'   => $order->load('items.product'),
        ], 201);
    }
}
