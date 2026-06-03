import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrders();
    });
  }

  Color _statusColor(String status) {
    return switch (status) {
      'pending'    => Colors.orange,
      'processing' => Colors.blue,
      'shipped'    => Colors.indigo,
      'delivered'  => Colors.green,
      'cancelled'  => Colors.red,
      _            => Colors.grey,
    };
  }

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

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Pesanan Saya'), centerTitle: true),
      body: prov.isLoading
          ? const Center(child: CircularProgressIndicator())
          : prov.orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 72, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text('Belum ada pesanan', style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: () => context.go('/'), child: const Text('Mulai Belanja')),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: prov.orders.length,
                  itemBuilder: (_, i) {
                    final order = prov.orders[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(order.orderNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _statusColor(order.status).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(order.statusLabel,
                                style: TextStyle(color: _statusColor(order.status), fontSize: 12, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text('Rp ${_fmt(order.totalPrice)}',
                              style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(order.createdAt.substring(0, 10), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          ],
                        ),
                        onTap: () => context.push('/orders/${order.id}'),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    );
                  },
                ),
    );
  }
}
