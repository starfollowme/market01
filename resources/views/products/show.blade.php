@extends('layouts.app')
@section('title', $product->name)

@section('content')
<nav aria-label="breadcrumb" class="mb-4">
    <ol class="breadcrumb">
        <li class="breadcrumb-item"><a href="{{ route('home') }}">Home</a></li>
        <li class="breadcrumb-item">
            <a href="{{ route('products.index', ['category' => $product->category->slug]) }}">
                {{ $product->category->name }}
            </a>
        </li>
        <li class="breadcrumb-item active">{{ $product->name }}</li>
    </ol>
</nav>

<div class="row g-4">
    <div class="col-md-5">
        <div class="card border-0 shadow-sm d-flex align-items-center justify-content-center bg-light" style="height:380px">
            <i class="bi bi-image text-secondary" style="font-size:5rem"></i>
        </div>
    </div>
    <div class="col-md-7">
        <span class="badge bg-secondary mb-2">{{ $product->category->name }}</span>
        <h2 class="fw-bold">{{ $product->name }}</h2>
        <p class="text-primary fw-bold fs-3 mb-1">Rp {{ number_format($product->price, 0, ',', '.') }}</p>
        <p class="text-muted mb-3">Stok tersedia: <strong>{{ $product->stock }}</strong></p>
        <p class="mb-4">{{ $product->description }}</p>

        @if($product->stock > 0)
        @auth
        <form action="{{ route('cart.add', $product->id) }}" method="POST" class="d-flex align-items-center gap-3">
            @csrf
            <div style="width:100px">
                <input type="number" name="quantity" class="form-control text-center"
                    value="1" min="1" max="{{ $product->stock }}">
            </div>
            <button type="submit" class="btn btn-primary btn-lg">
                <i class="bi bi-cart-plus me-1"></i>Tambah ke Keranjang
            </button>
        </form>
        @else
        <a href="{{ route('login') }}" class="btn btn-primary btn-lg">
            <i class="bi bi-box-arrow-in-right me-1"></i>Masuk untuk Beli
        </a>
        @endauth
        @else
        <button class="btn btn-secondary btn-lg" disabled>Stok Habis</button>
        @endif
    </div>
</div>

@if($related->count())
<hr class="my-5">
<h5 class="fw-bold mb-3">Produk Serupa</h5>
<div class="row g-3">
    @foreach($related as $item)
    <div class="col-sm-6 col-md-3">
        <div class="card h-100 border-0 shadow-sm product-card">
            <div class="card-img-top d-flex align-items-center justify-content-center bg-light" style="height:150px">
                <i class="bi bi-image text-secondary" style="font-size:2rem"></i>
            </div>
            <div class="card-body">
                <h6 class="card-title">{{ $item->name }}</h6>
                <p class="text-primary fw-bold mb-2">Rp {{ number_format($item->price, 0, ',', '.') }}</p>
                <a href="{{ route('products.show', $item->slug) }}" class="btn btn-outline-primary btn-sm">Lihat</a>
            </div>
        </div>
    </div>
    @endforeach
</div>
@endif
@endsection
