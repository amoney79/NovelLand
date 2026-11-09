import 'package:flutter/foundation.dart';

class UserProfile extends ChangeNotifier {
  String name;
  String email;
  String role; // 'developer' or 'reader'

  UserProfile({
    required this.name,
    required this.email,
    required this.role,
  });

  bool get isDeveloper => role.toLowerCase() == 'developer' || role.toLowerCase() == 'admin';

  void updateProfile({String? newName, String? newEmail, String? newRole}) {
    if (newName != null) name = newName;
    if (newEmail != null) email = newEmail;
    if (newRole != null) role = newRole;
    notifyListeners();
  }
}
