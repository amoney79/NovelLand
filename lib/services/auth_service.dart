import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Current User Session
  static User? get currentUser => _client.auth.currentUser;

  // Sign Up with Email & Password
  static Future<AuthResponse> signUp(String email, String password) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  // Sign In with Email & Password
  static Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  // Sign Out
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }
}