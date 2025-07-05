class Review {
  final String id;
  final String userId;
  final String targetId; // Could be dishId or restaurantId
  final String description;
  final int stars;

  Review({
    required this.id,
    required this.userId,
    required this.targetId,
    required this.description,
    required this.stars,
  });

  factory Review.fromMap(Map<String, dynamic> data, String documentId) {
    return Review(
      id: documentId,
      userId: data['userId'] ?? '',
      targetId: data['targetId'] ?? '',
      description: data['description'] ?? '',
      stars: data['stars'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'targetId': targetId,
      'description': description,
      'stars': stars,
    };
  }
}
