import 'package:flutter_test/flutter_test.dart';
import 'package:thomas_trolls/game/game_controller.dart';
import 'package:thomas_trolls/game/models/troll_data.dart';
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

  testWidgets('shows victory celebration when arriving at Troll Village', (WidgetTester tester) async {
    final testController = GameController();
    testController.initialize(800, 400);

    for (int i = 0; i < 10; i++) {
      final t = TrollData(
        x: testController.trainX,
        y: testController.track.getHeightAt(testController.trainX),
        type: TrollType.poppy,
      );
      testController.trolls.clear();
      testController.trolls.add(t);
      testController.onPointerDown(const Offset(400, 200));
      testController.update(0.1);
    }

    expect(testController.hasWon, isTrue);
    expect(testController.collectedTrollsCount, equals(10));
    expect(testController.villageX, isNotNull);
  });
}
