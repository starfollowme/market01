import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadCategories();
      context.read<ProductProvider>().loadProducts(refresh: true);
      if (context.read<AuthProvider>().isLoggedIn) {
        context.read<CartProvider>().loadCart();
      }
    });
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
        context.read<ProductProvider>().loadProducts();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth     = context.watch<AuthProvider>();
    final products = context.watch<ProductProvider>();
    final cart     = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Market', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (auth.isLoggedIn)
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () => context.push('/cart'),
                ),
                if (cart.count > 0)
                  Positioned(
                    right: 6, top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: Text('${cart.count}', style: const TextStyle(color: Colors.white, fontSize: 10)),
                    ),
                  ),
              ],
            ),
          if (!auth.isLoggedIn)
            TextButton(onPressed: () => context.push('/login'), child: const Text('Masuk')),
          if (auth.isLoggedIn)
            PopupMenuButton(
              icon: const Icon(Icons.person_outline),
              itemBuilder: (_) => [
                PopupMenuItem(
                  child: ListTile(
                    leading: const Icon(Icons.receipt_long_outlined),
                    title: const Text('Pesanan'),
                    contentPadding: EdgeInsets.zero,
                    onTap: () { Navigator.pop(context); context.push('/orders'); },
                  ),
                ),
                PopupMenuItem(
                  child: ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Keluar', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                    onTap: () async {
                      Navigator.pop(context);
                      final auth = context.read<AuthProvider>();
                      final cart = context.read<CartProvider>();
                      await auth.logout();
                      if (mounted) cart.clear();
                    },
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                        _searchCtrl.clear();
                        context.read<ProductProvider>().setSearch('');
                      })
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                filled: true, fillColor: Colors.grey[50],
              ),
              onSubmitted: (v) => context.read<ProductProvider>().setSearch(v),
            ),
          ),

          // Categories
          if (products.categories.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: products.categories.length + 1,
                itemBuilder: (_, i) {
                  if (i == 0) {
                    final selected = products.selectedCategory.isEmpty;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: const Text('Semua'),
                        selected: selected,
                        onSelected: (_) => context.read<ProductProvider>().setCategory(''),
                      ),
                    );
                  }
                  final cat = products.categories[i - 1];
                  final selected = products.selectedCategory == cat.slug;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(cat.name),
                      selected: selected,
                      onSelected: (_) => context.read<ProductProvider>().setCategory(cat.slug),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 8),

          // Products Grid
          Expanded(
            child: products.isLoading && products.products.isEmpty
                ? const LoadingShimmer()
                : products.products.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text('Produk tidak ditemukan', style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      )
                    : GridView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: products.products.length + (products.hasMore ? 1 : 0),
                        itemBuilder: (_, i) {
                          if (i == products.products.length) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final p = products.products[i];
                          return ProductCard(
                            product: p,
                            onTap: () => context.push('/products/${p.slug}'),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
