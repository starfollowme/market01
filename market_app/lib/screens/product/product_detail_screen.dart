import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../data/models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';

class ProductDetailScreen extends StatefulWidget {
  final String slug;
  const ProductDetailScreen({super.key, required this.slug});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ProductModel? _product;
  List<ProductModel> _related = [];
  bool _isLoading = true;
  int _qty = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await context.read<ProductProvider>().getProduct(widget.slug);
      if (mounted) {
        setState(() {
          _product = data['product'];
          _related = data['related'];
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatPrice(double price) {
    final str = price.toStringAsFixed(0);
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      count++;
    }
    return buffer.toString().split('').reversed.join();
  }

  Future<void> _addToCart() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      context.push('/login');
      return;
    }
    final ok = await context.read<CartProvider>().addToCart(_product!.id, _qty);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'Ditambahkan ke keranjang' : context.read<CartProvider>().error ?? 'Gagal'),
      backgroundColor: ok ? Colors.green : Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_product == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Produk tidak ditemukan')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(_product!.name), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              width: double.infinity, height: 280,
              color: Colors.grey[100],
              child: Icon(Icons.image_outlined, size: 80, color: Colors.grey[400]),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_product!.category != null)
                    Chip(label: Text(_product!.category!.name), visualDensity: VisualDensity.compact),
                  const SizedBox(height: 8),
                  Text(_product!.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Rp ${_formatPrice(_product!.price)}',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                  const SizedBox(height: 4),
                  Text('Stok: ${_product!.stock}', style: TextStyle(color: Colors.grey[600])),
                  const Divider(height: 24),
                  if (_product!.description != null) ...[
                    const Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(_product!.description!, style: TextStyle(color: Colors.grey[700], height: 1.5)),
                  ],

                  if (_product!.stock > 0) ...[
                    const SizedBox(height: 24),
                    const Text('Jumlah', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _qty > 1 ? () => setState(() => _qty--) : null,
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('$_qty', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        IconButton(
                          onPressed: _qty < _product!.stock ? () => setState(() => _qty++) : null,
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Related products
            if (_related.isNotEmpty) ...[
              const Divider(),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text('Produk Serupa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _related.length,
                  itemBuilder: (_, i) => SizedBox(
                    width: 150,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ProductCard(
                        product: _related[i],
                        onTap: () => context.pushReplacement('/products/${_related[i].slug}'),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ],
        ),
      ),
      bottomNavigationBar: _product!.stock > 0
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: _addToCart,
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('Tambah ke Keranjang', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                ),
              ),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  child: const Text('Stok Habis'),
                ),
              ),
            ),
    );
  }
}
