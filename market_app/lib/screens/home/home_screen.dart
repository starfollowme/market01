import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    final auth = context.watch<AuthProvider>();
    final products = context.watch<ProductProvider>();
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        controller: _scrollCtrl,
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            snap: true,
            elevation: 0,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            title: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.shopping_bag_rounded, size: 20, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Text('Market', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            actions: [
              if (auth.isLoggedIn)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: badges.Badge(
                    badgeContent: Text('${cart.count}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    showBadge: cart.count > 0,
                    badgeStyle: const badges.BadgeStyle(badgeColor: Color(0xFFEC4899)),
                    child: IconButton(
                      icon: const Icon(Icons.shopping_cart_outlined),
                      onPressed: () => context.push('/cart'),
                    ),
                  ),
                ),
              if (!auth.isLoggedIn)
                TextButton(onPressed: () => context.push('/login'), child: const Text('Masuk')),
              if (auth.isLoggedIn)
                PopupMenuButton(
                  icon: CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFFEEF2FF),
                    child: Text(auth.user?.name[0].toUpperCase() ?? 'U',
                      style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold)),
                  ),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      child: ListTile(
                        leading: const Icon(Icons.receipt_long_outlined, size: 20),
                        title: const Text('Pesanan Saya', style: TextStyle(fontSize: 14)),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        onTap: () { Navigator.pop(context); context.push('/orders'); },
                      ),
                    ),
                    PopupMenuItem(
                      child: ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red, size: 20),
                        title: const Text('Keluar', style: TextStyle(color: Colors.red, fontSize: 14)),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        onTap: () async {
                          Navigator.pop(context);
                          final authProv = context.read<AuthProvider>();
                          final cartProv = context.read<CartProvider>();
                          await authProv.logout();
                          if (mounted) cartProv.clear();
                        },
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Cari produk...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Color(0xFF94A3B8)),
                            onPressed: () {
                              _searchCtrl.clear();
                              context.read<ProductProvider>().setSearch('');
                            })
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onSubmitted: (v) => context.read<ProductProvider>().setSearch(v),
                ),
              ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),
            ),
          ),

          // Categories
          if (products.categories.isNotEmpty)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44,
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
                          selectedColor: const Color(0xFF6366F1),
                          labelStyle: TextStyle(color: selected ? Colors.white : const Color(0xFF64748B)),
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
                        selectedColor: const Color(0xFF6366F1),
                        labelStyle: TextStyle(color: selected ? Colors.white : const Color(0xFF64748B)),
                      ),
                    );
                  },
                ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // Products Grid
          products.isLoading && products.products.isEmpty
              ? const SliverFillRemaining(child: LoadingShimmer())
              : products.products.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 12),
                            Text('Produk tidak ditemukan', style: TextStyle(color: Colors.grey[500])),
                          ],
                        ).animate().fadeIn(),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (_, i) {
                            if (i == products.products.length) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            final p = products.products[i];
                            return ProductCard(
                              product: p,
                              onTap: () => context.push('/products/${p.slug}'),
                            ).animate().fadeIn(delay: (i * 50).ms).scale(begin: const Offset(0.8, 0.8));
                          },
                          childCount: products.products.length + (products.hasMore ? 1 : 0),
                        ),
                      ),
                    ),
        ],
      ),
    );
  }
}
