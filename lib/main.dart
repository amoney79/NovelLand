import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'screens/main_container.dart';
import 'screens/auth_screen.dart';
import 'models/user_profile.dart';
import 'models/novel.dart';
import 'models/app_settings.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://paoqyeaslvjrowvirmqn.supabase.co',
    publishableKey: 'sb_publishable_yUMXJ4XiauOZOpa-biiHcQ_eyQSNjGm',
  );

  runApp(const StoryLandApp());
}

class StoryLandApp extends StatelessWidget {
  const StoryLandApp({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final initialEmail = user?.email ?? 'reader@storyland.com';
    final initialName = initialEmail.split('@').first;
    final initialRole = AuthService.isDeveloper ? 'developer' : 'reader';

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppSettings()),
        ChangeNotifierProvider(create: (_) => UserProfile(name: initialName, email: initialEmail, role: initialRole)),
        ChangeNotifierProvider(create: (_) => NovelManager()),
      ],
      child: Consumer<AppSettings>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'StoryLand',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            home: AuthService.currentUser != null ? const MainContainer() : const AuthScreen(),
          );
        },
      ),
    );
  }
}
