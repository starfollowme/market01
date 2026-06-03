@extends('layouts.app')
@section('title', 'Produk')

@section('content')
<div class="row">
    {{-- Sidebar Kategori --}}
    <div class="col-lg-2 mb-4">
        <div class="card border-0 shadow-sm">
            <div class="card-body p-3">
                <h6 class="fw-bold mb-3">Kategori</h6>
                <a href="{{ route('products.index', request()->except('category')) }}"
                   class="d-block py-1 text-decoration-none {{ !request('category') ? 'fw-bold text-primary' : 'text-secondary' }}">
                    Semua
                </a>
                @foreach($categories as $cat)
                <a href="{{ route('products.index', array_merge(request()->all(), ['category' => $cat->slug])) }}"
                   class="d-block py-1 text-decoration-none {{ request('category') == $cat->slug ? 'fw-bold text-primary' : 'text-secondary' }}">
                    {{ $cat->name }}
                </a>
                @endforeach
            </div>
        </div>
    </div>

    {{-- Products Grid --}}
    <div class="col-lg-10">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h5 class="fw-bold mb-0">
                @if(request('search'))
                    Hasil: "{{ request('search') }}"
                @elseif(request('category'))
                    {{ $categories->firstWhere('slug', request('category'))?->name ?? 'Produk' }}
                @else
                    Semua Produk
                @endif
                <small class="text-muted fw-normal fs-6">({{ $products->total() }} item)</small>
            </h5>
        </div>

        @if($products->isEmpty())
        <div class="text-center py-5">
            <i class="bi bi-box-seam display-3 text-muted"></i>
            <p class="mt-3 text-muted">Produk tidak ditemukan.</p>
        </div>
        @else
        <div class="row g-3">
            @foreach($products as $product)
            <div class="col-sm-6 col-md-4 col-xl-3">
                <div class="card h-100 border-0 shadow-sm product-card">
                    <div class="card-img-top d-flex align-items-center justify-content-center bg-light" style="height:180px">
                        <i class="bi bi-image text-secondary" style="font-size:3rem"></i>
                    </div>
                    <div class="card-body d-flex flex-column">
                        <span class="badge bg-secondary badge-category mb-1">{{ $product->category->name }}</span>
                        <h6 class="card-title fw-semibold">{{ $product->name }}</h6>
                        <p class="text-primary fw-bold fs-5 mb-1">Rp {{ number_format($product->price, 0, ',', '.') }}</p>
                        <small class="text-muted mb-3">Stok: {{ $product->stock }}</small>
                        <a href="{{ route('products.show', $product->slug) }}" class="btn btn-outline-primary btn-sm mt-auto">
                            Lihat Detail
                        </a>
                    </div>
                </div>
            </div>
            @endforeach
        </div>

        <div class="mt-4">
            {{ $products->links() }}
        </div>
        @endif
    </div>
</div>
@endsection
