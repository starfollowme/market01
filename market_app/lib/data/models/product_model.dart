import 'category_model.dart';

class ProductModel {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final double price;
  final int stock;
  final String? image;
  final bool isActive;
  final CategoryModel? category;

  ProductModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.price,
    required this.stock,
    this.image,
    required this.isActive,
    this.category,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id'],
        name: json['name'],
        slug: json['slug'],
        description: json['description'],
        price: double.tryParse(json['price'].toString()) ?? 0,
        stock: json['stock'],
        image: json['image'],
        isActive: json['is_active'] == true || json['is_active'] == 1,
        category: json['category'] != null
            ? CategoryModel.fromJson(json['category'])
            : null,
      );
}
