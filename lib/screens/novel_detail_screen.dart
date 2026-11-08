import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/novel.dart';
import 'reader_screen.dart';
import 'admin_screen.dart';

class NovelDetailScreen extends StatelessWidget {
  final Novel novel;

  const NovelDetailScreen({super.key, required this.novel});

  @override
  Widget build(BuildContext context) {
    final novelManager = Provider.of<NovelManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(novel.title),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  novel.imageUrl,
                  height: 220,
                  width: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 220,
                    width: 150,
                    color: const Color(0xFF1E293B),
                    child: const Icon(Icons.book, size: 60, color: Color(0xFF6366F1)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                novel.title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                'By ${novel.author}',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Chip(
                  label: Text(novel.genre),
                  backgroundColor: const Color(0xFF6366F1).withValues(alpha: 0.2),
                  labelStyle: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                Chip(
                  avatar: const Icon(Icons.remove_red_eye, size: 16, color: Colors.amber),
                  label: Text('${novel.views} Views'),
                  backgroundColor: const Color(0xFF1E293B),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFF6366F1),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ReaderScreen(story: novel)),
                      );
                    },
                    icon: const Icon(Icons.menu_book),
                    label: const Text('Start Reading', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    side: BorderSide(color: novel.isBookmarked ? Colors.amber : Colors.grey),
                  ),
                  onPressed: () {
                    novelManager.toggleBookmark(novel.id);
                  },
                  icon: Icon(
                    novel.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: novel.isBookmarked ? Colors.amber : Colors.grey,
                  ),
                  label: Text(
                    novel.isBookmarked ? 'Saved' : 'Bookmark',
                    style: TextStyle(color: novel.isBookmarked ? Colors.amber : Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Synopsis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              novel.synopsis,
              style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.white70),
            ),
            const SizedBox(height: 24),
            Text(
              'Chapters (${novel.chapters.length})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...novel.chapters.map((chapter) => Card(
              color: const Color(0xFF1E293B),
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(chapter.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ReaderScreen(story: novel)),
                  );
                },
              ),
            )),
          ],
        ),
      ),
    );
  }
}
