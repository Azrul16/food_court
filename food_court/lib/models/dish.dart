class Dish {
  final String id;
  final String restaurantId;
  final String title;
  final String slogan;
  final double price;
  final String image;
  final String cuisine;

  Dish({
    required this.id,
    required this.restaurantId,
    required this.title,
    required this.slogan,
    required this.price,
    required this.image,
    required this.cuisine,
  });

  factory Dish.fromMap(Map<String, dynamic> data, String documentId) {
    return Dish(
      id: documentId,
      restaurantId: data['restaurantId'] ?? '',
      title: data['title'] ?? '',
      slogan: data['slogan'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      image: data['image'] ?? '',
      cuisine: data['cuisine'] ?? 'Unknown',
    );
  }

  static Dish fromFirestore(dynamic doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Dish.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'restaurantId': restaurantId,
      'title': title,
      'slogan': slogan,
      'price': price,
      'image': image,
      'cuisine': cuisine,
    };
  }
}
