import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
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
    final email = user.email?.toLowerCase() ?? '';

    return role == 'developer' ||
        role == 'admin' ||
        email.endsWith('@dev.com') ||
        email.endsWith('@admin.com') ||
        email.contains('dev') ||
        email.contains('admin');
  }

  // Sign Up with Email, Password and Role
  static Future<AuthResponse> signUp(String email, String password, {String role = 'reader'}) async {
    final client = _client;
    if (client == null) throw Exception('Supabase client not initialized.');
    return await client.auth.signUp(
      email: email,
      password: password,
      data: {'role': role},
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
