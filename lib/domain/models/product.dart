class Product {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String brand;
  final String thumbnail;
  final List<String> images;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    this.discountPercentage = 0,
    required this.rating,
    this.stock = 0,
    this.brand = '',
    required this.thumbnail,
    required this.images,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: (map['id'] as num?)?.toInt() ?? 0,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      discountPercentage:
          (map['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      brand: map['brand'] as String? ?? '',
      thumbnail: map['thumbnail'] as String? ?? '',
      images: (map['images'] as List<dynamic>?)
              ?.map((e) => e as String? ?? '')
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'discountPercentage': discountPercentage,
      'rating': rating,
      'stock': stock,
      'brand': brand,
      'thumbnail': thumbnail,
      'images': images,
    };
  }
}
