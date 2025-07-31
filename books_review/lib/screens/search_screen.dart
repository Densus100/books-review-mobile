import 'package:flutter/material.dart';
import '../models/user.dart';
import '../widgets/book_card.dart';
import '../models/book.dart';
import '../services/api_service.dart';
import 'book_detail_screen.dart';
import 'dart:convert';

class SearchScreen extends StatefulWidget {
  final User user;
  const SearchScreen({super.key, required this.user});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';
  List<Book> _books = [];
  List<Book> _filteredBooks = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiService.getBooks();
      if (res.statusCode == 200) {
        final List data = (res.body.isNotEmpty) ? List<Map<String, dynamic>>.from(List.from(jsonDecode(res.body))) : [];
        _books = data.map((e) => Book.fromJson(e)).toList();
        _filterBooks();
      } else {
        setState(() { _error = 'Failed to load books'; });
      }
    } catch (e) {
      setState(() { _error = 'Error: $e'; });
    }
    setState(() { _loading = false; });
  }

  void _filterBooks() {
    setState(() {
      if (_query.isEmpty) {
        _filteredBooks = _books;
      } else {
        _filteredBooks = _books.where((b) => b.name.toLowerCase().contains(_query.toLowerCase())).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search books...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              onChanged: (v) {
                _query = v;
                _filterBooks();
              },
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                    : _filteredBooks.isEmpty
                        ? Center(child: Text('No results.', style: Theme.of(context).textTheme.bodyLarge))
                        : RefreshIndicator(
                            onRefresh: _fetchBooks,
                            child: ListView.builder(
                              itemCount: _filteredBooks.length,
                              itemBuilder: (context, i) => BookCard(
                                book: _filteredBooks[i],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BookDetailScreen(book: _filteredBooks[i], user: widget.user),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
