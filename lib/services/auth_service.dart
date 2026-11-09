import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static const String devEmail = 'mackenziejoseph396@gmail.com';
  static const String devName = 'Amoney';
  static const String devPassword = 'Storyland100@';

  static SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  // Current User Session
  static User? get currentUser {
    try {
      return _client?.auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  // Check if current logged-in user is Developer / Admin
  static bool get isDeveloper {
    final user = currentUser;
    if (user == null) return false;

    final role = user.userMetadata?['role']?.toString().toLowerCase() ?? '';
    final email = user.email?.toLowerCase().trim() ?? '';

    return email == devEmail.toLowerCase() ||
        role == 'developer' ||
        role == 'admin' ||
        email.endsWith('@dev.com') ||
        email.endsWith('@admin.com') ||
        email.contains('dev') ||
        email.contains('admin');
  }

  // Sign Up with Email & Password
  static Future<AuthResponse> signUp(String email, String password, {String role = 'reader'}) async {
    final client = _client;
    if (client == null) throw Exception('Supabase client not initialized.');
    final userRole = (email.toLowerCase().trim() == devEmail.toLowerCase() ||
        email.toLowerCase().contains('dev') ||
        email.toLowerCase().contains('admin'))
        ? 'developer'
        : role;

    return await client.auth.signUp(
      email: email,
      password: password,
      data: {
        'role': userRole,
        'name': email.toLowerCase().trim() == devEmail.toLowerCase() ? devName : email.split('@').first,
      },
    );
  }

  // Sign In with Email & Password
  static Future<AuthResponse> signIn(String email, String password) async {
    final client = _client;
    if (client == null) throw Exception('Supabase client not initialized.');
    return await client.auth.signInWithPassword(email: email, password: password);
  }

  // Sign Out
  static Future<void> signOut() async {
    final client = _client;
    if (client == null) return;
    await client.auth.signOut();
  }
}
