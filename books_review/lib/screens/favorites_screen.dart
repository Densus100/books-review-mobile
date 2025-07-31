import 'package:flutter/material.dart';
import '../models/user.dart';
import '../widgets/book_card.dart';
import 'book_detail_screen.dart';
import '../models/book.dart';
import '../services/api_service.dart';
import 'dart:convert';


class FavoritesScreen extends StatefulWidget {
  final User user;
  const FavoritesScreen({super.key, required this.user});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<Book>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _favoritesFuture = _fetchFavorites();
  }

  Future<List<Book>> _fetchFavorites() async {
    final res = await ApiService.getFavorites(widget.user.token ?? '');
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body) as List;
      // If API returns favorite objects, fetch book details for each
      if (data.isNotEmpty && data.first is Map && data.first.containsKey('bookId')) {
        List<Book> books = [];
        for (var fav in data) {
          final bookRes = await ApiService.getBookById(fav['bookId'].toString());
          if (bookRes.statusCode == 200) {
            books.add(Book.fromJson(jsonDecode(bookRes.body)));
          }
        }
        return books;
      } else {
        // If API returns books directly
        return data.map((e) => Book.fromJson(e as Map<String, dynamic>)).toList();
      }
    } else {
      throw Exception('Failed to load favorites');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: FutureBuilder<List<Book>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('No favorites yet.', style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            );
          }
          final books = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: books.length,
            itemBuilder: (context, i) => BookCard(
              book: books[i],
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookDetailScreen(book: books[i], user: widget.user),
                  ),
                );
                setState(() {
                  _favoritesFuture = _fetchFavorites();
                });
              },
            ),
          );
        },
      ),
    );
  }
}
