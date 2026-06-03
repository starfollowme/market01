import 'category_model.dart';

class ProductImageModel {
  final int id;
  final String imagePath;

  ProductImageModel({required this.id, required this.imagePath});

  factory ProductImageModel.fromJson(Map<String, dynamic> json) => ProductImageModel(
        id: int.tryParse(json['id'].toString()) ?? 0,
        imagePath: json['image_path']?.toString() ?? '',
      );
}

class ProductRentalModel {
  final int id;
  final double price;
  final int cycleValue;
  final String isDelivery;

  ProductRentalModel({
    required this.id,
    required this.price,
    required this.cycleValue,
    required this.isDelivery,
  });

  factory ProductRentalModel.fromJson(Map<String, dynamic> json) => ProductRentalModel(
        id: int.tryParse(json['id'].toString()) ?? 0,
        price: double.tryParse(json['price'].toString()) ?? 0,
        cycleValue: int.tryParse(json['cycle_value'].toString()) ?? 0,
        isDelivery: json['is_delivery']?.toString() ?? 'pickup',
      );
}

class ProductModel {
  final int id;
  final String name;
  final String? code;
  final String? description;
  final String? condition;
  final CategoryModel? category;
  final List<ProductImageModel>? images;
  final List<ProductRentalModel>? rentals;

  ProductModel({
    required this.id,
    required this.name,
    this.code,
    this.description,
    this.condition,
    this.category,
    this.images,
    this.rentals,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: int.tryParse(json['id'].toString()) ?? 0,
        name: json['name']?.toString() ?? '',
        code: json['code']?.toString(),
        description: json['description']?.toString(),
        condition: json['condition']?.toString(),
        category: json['category'] != null
            ? CategoryModel.fromJson(json['category'])
            : null,
        images: json['images'] != null
            ? (json['images'] as List)
                .map((i) => ProductImageModel.fromJson(i))
                .toList()
            : null,
        rentals: json['rentals'] != null
            ? (json['rentals'] as List)
                .map((r) => ProductRentalModel.fromJson(r))
                .toList()
            : null,
      );

  // Helper method to get the primary rental option
  ProductRentalModel? get primaryRental {
    if (rentals != null && rentals!.isNotEmpty) {
      return rentals!.first;
    }
    return null;
  }

  // Helper method to get the primary image
  String? get primaryImageUrl {
    if (images != null && images!.isNotEmpty) {
      return images!.first.imagePath;
    }
    return null;
  }
}
