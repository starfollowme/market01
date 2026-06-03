import '../../core/network/api_client.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class ProductService {
  final _dio = ApiClient.instance;

  Future<Map<String, dynamic>> getProducts({
    String? search,
    String? category,
    int page = 1,
  }) async {
    final res = await _dio.get('/products', queryParameters: {
      if (search != null && search.isNotEmpty) 'search': search,
      if (category != null && category.isNotEmpty) 'category': category,
      'page': page,
      'per_page': 12,
    });

    final data = res.data;
    final products = (data['data'] as List)
        .map((e) => ProductModel.fromJson(e))
        .toList();

    return {
      'products': products,
      'current_page': data['current_page'],
      'last_page': data['last_page'],
    };
  }

  Future<Map<String, dynamic>> getProduct(int id) async {
    final res = await _dio.get('/products/$id');
    return {
      'product': ProductModel.fromJson(res.data['data']),
      'related': [], // TODO: implement related products API
    };
  }

  Future<List<CategoryModel>> getCategories() async {
    final res = await _dio.get('/categories');
    return (res.data as List).map((e) => CategoryModel.fromJson(e)).toList();
  }
}
