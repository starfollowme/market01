import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final String id;
  const ProductDetailScreen({super.key, required this.id});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ProductModel? _product;
  bool _isLoading = true;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await context.read<ProductProvider>().getProduct(widget.id);
      if (mounted) {
        setState(() {
          _product = data['product'];
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

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final initialDateRange = _selectedDateRange ??
        DateTimeRange(start: now, end: now.add(Duration(days: _product?.primaryRental?.cycleValue ?? 1)));
    
    final result = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: initialDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedDateRange = result;
      });
    }
  }

  void _rentNow() {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      context.push('/login');
      return;
    }
    
    if (_selectedDateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Pilih tanggal sewa terlebih dahulu'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    // Prepare data for checkout
    final rental = _product!.primaryRental;
    if (rental == null) return;
    
    final days = _selectedDateRange!.end.difference(_selectedDateRange!.start).inDays + 1;
    final cycle = rental.cycleValue;
    final totalCycles = (days / cycle).ceil();
    final totalPrice = totalCycles * rental.price;

    context.push('/checkout', extra: {
      'product': _product,
      'rental': rental,
      'startDate': _selectedDateRange!.start,
      'endDate': _selectedDateRange!.end,
      'days': days,
      'totalPrice': totalPrice,
    });
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

    final rental = _product!.primaryRental;

    return Scaffold(
      appBar: AppBar(title: Text(_product!.name), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              width: double.infinity, height: 280,
              color: const Color(0xFFEEF2FF),
              child: Icon(Icons.car_rental, size: 80, color: const Color(0xFF2563EB).withValues(alpha: 0.3)),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_product!.category != null)
                    Chip(
                      label: Text(_product!.category!.name),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: const Color(0xFFEEF2FF),
                      labelStyle: const TextStyle(color: Color(0xFF2563EB)),
                    ),
                  const SizedBox(height: 8),
                  Text(_product!.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  
                  if (rental != null)
                    Text('Rp ${_formatPrice(rental.price)} / ${rental.cycleValue} hari',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                      
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.inventory_2_outlined, color: Color(0xFF10B981), size: 16),
                      const SizedBox(width: 4),
                      Text(_product!.condition ?? 'Bagus', style: const TextStyle(color: Color(0xFF10B981))),
                    ],
                  ),
                  const Divider(height: 32),
                  
                  // Date Picker Section
                  const Text('Tanggal Sewa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickDateRange,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Color(0xFF2563EB)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _selectedDateRange == null
                                ? const Text('Pilih Tanggal Sewa', style: TextStyle(color: Colors.grey))
                                : Text(
                                    '${DateFormat('dd MMM yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd MMM yyyy').format(_selectedDateRange!.end)}',
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  
                  const Divider(height: 32),
                  if (_product!.description != null) ...[
                    const Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(_product!.description!, style: TextStyle(color: Colors.grey[700], height: 1.5)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: rental != null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _rentNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Sewa Sekarang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  child: const Text('Tidak tersedia untuk disewa'),
                ),
              ),
            ),
    );
  }
}
