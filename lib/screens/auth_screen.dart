import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user_profile.dart';
import 'main_container.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _nameController;

  bool _isSignUp = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Prefill developer credentials for quick & seamless access
    _emailController = TextEditingController(text: AuthService.devEmail);
    _passwordController = TextEditingController(text: AuthService.devPassword);
    _nameController = TextEditingController(text: AuthService.devName);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submitAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final isDev = email.toLowerCase() == AuthService.devEmail.toLowerCase() ||
        email.toLowerCase().contains('dev') ||
        email.toLowerCase().contains('admin');

    final role = isDev ? 'developer' : 'reader';
    final name = email.toLowerCase() == AuthService.devEmail.toLowerCase()
        ? AuthService.devName
        : (_nameController.text.trim().isNotEmpty ? _nameController.text.trim() : email.split('@').first);

    try {
      if (_isSignUp) {
        final response = await AuthService.signUp(email, password, role: role);
        if (response.user != null) {
          if (mounted) {
            Provider.of<UserProfile>(context, listen: false).updateProfile(
              newName: name,
              newEmail: email,
              newRole: role,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('🎉 Account created! Logged in as ${isDev ? "Developer (Amoney)" : "Reader"}')),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MainContainer()),
            );
          }
        }
      } else {
        final response = await AuthService.signIn(email, password);
        if (response.user != null) {
          final userRole = email.toLowerCase() == AuthService.devEmail.toLowerCase() ||
              response.user?.userMetadata?['role']?.toString().toLowerCase() == 'developer' ||
              email.contains('dev') || email.contains('admin')
              ? 'developer'
              : 'reader';

          if (mounted) {
            Provider.of<UserProfile>(context, listen: false).updateProfile(
              newName: name,
              newEmail: email,
              newRole: userRole,
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MainContainer()),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⚠️ Auth Error: ${e.toString().replaceAll('Exception:', '')}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.auto_stories, size: 70, color: Color(0xFF6366F1)),
                  const SizedBox(height: 12),
                  const Text(
                    'StoryLand',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isSignUp ? 'Create your account' : 'Sign in to access your library & Creator Studio',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 32),

                  if (_isSignUp) ...[
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => _isSignUp && (val == null || val.isEmpty) ? 'Enter your name' : null,
                    ),
                    const SizedBox(height: 16),
                  ],

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                      hintText: 'user@example.com',
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty || !val.contains('@')) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val == null || val.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _isLoading ? null : _submitAuth,
                      child: _isLoading
                          ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                        _isSignUp ? 'Create Account' : 'Sign In',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => setState(() => _isSignUp = !_isSignUp),
                    child: Text(
                      _isSignUp ? 'Already have an account? Sign In' : "Don't have an account? Sign Up",
                      style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
