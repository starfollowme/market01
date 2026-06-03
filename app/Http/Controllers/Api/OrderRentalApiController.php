<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\Payment;
use App\Models\ProductRental;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class OrderRentalApiController extends Controller
{
    public function index(Request $request)
    {
        $orders = Order::with(['productRental.product.images', 'payment', 'address'])
            ->where('user_id', $request->user()->id)
            ->latest()
            ->get();

        return response()->json([
            'success' => true,
            'data' => $orders
        ]);
    }

    public function show($id, Request $request)
    {
        $order = Order::with(['productRental.product.images', 'payment', 'address'])
            ->where('user_id', $request->user()->id)
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $order
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'product_rental_id' => 'required|exists:product_rentals,id',
            'start_time' => 'required|date',
            'end_time' => 'required|date|after:start_time',
            'delivery_method' => 'required|in:pickup,delivery',
        ]);

        $rental = ProductRental::findOrFail($request->product_rental_id);

        // Kalkulasi harga (contoh sederhana)
        $start = \Carbon\Carbon::parse($request->start_time);
        $end = \Carbon\Carbon::parse($request->end_time);
        $days = $start->diffInDays($end) ?: 1;
        $totalPrice = $rental->price * $days;

        // Cek stok (jika ada sistem stok, di sini hanya asumsikan bisa dipesan)

        $orderCode = 'RNT-' . strtoupper(Str::random(10));

        $order = Order::create([
            'user_id' => $request->user()->id,
            'product_rental_id' => $rental->id,
            'order_code' => $orderCode,
            'start_time' => $request->start_time,
            'end_time' => $request->end_time,
            'status' => Order::STATUS_PENDING,
            'delivery_method' => $request->delivery_method,
            'user_address_id' => $request->user_address_id, // Opsional
        ]);

        // Buat Payment entry dummy/pending
        Payment::create([
            'order_id' => $order->id,
            'amount' => $totalPrice,
            'status' => 'pending',
            'payment_method' => 'transfer',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Pesanan sewa berhasil dibuat',
            'data' => $order->load('payment')
        ], 201);
    }
}
