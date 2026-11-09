import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/novel.dart';
import '../services/auth_service.dart';
import 'novel_detail_screen.dart';
import 'admin_screen.dart';

class GenreScreen extends StatefulWidget {
  const GenreScreen({super.key});

  @override
  State<GenreScreen> createState() => _GenreScreenState();
}

class _GenreScreenState extends State<GenreScreen> {
  String selectedGenre = 'Romance';
  final List<String> genres = ['Romance', 'Fiction', 'Teen', 'Sci-Fi', 'Action', 'Fantasy', 'Mystery'];

  @override
  Widget build(BuildContext context) {
    final novelManager = Provider.of<NovelManager>(context);
    final isDev = AuthService.isDeveloper;
    final filteredNovels = novelManager.novels.where((n) => n.genre.toLowerCase().contains(selectedGenre.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Genres 🗂️', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (isDev)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFFEC4899)),
              tooltip: 'Creator Studio (Dev)',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminStoryCreatorScreen()),
              ),
            ),
        ],
      ),
      body: Row(
        children: [
          // Vertical Sidebar
          Container(
            width: 110,
            color: Theme.of(context).colorScheme.surface,
            child: ListView.builder(
              itemCount: genres.length,
              itemBuilder: (context, index) {
                final genre = genres[index];
                final isSelected = genre == selectedGenre;
                return InkWell(
                  onTap: () => setState(() => selectedGenre = genre),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: isSelected ? const Color(0xFF6366F1) : Colors.transparent, width: 4)),
                      color: isSelected ? const Color(0xFF6366F1).withValues(alpha: 0.1) : Colors.transparent,
                    ),
                    child: Text(
                      genre,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? const Color(0xFF6366F1) : Colors.grey,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Novels panel on the right
          Expanded(
            child: filteredNovels.isEmpty
                ? const Center(child: Text('No novels found in this genre.', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredNovels.length,
              itemBuilder: (context, index) {
                final novel = filteredNovels[index];
                return Card(
                  color: Theme.of(context).colorScheme.surface,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        novel.imageUrl,
                        width: 50,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 50,
                          height: 70,
                          color: const Color(0xFF0F172A),
                          child: const Icon(Icons.book, size: 24, color: Color(0xFF6366F1)),
                        ),
                      ),
                    ),
                    title: Text(novel.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('By ${novel.author}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    trailing: IconButton(
                      icon: Icon(
                        novel.isBookmarked ? Icons.bookmark : Icons.bookmark_add_outlined,
                        color: novel.isBookmarked ? Colors.amber : Colors.grey,
                      ),
                      onPressed: () {
                        novelManager.toggleBookmark(novel.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(novel.isBookmarked ? 'Added to Library' : 'Removed from Library')),
                        );
                      },
                    ),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NovelDetailScreen(novel: novel))),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
