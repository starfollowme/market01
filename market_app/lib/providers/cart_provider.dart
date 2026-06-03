import 'package:flutter/foundation.dart';
import '../data/models/cart_model.dart';
import '../data/services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  final _service = CartService();

  List<CartModel> _items = [];
  double _total = 0;
  bool _isLoading = false;
  String? _error;

  List<CartModel> get items => _items;
  double get total => _total;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get count => _items.fold(0, (sum, e) => sum + e.quantity);

  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _service.getCart();
      _items = data['items'];
      _total = double.tryParse(data['total'].toString()) ?? 0;
      _error = null;
    } catch (e) {
      _error = 'Gagal memuat keranjang.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addToCart(int productId, int quantity) async {
    try {
      await _service.addToCart(productId, quantity);
      await loadCart();
      return true;
    } catch (e) {
      _error = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> updateCart(int cartId, int quantity) async {
    try {
      await _service.updateCart(cartId, quantity);
      await loadCart();
    } catch (e) {
      _error = _parseError(e);
      notifyListeners();
    }
  }

  Future<void> removeFromCart(int cartId) async {
    try {
      await _service.removeFromCart(cartId);
      _items.removeWhere((e) => e.id == cartId);
      _total = _items.fold(0, (sum, e) => sum + e.subtotal);
      notifyListeners();
    } catch (_) {}
  }

  void clear() {
    _items = [];
    _total = 0;
    notifyListeners();
  }

  String _parseError(dynamic e) {
    try {
      return e.response?.data['message'] ?? 'Terjadi kesalahan.';
    } catch (_) {
      return 'Tidak dapat terhubung ke server.';
    }
  }
}
