import 'package:flutter/material.dart';
import '../models/book.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;
  const BookCard({super.key, required this.book, this.onTap});

  @override
  Widget build(BuildContext context) {
    String imageUrl = book.imagePath;
    if (!_isValidImageUrl(imageUrl) && imageUrl.isNotEmpty) {
      // Use emulator-friendly base URL
      imageUrl = 'http://10.0.2.2:3000/images/' + imageUrl.replaceAll(RegExp(r'^/'), '');
    }
    String releaseYear = '';
    if (book.releaseDate.isNotEmpty) {
      try {
        releaseYear = DateTime.parse(book.releaseDate).year.toString();
      } catch (_) {
        releaseYear = book.releaseDate;
      }
    }
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageUrl.isNotEmpty
                    ? Image.network(imageUrl, width: 60, height: 90, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(width: 60, height: 90, color: Colors.grey[300]))
                    : Container(width: 60, height: 90, color: Colors.grey[300]),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(book.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(book.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    Text('Release: $releaseYear', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static bool _isValidImageUrl(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }
}
