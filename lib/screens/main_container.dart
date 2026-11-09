import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'explore_screen.dart';
import 'genre_screen.dart';
import 'library_screen.dart';
import 'profile_screen.dart';
import 'admin_screen.dart';

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _currentIndex = 1; // Default to Explore

  final List<Widget> _screens = [
    const ProfileScreen(), // Me
    const ExploreScreen(),
    const GenreScreen(),
    const LibraryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDev = AuthService.isDeveloper;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: isDev
          ? FloatingActionButton.extended(
        backgroundColor: const Color(0xFFEC4899),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminStoryCreatorScreen()),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Creator Studio', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        indicatorColor: const Color(0xFF6366F1).withValues(alpha: 0.3),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Me'),
          NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Explore'),
          NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view), label: 'Genre'),
          NavigationDestination(icon: Icon(Icons.book_outlined), selectedIcon: Icon(Icons.book), label: 'Library'),
        ],
      ),
    );
  }
}
