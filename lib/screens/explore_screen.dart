import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/novel.dart';
import '../services/supa_base_service.dart';
import 'novel_detail_screen.dart';
import 'admin_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late final PageController _pageController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _fetchNovels();
  }

  Future<void> _fetchNovels() async {
    try {
      final fetched = await SupabaseService.fetchNovels();
      debugPrint('Successfully fetched ${fetched.length} novels from Supabase.');
      if (mounted) {
        Provider.of<NovelManager>(context, listen: false).setNovels(fetched);
        _startTimer(fetched.length);
      }
    } catch (e) {
      debugPrint('❌ FETCH NOVELS ERROR: $e');
    }
  }

  void _startTimer(int count) {
    _timer?.cancel();
    if (count == 0) return;
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        int maxPages = count > 3 ? 3 : count;
        int nextPage = (_pageController.page?.round() ?? 0) + 1;
        if (nextPage >= maxPages) nextPage = 0;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final novelManager = Provider.of<NovelManager>(context);
    final novels = novelManager.novels;

    return Scaffold(
      appBar: AppBar(
        title: const Text('NovelUP Explore 📚', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFFEC4899)),
            tooltip: 'Creator Studio',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminStoryCreatorScreen()),
            ).then((_) => _fetchNovels()),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchNovels,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text('Featured Auto-Scroll Showcase', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 180,
              child: novels.isEmpty
                  ? const Center(child: Text('No featured novels available', style: TextStyle(color: Colors.grey)))
                  : PageView.builder(
                controller: _pageController,
                itemCount: novels.length > 3 ? 3 : novels.length,
                itemBuilder: (context, index) {
                  final novel = novels[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NovelDetailScreen(novel: novel))),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: NetworkImage(novel.imageUrl),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) {},
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        alignment: Alignment.bottomLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(novel.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            Text('By ${novel.author}', style: const TextStyle(fontSize: 12, color: Colors.white70)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('All Novels', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            if (novels.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: Text('No novels found.', style: TextStyle(color: Colors.grey))),
              )
            else
              ...novels.map((novel) => Card(
                color: const Color(0xFF1E293B),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                  subtitle: Text('${novel.genre}\n${novel.views} views', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NovelDetailScreen(novel: novel))),
                ),
              )),
          ],
        ),
      ),
    );
  }
}