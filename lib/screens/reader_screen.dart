import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/novel.dart';
import '../models/user_profile.dart';

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

  @override
  Widget build(BuildContext context) {
    final novel = widget.story;
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
                      Provider.of<UserProfile>(context, listen: false).addPoints(50);
                      Provider.of<NovelManager>(context, listen: false).updateStatus(novel.id, 'finished');
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Finish Story (+50 Gems)', style: TextStyle(fontSize: 16)),
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
      // Linear chapter reading mode
      final chapter = novel.chapters.isNotEmpty
          ? novel.chapters[currentChapterIndex]
          : Chapter(number: 1, title: novel.title, content: novel.synopsis);

      final isLastChapter = currentChapterIndex >= novel.chapters.length - 1;

      return Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(novel.title, style: const TextStyle(fontSize: 16)),
              Text('Chapter ${chapter.number}/${novel.chapters.length}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
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
                      style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF1E293B),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: currentChapterIndex > 0
                        ? () => setState(() => currentChapterIndex--)
                        : null,
                    child: const Text('Previous'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLastChapter ? Colors.green : const Color(0xFF6366F1),
                    ),
                    onPressed: () {
                      if (isLastChapter) {
                        Provider.of<UserProfile>(context, listen: false).addPoints(50);
                        Provider.of<NovelManager>(context, listen: false).updateStatus(novel.id, 'finished');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('🎉 Completed novel! Earned 50 Gems!')),
                        );
                        Navigator.pop(context);
                      } else {
                        setState(() => currentChapterIndex++);
                        Provider.of<NovelManager>(context, listen: false).updateStatus(novel.id, 'reading');
                      }
                    },
                    child: Text(isLastChapter ? 'Finish (+50 Gems)' : 'Next Chapter'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
