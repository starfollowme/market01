import 'package:flutter/foundation.dart';
import '../data/models/order_model.dart';
import '../data/services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  final _service = OrderService();

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      _orders = await _service.getOrders();
      _error = null;
    } catch (_) {
      _error = 'Gagal memuat pesanan.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<OrderModel?> getOrder(int id) async {
    try {
      return await _service.getOrder(id);
    } catch (_) {
      return null;
    }
  }

  Future<OrderModel?> createOrder({
    required int productRentalId,
    required String startTime,
    required String endTime,
    required String deliveryMethod,
    int? userAddressId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final order = await _service.createOrder(
        productRentalId: productRentalId,
        startTime: startTime,
        endTime: endTime,
        deliveryMethod: deliveryMethod,
        userAddressId: userAddressId,
      );
      return order;
    } catch (e) {
      try {
        _error = e.toString().contains('response')
            ? 'Gagal membuat pesanan.'
            : e.toString();
      } catch (_) {
        _error = 'Gagal membuat pesanan.';
      }
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
