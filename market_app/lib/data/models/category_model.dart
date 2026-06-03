class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final int? productsCount;
  final String? image;

  CategoryModel({required this.id, required this.name, required this.slug, this.productsCount, this.image});

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: int.tryParse(json['id'].toString()) ?? 0,
        name: json['name'].toString(),
        slug: json['slug'].toString(),
        productsCount: json['products_count'] != null ? int.tryParse(json['products_count'].toString()) : null,
        image: json['image']?.toString(),
      );
}
