import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/novel.dart';
import '../services/auth_service.dart';
import '../services/supa_base_service.dart';
import 'reader_screen.dart';
import 'admin_screen.dart';

class NovelDetailScreen extends StatelessWidget {
  final Novel novel;

  const NovelDetailScreen({super.key, required this.novel});

  @override
  Widget build(BuildContext context) {
    final novelManager = Provider.of<NovelManager>(context);
    final isDev = AuthService.isDeveloper;

    return Scaffold(
      appBar: AppBar(
        title: Text(novel.title),
        actions: [
          if (isDev)
            IconButton(
              icon: const Icon(Icons.edit_note_rounded, color: Color(0xFFEC4899)),
              tooltip: 'Edit Novel / Add Chapter',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminStoryCreatorScreen(initialNovel: novel),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                    backgroundColor: Theme.of(context).colorScheme.surface,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Prominent Action Buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ReaderScreen(story: novel)),
                          );
                        },
                        icon: const Icon(Icons.menu_book, color: Colors.white),
                        label: const Text('Start Reading', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        side: BorderSide(color: novel.isBookmarked ? Colors.amber : const Color(0xFF6366F1), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        novelManager.toggleBookmark(novel.id);
                      },
                      icon: Icon(
                        novel.isBookmarked ? Icons.bookmark : Icons.bookmark_add_outlined,
                        color: novel.isBookmarked ? Colors.amber : const Color(0xFF6366F1),
                      ),
                      label: Text(
                        novel.isBookmarked ? 'In Library' : 'Add to Library',
                        style: TextStyle(
                          color: novel.isBookmarked ? Colors.amber : const Color(0xFF6366F1),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Developer Operations Bar
              if (isDev) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Text('Developer:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AdminStoryCreatorScreen(initialNovel: novel),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add, color: Color(0xFF6366F1), size: 18),
                        label: const Text('Add Chapter', style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold)),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Novel?'),
                              content: Text('Are you sure you want to delete "${novel.title}"?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await SupabaseService.deleteNovel(novel.id);
                            novelManager.deleteNovel(novel.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Novel deleted')));
                              Navigator.pop(context);
                            }
                          }
                        },
                        icon: const Icon(Icons.delete_forever, color: Colors.redAccent, size: 18),
                        label: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),
              const Text('Synopsis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                novel.synopsis.isNotEmpty ? novel.synopsis : 'No synopsis available.',
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 24),
              Text(
                'Chapters (${novel.chapters.length})',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              ...novel.chapters.map((chapter) => Card(
                color: Theme.of(context).colorScheme.surface,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(chapter.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isDev)
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18, color: Color(0xFF6366F1)),
                          tooltip: 'Edit Chapter Text',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdminStoryCreatorScreen(
                                  initialNovel: novel,
                                  initialChapterToEdit: chapter,
                                ),
                              ),
                            );
                          },
                        ),
                      const Icon(Icons.chevron_right, size: 20),
                    ],
                  ),
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
      ),
    );
  }
}
