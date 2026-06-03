import 'product_model.dart';

class CartModel {
  final int id;
  final int userId;
  final int productId;
  int quantity;
  final ProductModel? product;

  CartModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    this.product,
  });

  double get subtotal => (product?.price ?? 0) * quantity;

  factory CartModel.fromJson(Map<String, dynamic> json) => CartModel(
        id: json['id'],
        userId: json['user_id'],
        productId: json['product_id'],
        quantity: json['quantity'],
        product: json['product'] != null
            ? ProductModel.fromJson(json['product'])
            : null,
      );
}
