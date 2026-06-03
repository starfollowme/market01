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
    return OrderModel.fromJson(res.data['data']);
  }

  Future<OrderModel> createOrder({
    required int productRentalId,
    required String startTime,
    required String endTime,
    required String deliveryMethod,
    int? userAddressId,
  }) async {
    final res = await _dio.post('/orders', data: {
      'product_rental_id': productRentalId,
      'start_time': startTime,
      'end_time': endTime,
      'delivery_method': deliveryMethod,
      if (userAddressId != null) 'user_address_id': userAddressId,
    });
    return OrderModel.fromJson(res.data['data']);
  }
}
