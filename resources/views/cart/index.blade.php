@extends('layouts.app')
@section('title', 'Keranjang Belanja')

@section('content')
<h4 class="fw-bold mb-4"><i class="bi bi-cart3 me-2"></i>Keranjang Belanja</h4>

@if($carts->isEmpty())
<div class="text-center py-5">
    <i class="bi bi-cart-x display-3 text-muted"></i>
    <p class="mt-3 text-muted">Keranjang belanjamu kosong.</p>
    <a href="{{ route('products.index') }}" class="btn btn-primary">Mulai Belanja</a>
</div>
@else
<div class="row">
    <div class="col-lg-8">
        <div class="card border-0 shadow-sm">
            <div class="card-body p-0">
                <table class="table table-borderless align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th class="ps-3">Produk</th>
                            <th class="text-center">Harga</th>
                            <th class="text-center">Qty</th>
                            <th class="text-center">Subtotal</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($carts as $cart)
                        <tr>
                            <td class="ps-3">
                                <div class="d-flex align-items-center gap-3">
                                    <div class="bg-light rounded d-flex align-items-center justify-content-center" style="width:56px;height:56px">
                                        <i class="bi bi-image text-secondary"></i>
                                    </div>
                                    <div>
                                        <p class="fw-semibold mb-0">{{ $cart->product->name }}</p>
                                        <small class="text-muted">{{ $cart->product->category->name }}</small>
                                    </div>
                                </div>
                            </td>
                            <td class="text-center">Rp {{ number_format($cart->product->price, 0, ',', '.') }}</td>
                            <td class="text-center" style="width:130px">
                                <form action="{{ route('cart.update', $cart->id) }}" method="POST" class="d-flex align-items-center justify-content-center gap-1">
                                    @csrf
                                    @method('PATCH')
                                    <input type="number" name="quantity" class="form-control form-control-sm text-center"
                                        value="{{ $cart->quantity }}" min="1" max="{{ $cart->product->stock }}" style="width:60px">
                                    <button type="submit" class="btn btn-sm btn-outline-secondary p-1" title="Update">
                                        <i class="bi bi-arrow-clockwise"></i>
                                    </button>
                                </form>
                            </td>
                            <td class="text-center fw-bold">
                                Rp {{ number_format($cart->product->price * $cart->quantity, 0, ',', '.') }}
                            </td>
                            <td>
                                <form action="{{ route('cart.remove', $cart->id) }}" method="POST">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" class="btn btn-sm btn-outline-danger"
                                        onclick="return confirm('Hapus produk ini?')">
                                        <i class="bi bi-trash"></i>
                                    </button>
                                </form>
                            </td>
                        </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <div class="col-lg-4">
        <div class="card border-0 shadow-sm">
            <div class="card-body">
                <h6 class="fw-bold mb-3">Ringkasan Pesanan</h6>
                <div class="d-flex justify-content-between mb-2">
                    <span class="text-muted">Total item</span>
                    <span>{{ $carts->sum('quantity') }}</span>
                </div>
                <hr>
                <div class="d-flex justify-content-between fw-bold fs-5">
                    <span>Total</span>
                    <span class="text-primary">Rp {{ number_format($total, 0, ',', '.') }}</span>
                </div>
                <a href="{{ route('orders.checkout') }}" class="btn btn-primary w-100 mt-3">
                    <i class="bi bi-bag-check me-1"></i>Checkout
                </a>
                <a href="{{ route('products.index') }}" class="btn btn-outline-secondary w-100 mt-2">
                    Lanjut Belanja
                </a>
            </div>
        </div>
    </div>
</div>
@endif
@endsection
