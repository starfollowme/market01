@extends('layouts.app')
@section('title', 'Detail Pesanan')

@section('content')
<div class="d-flex justify-content-between align-items-center mb-4">
    <h4 class="fw-bold mb-0">Detail Pesanan</h4>
    <a href="{{ route('orders.index') }}" class="btn btn-outline-secondary btn-sm">
        <i class="bi bi-arrow-left me-1"></i>Kembali
    </a>
</div>

<div class="row g-4">
    <div class="col-lg-8">
        <div class="card border-0 shadow-sm mb-4">
            <div class="card-header bg-white fw-bold py-3">
                <i class="bi bi-box-seam me-2"></i>Item Pesanan
            </div>
            <div class="card-body p-0">
                <table class="table table-borderless align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th class="ps-3">Produk</th>
                            <th class="text-center">Harga</th>
                            <th class="text-center">Qty</th>
                            <th class="text-end pe-3">Subtotal</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($order->items as $item)
                        <tr>
                            <td class="ps-3">{{ $item->product->name }}</td>
                            <td class="text-center">Rp {{ number_format($item->price, 0, ',', '.') }}</td>
                            <td class="text-center">{{ $item->quantity }}</td>
                            <td class="text-end pe-3 fw-bold">
                                Rp {{ number_format($item->price * $item->quantity, 0, ',', '.') }}
                            </td>
                        </tr>
                        @endforeach
                    </tbody>
                    <tfoot class="table-light">
                        <tr>
                            <td colspan="3" class="ps-3 fw-bold">Total</td>
                            <td class="text-end pe-3 fw-bold text-primary fs-5">
                                Rp {{ number_format($order->total_price, 0, ',', '.') }}
                            </td>
                        </tr>
                    </tfoot>
                </table>
            </div>
        </div>
    </div>

    <div class="col-lg-4">
        <div class="card border-0 shadow-sm mb-3">
            <div class="card-body">
                <h6 class="fw-bold mb-3">Info Pesanan</h6>
                <p class="mb-1 text-muted small">No. Pesanan</p>
                <p class="fw-semibold">{{ $order->order_number }}</p>
                <p class="mb-1 text-muted small">Tanggal</p>
                <p>{{ $order->created_at->format('d M Y, H:i') }}</p>
                <p class="mb-1 text-muted small">Status</p>
                <span class="badge bg-{{ $order->status_color }} fs-6">{{ $order->status_label }}</span>
            </div>
        </div>

        <div class="card border-0 shadow-sm">
            <div class="card-body">
                <h6 class="fw-bold mb-3">Info Pengiriman</h6>
                <p class="mb-1 text-muted small">Alamat</p>
                <p>{{ $order->shipping_address }}</p>
                <p class="mb-1 text-muted small">No. HP</p>
                <p>{{ $order->phone }}</p>
                @if($order->notes)
                <p class="mb-1 text-muted small">Catatan</p>
                <p class="mb-0">{{ $order->notes }}</p>
                @endif
            </div>
        </div>
    </div>
</div>
@endsection
