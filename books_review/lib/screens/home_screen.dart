import 'package:flutter/material.dart';
import '../models/user.dart';
import '../widgets/book_card.dart';
import 'book_detail_screen.dart';
import '../models/book.dart';
import '../services/api_service.dart';
import 'dart:convert';

class HomeScreen extends StatelessWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  Future<List<Book>> _fetchBooks() async {
    final res = await ApiService.getBooks();
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body) as List;
      return data.map((e) => Book.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load books');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: FutureBuilder<List<Book>>(
        future: _fetchBooks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}', style: const TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No books found.', style: Theme.of(context).textTheme.bodyLarge));
          }
          final books = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: books.length,
            itemBuilder: (context, i) => BookCard(
              book: books[i],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookDetailScreen(book: books[i], user: user),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
