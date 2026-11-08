import 'package:flutter/foundation.dart';

class UserProfile extends ChangeNotifier {
  String name;
  int points;
  int streak;

  UserProfile({
    required this.name,
    required this.points,
    required this.streak,
  });

  int get coins => points;
  int get readingStreak => streak;

  void addPoints(int amount) {
    points += amount;
    notifyListeners();
  }

  void addCoins(int amount) => addPoints(amount);
}
