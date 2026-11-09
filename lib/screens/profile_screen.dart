import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../models/app_settings.dart';
import '../services/auth_service.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProfile>(context);
    final settings = Provider.of<AppSettings>(context);
    final isDev = AuthService.isDeveloper || user.isDeveloper;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // User Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: const Color(0xFF6366F1),
                    child: Icon(isDev ? Icons.developer_mode : Icons.person, size: 35, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name.isNotEmpty ? user.name : (AuthService.currentUser?.email?.split('@').first ?? 'Reader'),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AuthService.currentUser?.email ?? user.email,
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDev ? const Color(0xFFEC4899).withValues(alpha: 0.2) : Colors.indigo.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text('Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),

            // Real Dark Mode Switch
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Light and Dark Modes'),
              value: settings.isDarkMode,
              onChanged: (val) => settings.toggleTheme(val),
              secondary: Icon(settings.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            ),

            // Push Notifications Switch
            SwitchListTile(
              title: const Text('Notifications'),
              subtitle: const Text('Get notified when new chapters are published'),
              value: settings.pushNotificationsEnabled,
              onChanged: (val) => settings.togglePushNotifications(val),
              secondary: const Icon(Icons.notifications),
            ),

            // Chapter Reading Transition Mode Dropdown
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Chapter Navigation Gesture'),
              subtitle: Text('Current mode: ${settings.readingTransitionMode}'),
              trailing: DropdownButton<String>(
                value: settings.readingTransitionMode,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'Horizontal Swipe', child: Text('Horizontal Swipe')),
                  DropdownMenuItem(value: 'Vertical Scroll', child: Text('Vertical Scroll')),
                  DropdownMenuItem(value: 'Buttons', child: Text('Buttons')),
                ],
                onChanged: (val) {
                  if (val != null) settings.setReadingTransitionMode(val);
                },
              ),
            ),

            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('App Language'),
              trailing: const Text('English', style: TextStyle(color: Colors.grey)),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About StoryLand'),
              trailing: const Text('v1.0.2', style: TextStyle(color: Colors.grey)),
              onTap: () {},
            ),

            const SizedBox(height: 32),

            // Sign Out Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  await AuthService.signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const AuthScreen()),
                          (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: const Text('Sign Out', style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
