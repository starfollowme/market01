import '../../core/network/api_client.dart';
import '../models/cart_model.dart';

class CartService {
  final _dio = ApiClient.instance;

  Future<Map<String, dynamic>> getCart() async {
    final res = await _dio.get('/cart');
    final items = (res.data['items'] as List)
        .map((e) => CartModel.fromJson(e))
        .toList();
    return {
      'items': items,
      'total': res.data['total'],
      'total_formatted': res.data['total_formatted'],
    };
  }

  Future<void> addToCart(int productId, int quantity) async {
    await _dio.post('/cart/$productId', data: {'quantity': quantity});
  }

  Future<void> updateCart(int cartId, int quantity) async {
    await _dio.patch('/cart/$cartId', data: {'quantity': quantity});
  }

  Future<void> removeFromCart(int cartId) async {
    await _dio.delete('/cart/$cartId');
  }
}
