class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final int? productsCount;

  CategoryModel({required this.id, required this.name, required this.slug, this.productsCount});

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id'],
        name: json['name'],
        slug: json['slug'],
        productsCount: json['products_count'],
      );
}
