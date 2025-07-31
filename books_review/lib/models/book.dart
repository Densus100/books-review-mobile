class Book {
  final String id;
  final String name;
  final String description;
  final String imagePath;
  final String releaseDate;
  final bool isActive;

  Book({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.releaseDate,
    required this.isActive,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imagePath: json['image_path'] ?? '',
      releaseDate: json['release_date'] ?? '',
      isActive: json['is_active'] ?? true,
    );
  }
}
