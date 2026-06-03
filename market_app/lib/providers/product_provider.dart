import 'package:flutter/foundation.dart';
import '../data/models/category_model.dart';
import '../data/models/product_model.dart';
import '../data/services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final _service = ProductService();

  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String _search = '';
  String _selectedCategory = '';

  List<ProductModel> get products => _products;
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String get selectedCategory => _selectedCategory;

  Future<void> loadCategories() async {
    try {
      _categories = await _service.getCategories();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadProducts({bool refresh = false}) async {
    if (refresh) {
      _products = [];
      _currentPage = 1;
      _hasMore = true;
    }
    if (!_hasMore || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _service.getProducts(
        search: _search,
        category: _selectedCategory,
        page: _currentPage,
      );
      final newProducts = result['products'] as List<ProductModel>;
      _products.addAll(newProducts);
      _currentPage++;
      _hasMore = result['current_page'] < result['last_page'];
    } catch (e) {
      print("ERROR FETCHING PRODUCTS: $e");
      _hasMore = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearch(String value) {
    _search = value;
    loadProducts(refresh: true);
  }

  void setCategory(String slug) {
    _selectedCategory = _selectedCategory == slug ? '' : slug;
    loadProducts(refresh: true);
  }

  Future<Map<String, dynamic>> getProduct(String slug) async {
    return await _service.getProduct(slug);
  }
}
