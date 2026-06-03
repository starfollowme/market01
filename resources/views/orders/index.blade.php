@extends('layouts.app')
@section('title', 'Pesanan Saya')

@section('content')
<h4 class="fw-bold mb-4"><i class="bi bi-bag me-2"></i>Pesanan Saya</h4>

@if($orders->isEmpty())
<div class="text-center py-5">
    <i class="bi bi-bag-x display-3 text-muted"></i>
    <p class="mt-3 text-muted">Belum ada pesanan.</p>
    <a href="{{ route('products.index') }}" class="btn btn-primary">Mulai Belanja</a>
</div>
@else
<div class="card border-0 shadow-sm">
    <div class="card-body p-0">
        <table class="table table-hover align-middle mb-0">
            <thead class="table-light">
                <tr>
                    <th class="ps-3">No. Pesanan</th>
                    <th>Tanggal</th>
                    <th class="text-center">Status</th>
                    <th class="text-end">Total</th>
                    <th></th>
                </tr>
            </thead>
            <tbody>
                @foreach($orders as $order)
                <tr>
                    <td class="ps-3 fw-semibold">{{ $order->order_number }}</td>
                    <td>{{ $order->created_at->format('d M Y, H:i') }}</td>
                    <td class="text-center">
                        <span class="badge bg-{{ $order->status_color }}">{{ $order->status_label }}</span>
                    </td>
                    <td class="text-end fw-bold">Rp {{ number_format($order->total_price, 0, ',', '.') }}</td>
                    <td class="text-end pe-3">
                        <a href="{{ route('orders.show', $order->id) }}" class="btn btn-sm btn-outline-primary">Detail</a>
                    </td>
                </tr>
                @endforeach
            </tbody>
        </table>
    </div>
</div>
<div class="mt-3">{{ $orders->links() }}</div>
@endif
@endsection
