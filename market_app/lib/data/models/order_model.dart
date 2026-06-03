import 'product_model.dart';

class PaymentModel {
  final int id;
  final double amount;
  final String status;
  final String paymentMethod;

  PaymentModel({
    required this.id,
    required this.amount,
    required this.status,
    required this.paymentMethod,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
        id: int.tryParse(json['id'].toString()) ?? 0,
        amount: double.tryParse(json['amount'].toString()) ?? 0,
        status: json['status']?.toString() ?? 'pending',
        paymentMethod: json['payment_method']?.toString() ?? '',
      );
}

class OrderModel {
  final int id;
  final String orderCode;
  final String startTime;
  final String endTime;
  final String? returnedAt;
  final String status;
  final String deliveryMethod;
  final ProductModel? product; 
  final ProductRentalModel? productRental;
  final PaymentModel? payment;
  final String createdAt;

  OrderModel({
    required this.id,
    required this.orderCode,
    required this.startTime,
    required this.endTime,
    this.returnedAt,
    required this.status,
    required this.deliveryMethod,
    this.product,
    this.productRental,
    this.payment,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // In OrderRentalApiController, we return:
    // Order::with(['productRental.product.images', 'payment', 'address'])
    
    ProductModel? pModel;
    ProductRentalModel? prModel;

    if (json['product_rental'] != null) {
      prModel = ProductRentalModel.fromJson(json['product_rental']);
      if (json['product_rental']['product'] != null) {
        pModel = ProductModel.fromJson(json['product_rental']['product']);
      }
    }

    return OrderModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      orderCode: json['order_code']?.toString() ?? '',
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      returnedAt: json['returned_at']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      deliveryMethod: json['delivery_method']?.toString() ?? 'pickup',
      product: pModel,
      productRental: prModel,
      payment: json['payment'] != null ? PaymentModel.fromJson(json['payment']) : null,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  double get totalPrice => payment?.amount ?? 0;
  
  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Menunggu Pembayaran';
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'ongoing':
        return 'Sedang Berlangsung';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      case 'penalty':
        return 'Denda';
      case 'returned':
        return 'Dikembalikan';
      default:
        return status;
    }
  }
}
