class Product {
  final int id;
  final String name;
  final String category;
  final int price;
  final String? imageUrl;
  final String description; 

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.imageUrl,
    this.description = 'Rasa otentik khas Pak Zaini', 
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      price: json['price'],
      imageUrl: json['image_url'],
      description: json['description'] ?? 'Rasa otentik khas Pak Zaini',
    );
  }
}
