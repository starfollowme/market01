import '../../core/network/api_client.dart';
import '../models/order_model.dart';

class OrderService {
  final _dio = ApiClient.instance;

  Future<List<OrderModel>> getOrders() async {
    final res = await _dio.get('/orders');
    return (res.data['data'] as List)
        .map((e) => OrderModel.fromJson(e))
        .toList();
  }

  Future<OrderModel> getOrder(int id) async {
    final res = await _dio.get('/orders/$id');
    return OrderModel.fromJson(res.data['order']);
  }

  Future<OrderModel> createOrder({
    required String shippingAddress,
    required String phone,
    String? notes,
  }) async {
    final res = await _dio.post('/orders', data: {
      'shipping_address': shippingAddress,
      'phone': phone,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
    return OrderModel.fromJson(res.data['order']);
  }
}
