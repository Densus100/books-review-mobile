

import 'package:flutter/material.dart';

import 'models/user.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const BookReviewApp());
}

class BookReviewApp extends StatefulWidget {
  const BookReviewApp({super.key});

  @override
  State<BookReviewApp> createState() => _BookReviewAppState();
}

class _BookReviewAppState extends State<BookReviewApp> {
  User? _user;
  int _selectedIndex = 0;

  void _onLogin(User user) {
    setState(() {
      _user = user;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _signOut() {
    setState(() {
      _user = null;
      _selectedIndex = 0;
    });
  }

  List<Widget> get _screens => [
        HomeScreen(user: _user!),
        SearchScreen(user: _user!),
        FavoritesScreen(user: _user!),
        ProfileScreen(user: _user!, onSignOut: _signOut),
      ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Review',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: _user == null
          ? LoginScreen(onLogin: _onLogin)
          : Scaffold(
              body: SafeArea(child: _screens[_selectedIndex]),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Theme.of(context).colorScheme.primary,
                unselectedItemColor: Colors.grey,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.search),
                    label: 'Search',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.favorite),
                    label: 'Favorites',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
    );
  }
}
