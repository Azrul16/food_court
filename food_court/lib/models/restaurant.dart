class Restaurant {
  final String id;
  final String title;
  final String address;
  final String image;
  final String cuisine;

  Restaurant({
    required this.id,
    required this.title,
    required this.address,
    required this.image,
    required this.cuisine,
  });

  factory Restaurant.fromMap(Map<String, dynamic> data, String documentId) {
    return Restaurant(
      id: documentId,
      title: data['title'] ?? '',
      address: data['address'] ?? '',
      image: data['image'] ?? '',
      cuisine: data['cuisine'] ?? 'Unknown',
    );
  }

  static Restaurant fromFirestore(dynamic doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Restaurant.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'address': address,
      'image': image,
      'cuisine': cuisine,
    };
  }
}
