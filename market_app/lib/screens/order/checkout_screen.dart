import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/product_model.dart';
import '../../providers/order_provider.dart';

class CheckoutScreen extends StatefulWidget {
  final ProductModel? product;
  final ProductRentalModel? rental;
  final DateTime? startDate;
  final DateTime? endDate;
  final int days;
  final double totalPrice;

  const CheckoutScreen({
    super.key,
    this.product,
    this.rental,
    this.startDate,
    this.endDate,
    this.days = 0,
    this.totalPrice = 0.0,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  String _deliveryMethod = 'pickup';

  String _fmt(double price) {
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

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (widget.rental == null || widget.startDate == null || widget.endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data tidak lengkap'), backgroundColor: Colors.red),
      );
      return;
    }

    final orderProv = context.read<OrderProvider>();
    final order = await orderProv.createOrder(
      productRentalId: widget.rental!.id,
      startTime: DateFormat('yyyy-MM-dd').format(widget.startDate!),
      endTime: DateFormat('yyyy-MM-dd').format(widget.endDate!),
      deliveryMethod: _deliveryMethod,
    );

    if (!mounted) return;

    if (order != null) {
      context.go('/orders');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesanan berhasil dibuat'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(orderProv.error ?? 'Gagal membuat pesanan'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<OrderProvider>().isLoading;

    if (widget.product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: const Center(child: Text('Data tidak valid')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order summary
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ringkasan Pesanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 60, height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.car_rental, color: Color(0xFF2563EB)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.product!.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                const SizedBox(height: 4),
                                Text(
                                  'Rp ${_fmt(widget.rental?.price ?? 0)} / ${widget.rental?.cycleValue ?? 1} hari',
                                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      _buildRow('Tanggal Mulai', DateFormat('dd MMM yyyy').format(widget.startDate!)),
                      const SizedBox(height: 8),
                      _buildRow('Tanggal Selesai', DateFormat('dd MMM yyyy').format(widget.endDate!)),
                      const SizedBox(height: 8),
                      _buildRow('Durasi Sewa', '${widget.days} hari'),
                      const Divider(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Biaya', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Rp ${_fmt(widget.totalPrice)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB), fontSize: 20)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Text('Metode Pengiriman', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              
              Card(
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text('Ambil di Toko (Pickup)'),
                      value: 'pickup',
                      groupValue: _deliveryMethod,
                      activeColor: const Color(0xFF2563EB),
                      onChanged: (v) => setState(() => _deliveryMethod = v!),
                    ),
                    const Divider(height: 1),
                    RadioListTile<String>(
                      title: const Text('Kirim ke Alamat (Delivery)'),
                      value: 'delivery',
                      groupValue: _deliveryMethod,
                      activeColor: const Color(0xFF2563EB),
                      onChanged: widget.rental?.isDelivery == 'yes'
                          ? (v) => setState(() => _deliveryMethod = v!)
                          : null,
                      subtitle: widget.rental?.isDelivery != 'yes'
                          ? const Text('Produk ini tidak bisa dikirim', style: TextStyle(color: Colors.red, fontSize: 12))
                          : null,
                    ),
                  ],
                ),
              ),
              
              if (_deliveryMethod == 'delivery') ...[
                const SizedBox(height: 16),
                const Text('Alamat pengiriman akan diambil dari profil Anda.',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
              ],

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : _placeOrder,
                  icon: isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check_circle_outline),
                  label: const Text('Konfirmasi & Bayar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF64748B))),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
