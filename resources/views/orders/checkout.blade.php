@extends('layouts.app')
@section('title', 'Checkout')

@section('content')
<h4 class="fw-bold mb-4"><i class="bi bi-bag-check me-2"></i>Checkout</h4>

<div class="row g-4">
    <div class="col-lg-7">
        <div class="card border-0 shadow-sm">
            <div class="card-body">
                <h6 class="fw-bold mb-3">Informasi Pengiriman</h6>

                @if($errors->any())
                <div class="alert alert-danger">
                    <ul class="mb-0">
                        @foreach($errors->all() as $err)<li>{{ $err }}</li>@endforeach
                    </ul>
                </div>
                @endif

                <form action="{{ route('orders.store') }}" method="POST" id="checkoutForm">
                    @csrf
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Alamat Pengiriman <span class="text-danger">*</span></label>
                        <textarea name="shipping_address" class="form-control" rows="3"
                            placeholder="Jalan, Kelurahan, Kecamatan, Kota, Provinsi" required>{{ old('shipping_address') }}</textarea>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Nomor HP <span class="text-danger">*</span></label>
                        <input type="text" name="phone" class="form-control"
                            placeholder="08xxxxxxxxxx" value="{{ old('phone') }}" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Catatan (opsional)</label>
                        <textarea name="notes" class="form-control" rows="2"
                            placeholder="Catatan untuk penjual...">{{ old('notes') }}</textarea>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <div class="col-lg-5">
        <div class="card border-0 shadow-sm">
            <div class="card-body">
                <h6 class="fw-bold mb-3">Produk Dipesan</h6>
                @foreach($carts as $cart)
                <div class="d-flex justify-content-between align-items-center mb-2">
                    <div>
                        <p class="mb-0 fw-semibold">{{ $cart->product->name }}</p>
                        <small class="text-muted">× {{ $cart->quantity }}</small>
                    </div>
                    <span>Rp {{ number_format($cart->product->price * $cart->quantity, 0, ',', '.') }}</span>
                </div>
                @endforeach
                <hr>
                <div class="d-flex justify-content-between fw-bold fs-5 mb-3">
                    <span>Total</span>
                    <span class="text-primary">Rp {{ number_format($total, 0, ',', '.') }}</span>
                </div>
                <button type="submit" form="checkoutForm" class="btn btn-success w-100">
                    <i class="bi bi-check-circle me-1"></i>Buat Pesanan
                </button>
                <a href="{{ route('cart.index') }}" class="btn btn-outline-secondary w-100 mt-2">
                    Kembali ke Keranjang
                </a>
            </div>
        </div>
    </div>
</div>
@endsection
