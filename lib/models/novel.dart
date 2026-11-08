import 'package:flutter/foundation.dart';

class StoryChoice {
  final String text;
  final int nextNodeId;

  StoryChoice({required this.text, required this.nextNodeId});
}

class StoryNode {
  final int id;
  final String title;
  final String content;
  final List<StoryChoice> choices;

  StoryNode({
    required this.id,
    required this.title,
    required this.content,
    required this.choices,
  });
}

class Chapter {
  final int number;
  final String title;
  final String content;

  Chapter({required this.number, required this.title, required this.content});
}

class Novel {
  final String id;
  final String title;
  final String author;
  final String genre;
  final String imageUrl;
  final String synopsis;
  final String views;
  final List<Chapter> chapters;
  final List<StoryNode> nodes;
  bool isBookmarked;
  String readingStatus; // 'unread', 'reading', 'finished'

  Novel({
    required this.id,
    required this.title,
    required this.author,
    required this.genre,
    required this.imageUrl,
    required this.synopsis,
    required this.views,
    required this.chapters,
    this.nodes = const [],
    this.isBookmarked = false,
    this.readingStatus = 'unread',
  });
}

typedef Story = Novel;

class NovelManager extends ChangeNotifier {
  final List<Novel> _novels = [
    Novel(
      id: '1',
      title: 'Married To The President',
      author: 'Elena Vance',
      genre: 'Romance',
      imageUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=500',
      synopsis: 'A contract marriage turns into an unpredictable emotional rollercoaster when dark corporate secrets and true romance collide.',
      views: '517.3K',
      isBookmarked: true,
      readingStatus: 'reading',
      chapters: [
        Chapter(number: 1, title: 'Chapter 1: The Contract', content: 'The rain poured heavily against the glass windows of the executive suite. Clara signed her name on the dotted line without looking back...'),
        Chapter(number: 2, title: 'Chapter 2: Unexpected Rules', content: '“There are three things you must never do in this house,” Ethan murmured, leaning closer with an unfathomable gaze...'),
      ],
    ),
    Novel(
      id: '2',
      title: 'Neon Shadows',
      author: 'CyberCrime',
      genre: 'Sci-Fi',
      imageUrl: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=500',
      synopsis: 'You wake up in a neon-lit alley in Neo-Seattle with a glowing data-shard. Navigate your destiny in this interactive branching adventure.',
      views: '890.1K',
      isBookmarked: true,
      readingStatus: 'reading',
      chapters: [
        Chapter(number: 1, title: 'Chapter 1: Awakening', content: 'You wake up in a neon-lit alley in Neo-Seattle. A glowing data-shard pulses in your cybernetic palm.'),
      ],
      nodes: [
        StoryNode(
          id: 0,
          title: 'Awakening',
          content: 'You wake up in a neon-lit alley in Neo-Seattle. A glowing data-shard pulses in your cybernetic palm.',
          choices: [
            StoryChoice(text: 'Examine the data-shard closely', nextNodeId: 1),
            StoryChoice(text: 'Run away before anyone spots you', nextNodeId: 2),
          ],
        ),
        StoryNode(
          id: 1,
          title: 'The Secret Message',
          content: 'The shard projects a holographic map pointing to an abandoned subway station downtown.',
          choices: [
            StoryChoice(text: 'Head to the subway station', nextNodeId: 3),
          ],
        ),
        StoryNode(
          id: 2,
          title: 'Shadows in the Alley',
          content: 'As you turn to run, a drone beams a red tracking laser onto your chest. Game Over... for now.',
          choices: [],
        ),
        StoryNode(
          id: 3,
          title: 'The Subway Station',
          content: 'You arrive safely at the old platform, hearing the faint hum of an incoming mag-train.',
          choices: [],
        ),
      ],
    ),
    Novel(
      id: '3',
      title: 'Son-in-Law of the Wealthiest Family',
      author: 'Marcus Wright',
      genre: 'Fiction',
      imageUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=500',
      synopsis: 'Despised by his in-laws for three years, he suddenly discovers he is the sole heir to a trillion-dollar global empire.',
      views: '890.1K',
      isBookmarked: false,
      readingStatus: 'unread',
      chapters: [
        Chapter(number: 1, title: 'Chapter 1: The Scorned Heir', content: 'They threw the divorce papers across the polished floor without a second thought, completely unaware of who had just stepped out of the luxury limousine outside...'),
      ],
    ),
    Novel(
      id: '4',
      title: 'Midnight Alpha',
      author: 'Sarah Jenkins',
      genre: 'Teen',
      imageUrl: 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=500',
      synopsis: 'A high school outcast discovers she is bound by blood and moonlight to the campus pack leader.',
      views: '320.4K',
      isBookmarked: true,
      readingStatus: 'finished',
      chapters: [
        Chapter(number: 1, title: 'Chapter 1: Full Moon', content: 'The locker doors slammed shut echoing down the empty hallway as the silver light flooded through the skylight...'),
      ],
    ),
  ];

  List<Novel> get novels => _novels;
  List<Novel> get stories => _novels;
  List<Novel> get bookmarkedNovels => _novels.where((n) => n.isBookmarked).toList();

  void toggleBookmark(String id) {
    final novel = _novels.firstWhere((n) => n.id == id);
    novel.isBookmarked = !novel.isBookmarked;
    if (novel.isBookmarked && novel.readingStatus == 'unread') {
      novel.readingStatus = 'reading';
    }
    notifyListeners();
  }

  void updateStatus(String id, String status) {
    final novel = _novels.firstWhere((n) => n.id == id);
    novel.readingStatus = status;
    notifyListeners();
  }

  void addNovel(Novel novel) {
    _novels.insert(0, novel);
    notifyListeners();
  }

  void addStory(Novel story) => addNovel(story);
}

typedef StoryManager = NovelManager;
