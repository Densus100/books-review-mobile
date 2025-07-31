import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/book.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../models/review.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;
  final User user;
  const BookDetailScreen({super.key, required this.book, required this.user});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final _reviewController = TextEditingController();
  int _reviewRating = 5;
  bool _isFavorite = false;
  bool _loading = false;
  String? _error;
  List<Review> _reviews = [];
  String? _favoriteId;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
    _checkFavorite();
  }

  Future<void> _fetchReviews() async {
    try {
      final res = await ApiService.getReviewsByBookId(widget.book.id);
      if (res.statusCode == 200) {
        final List data = res.body.isNotEmpty ? List.from(jsonDecode(res.body)) : [];
        setState(() {
          _reviews = data.map((e) => Review.fromJson(e)).toList();
        });
      }
    } catch (e) {
      // ignore error
    }
  }

  Future<void> _checkFavorite() async {
    // Get all favorites for user and check if this book is in favorites
    final token = widget.user.token;
    if (token == null) return;
    try {
      final res = await ApiService.getFavorites(token);
      if (res.statusCode == 200) {
        final List data = res.body.isNotEmpty ? List.from(jsonDecode(res.body)) : [];
        final fav = data.firstWhere(
          (f) => f['bookId'].toString() == widget.book.id,
          orElse: () => null,
        );
        setState(() {
          _isFavorite = fav != null;
          _favoriteId = fav != null ? fav['id']?.toString() : null;
        });
      }
    } catch (e) {
      // ignore error
    }
  }

  Future<void> _addFavorite() async {
    setState(() { _loading = true; });
    final token = widget.user.token;
    if (token == null) return;
    try {
      final res = await ApiService.addFavorite(int.parse(widget.book.id), token);
      if (res.statusCode == 200 || res.statusCode == 201) {
        // Get new favorite id
        final data = jsonDecode(res.body);
        setState(() {
          _isFavorite = true;
          _favoriteId = data['id']?.toString();
        });
      }
    } catch (e) {
      setState(() { _error = 'Failed to add favorite'; });
    }
    setState(() { _loading = false; });
  }

  Future<void> _removeFavorite() async {
    setState(() { _loading = true; });
    final token = widget.user.token;
    if (token == null) {
      debugPrint('Remove favorite: token is null');
      setState(() { _loading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User token not found.')),
      );
      return;
    }
    try {
      // Use bookId for API as required by backend
      final String bookId = widget.book.id;
      debugPrint('Attempting to remove favorite with bookId: $bookId');
      final res = await ApiService.removeFavorite(bookId, token);
      debugPrint('Remove favorite response: ${res.statusCode} - ${res.body}');
      if (res.statusCode == 200 || res.statusCode == 204) {
        await _checkFavorite();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from favorites.')),
        );
      } else {
        await _checkFavorite();
        setState(() { _error = 'Failed to remove favorite'; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove favorite: ${res.statusCode} - ${res.body}')),
        );
      }
    } catch (e) {
      debugPrint('Exception removing favorite: $e');
      await _checkFavorite();
      setState(() { _error = 'Failed to remove favorite'; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove favorite (exception): $e')),
      );
    }
    setState(() { _loading = false; });
  }

  Future<void> _submitReview() async {
    final review = _reviewController.text.trim();
    if (review.isEmpty) return;
    setState(() { _loading = true; _error = null; });
    final token = widget.user.token;
    if (token == null) return;
    try {
      final res = await ApiService.createReview({
        'rating': _reviewRating,
        'comment': review, // API expects 'comment' field
        'bookId': int.parse(widget.book.id),
      }, token);
      if (res.statusCode == 200 || res.statusCode == 201) {
        _reviewController.clear();
        setState(() { _loading = false; _reviewRating = 5; });
        await _fetchReviews();
        return;
      } else {
        setState(() { _error = 'Failed to post review'; });
      }
    } catch (e) {
      setState(() { _error = 'Failed to post review'; });
    }
    setState(() { _loading = false; });
  }

  String _formatDate(String date) {
    if (date.isEmpty) return '';
    try {
      final d = DateTime.parse(date);
      return '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';
    } catch (_) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    return Scaffold(
      appBar: AppBar(
        title: Text(book.name),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: book.imagePath.isNotEmpty
                    ? Image.network(
                        book.imagePath.startsWith('http')
                            ? book.imagePath
                            : 'http://10.0.2.2:3000/images/' + book.imagePath.replaceAll(RegExp(r'^/'), ''),
                        width: 120,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(width: 120, height: 180, color: Colors.grey[300]),
                      )
                    : Container(width: 120, height: 180, color: Colors.grey[300]),
              ),
            ),
            const SizedBox(height: 16),
            Text(book.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(book.description, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            Text(
              'Release: ${_formatDate(book.releaseDate)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _isFavorite
                    ? ElevatedButton.icon(
                        onPressed: _loading ? null : _removeFavorite,
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        label: const Text('Remove from Favorites'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          foregroundColor: Colors.red,
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: _loading ? null : _addFavorite,
                        icon: const Icon(Icons.favorite_border),
                        label: const Text('Add to Favorites'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Reviews', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _reviews.isEmpty
                ? Container(
                    height: 120,
                    color: Colors.grey[100],
                    child: const Center(child: Text('No reviews yet.')),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _reviews.length,
                    itemBuilder: (context, i) {
                      final r = _reviews[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(r.review),
                          subtitle: Text('Rating: ${r.rating}'),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Your Rating:', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(width: 8),
                Row(
                  children: List.generate(5, (i) => IconButton(
                    icon: Icon(
                      i < _reviewRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    iconSize: 28,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      setState(() {
                        _reviewRating = i + 1;
                      });
                    },
                  )),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reviewController,
              decoration: InputDecoration(
                hintText: 'Add a review...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              minLines: 1,
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submitReview,
                child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Post Review'),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}
