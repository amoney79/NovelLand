import 'package:flutter_test/flutter_test.dart';
import 'package:storyland/main.dart';

void main() {
  testWidgets('StoryLandApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StoryLandApp());

    // Verify app starts cleanly
    expect(find.text('StoryLand'), findsWidgets);
  });
}
