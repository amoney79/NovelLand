import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/novel.dart';
import '../models/app_settings.dart';

class ReaderScreen extends StatefulWidget {
  final Novel story;
  const ReaderScreen({
    super.key,
    required this.story,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  int currentNodeId = 0;
  int currentChapterIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: currentChapterIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final novel = widget.story;
    final settings = Provider.of<AppSettings>(context);
    final isInteractive = novel.nodes.isNotEmpty;

    if (isInteractive) {
      final currentNode = novel.nodes.firstWhere(
        (node) => node.id == currentNodeId,
        orElse: () => novel.nodes.first,
      );

      return Scaffold(
        appBar: AppBar(title: Text(novel.title)),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentNode.title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
              ),
              const SizedBox(height: 16),
              Text(
                currentNode.content,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
              const Spacer(),
              if (currentNode.choices.isEmpty)
                Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                      Provider.of<NovelManager>(context, listen: false).updateStatus(novel.id, 'finished');
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Finish Story', style: TextStyle(fontSize: 16)),
                  ),
                )
              else
                ...currentNode.choices.map((choice) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: const Color(0xFF1E293B),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        setState(() {
                          currentNodeId = choice.nextNodeId;
                        });
                      },
                      child: Text(choice.text, style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                )),
            ],
          ),
        ),
      );
    } else {
      // Linear chapter reading mode with configured transition mode
      final chapters = novel.chapters.isNotEmpty
          ? novel.chapters
          : [Chapter(number: 1, title: novel.title, content: novel.synopsis)];

      final transitionMode = settings.readingTransitionMode;

      return Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(novel.title, style: const TextStyle(fontSize: 16)),
              Text('Chapter ${currentChapterIndex + 1}/${chapters.length}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: transitionMode == 'Horizontal Swipe'
                    ? PageView.builder(
                  controller: _pageController,
                  itemCount: chapters.length,
                  onPageChanged: (index) {
                    setState(() => currentChapterIndex = index);
                    Provider.of<NovelManager>(context, listen: false).updateStatus(novel.id, 'reading');
                  },
                  itemBuilder: (context, index) {
                    final chapter = chapters[index];
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chapter.title,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            chapter.content,
                            style: const TextStyle(fontSize: 16, height: 1.6),
                          ),
                        ],
                      ),
                    );
                  },
                )
                    : transitionMode == 'Vertical Scroll'
                    ? ListView.builder(
                  padding: const EdgeInsets.all(20.0),
                  itemCount: chapters.length,
                  itemBuilder: (context, index) {
                    final chapter = chapters[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 32.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chapter.title,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            chapter.content,
                            style: const TextStyle(fontSize: 16, height: 1.6),
                          ),
                          const Divider(height: 40),
                        ],
                      ),
                    );
                  },
                )
                    : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chapters[currentChapterIndex].title,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        chapters[currentChapterIndex].content,
                        style: const TextStyle(fontSize: 16, height: 1.6),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Chapter Control Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Theme.of(context).colorScheme.surface,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: currentChapterIndex > 0
                          ? () {
                        setState(() => currentChapterIndex--);
                        if (transitionMode == 'Horizontal Swipe' && _pageController.hasClients) {
                          _pageController.animateToPage(currentChapterIndex, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                        }
                      }
                          : null,
                      icon: const Icon(Icons.chevron_left),
                      label: const Text('Previous'),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (currentChapterIndex >= chapters.length - 1) ? Colors.green : const Color(0xFF6366F1),
                      ),
                      onPressed: () {
                        if (currentChapterIndex >= chapters.length - 1) {
                          Provider.of<NovelManager>(context, listen: false).updateStatus(novel.id, 'finished');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('🎉 Completed novel!')),
                          );
                          Navigator.pop(context);
                        } else {
                          setState(() => currentChapterIndex++);
                          if (transitionMode == 'Horizontal Swipe' && _pageController.hasClients) {
                            _pageController.animateToPage(currentChapterIndex, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                          }
                          Provider.of<NovelManager>(context, listen: false).updateStatus(novel.id, 'reading');
                        }
                      },
                      label: Text(currentChapterIndex >= chapters.length - 1 ? 'Finish' : 'Next Chapter'),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
