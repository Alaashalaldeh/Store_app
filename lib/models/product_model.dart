class Product {
  final int id;
  final String name;
  final double price;
  final String image;
  final String? description;
  final int categoryId;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    this.description,
    required this.categoryId,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as int,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        image: json['image'] as String,
        description: json['description'] as String?,
        categoryId: json['category_id'] as int,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'image': image,
        'description': description,
        'category_id': categoryId,
      };

  Map<String, dynamic> toCartMap() => {
        'id': id,
        'name': name,
        'price': price,
        'image': image,
      };
}
