import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/novel.dart';
import 'novel_detail_screen.dart';
import 'explore_screen.dart';
import 'admin_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String currentFilter = 'All'; // All, Reading, Unread, Finished

  @override
  Widget build(BuildContext context) {
    final novelManager = Provider.of<NovelManager>(context);
    final bookmarked = novelManager.bookmarkedNovels;

    // Apply status filter
    List<Novel> displayedNovels = bookmarked;
    if (currentFilter == 'Reading') {
      displayedNovels = bookmarked.where((n) => n.readingStatus == 'reading').toList();
    } else if (currentFilter == 'Unread') {
      displayedNovels = bookmarked.where((n) => n.readingStatus == 'unread').toList();
    } else if (currentFilter == 'Finished') {
      displayedNovels = bookmarked.where((n) => n.readingStatus == 'finished').toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Library 📖', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFFEC4899)),
            tooltip: 'Creator Studio',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminStoryCreatorScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Buttons Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: ['All', 'Reading', 'Unread', 'Finished'].map((filter) {
                final isSelected = currentFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) => setState(() => currentFilter = filter),
                    selectedColor: const Color(0xFF6366F1),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: displayedNovels.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No stories added to your library yet.', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ExploreScreen()));
                    },
                    child: const Text('Explore novels'),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: displayedNovels.length,
              itemBuilder: (context, index) {
                final novel = displayedNovels[index];
                return Card(
                  color: const Color(0xFF1E293B),
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
                    title: Text(novel.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Status: ${novel.readingStatus.toUpperCase()}', style: const TextStyle(color: Colors.amber, fontSize: 11)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
