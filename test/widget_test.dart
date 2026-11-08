import 'package:flutter_test/flutter_test.dart';
import 'package:thomas_trolls/main.dart';

void main() {
  testWidgets('Thomas & Trolls app smoke and interaction test', (WidgetTester tester) async {
    await tester.pumpWidget(const ThomasTrollsApp());
    await tester.pump();

    // Verify initial instructions are visible
    expect(find.textContaining('Press & hold screen to make Thomas go!'), findsOneWidget);
    expect(find.textContaining('🌟 Trolls: '), findsOneWidget);
    expect(find.text('Restart'), findsOneWidget);

    // Simulate touching and holding the screen
    final gesture = await tester.startGesture(const Offset(400, 250));
    await tester.pump(const Duration(milliseconds: 100));

    // Instructions should disappear once user starts playing
    expect(find.textContaining('Press & hold screen to make Thomas go!'), findsNothing);

    // Drag finger up to make a mountain
    await gesture.moveTo(const Offset(400, 120));
    await tester.pump(const Duration(milliseconds: 100));

    // Release touch
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 100));

    // Tap restart button
    await tester.tap(find.text('Restart'));
    await tester.pump();
  });
}
