class Review {
  final String id;
  final String userId;
  final String bookId;
  final int rating;
  final String review;
  final bool? active;

  Review({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.rating,
    required this.review,
    this.active,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      bookId: json['bookId']?.toString() ?? '',
      rating: json['rating'] ?? 0,
      review: json['review'] ?? json['comment'] ?? '',
      active: json['active'],
    );
  }
}
