import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/main_container.dart';
import 'models/user_profile.dart';
import 'models/novel.dart';

void main() {
  runApp(const StoryLandApp());
}

class StoryLandApp extends StatelessWidget {
  const StoryLandApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProfile(name: "Aria Stark", points: 1250, streak: 7)),
        ChangeNotifierProvider(create: (_) => NovelManager()),
      ],
      child: MaterialApp(
        title: 'StoryLand',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const MainContainer(),
      ),
    );
  }
}
