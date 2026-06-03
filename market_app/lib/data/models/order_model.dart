class OrderItemModel {
  final int id;
  final int quantity;
  final double price;
  final Map<String, dynamic>? product;

  OrderItemModel({
    required this.id,
    required this.quantity,
    required this.price,
    this.product,
  });

  double get subtotal => price * quantity;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
        id: json['id'],
        quantity: json['quantity'],
        price: double.tryParse(json['price'].toString()) ?? 0,
        product: json['product'],
      );
}

class OrderModel {
  final int id;
  final String orderNumber;
  final double totalPrice;
  final String status;
  final String statusLabel;
  final String shippingAddress;
  final String phone;
  final String? notes;
  final String createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.totalPrice,
    required this.status,
    required this.statusLabel,
    required this.shippingAddress,
    required this.phone,
    this.notes,
    required this.createdAt,
    this.items = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id'],
        orderNumber: json['order_number'],
        totalPrice: double.tryParse(json['total_price'].toString()) ?? 0,
        status: json['status'],
        statusLabel: json['status_label'] ?? json['status'],
        shippingAddress: json['shipping_address'],
        phone: json['phone'],
        notes: json['notes'],
        createdAt: json['created_at'] ?? '',
        items: json['items'] != null
            ? (json['items'] as List)
                .map((e) => OrderItemModel.fromJson(e))
                .toList()
            : [],
      );
}
