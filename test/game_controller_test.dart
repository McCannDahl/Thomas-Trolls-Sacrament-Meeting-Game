import 'package:flutter_test/flutter_test.dart';
import 'package:thomas_trolls/game/game_controller.dart';
import 'package:thomas_trolls/game/models/troll_data.dart';

void main() {
  group('GameController', () {
    test('initializes with zero speed, 3 carts behind Thomas, and spawns initial track and trolls', () {
      final controller = GameController();
      controller.initialize(800, 400);

      expect(controller.isInitialized, isTrue);
      expect(controller.trainSpeed, equals(0.0));
      expect(controller.touchActive, isFalse);
      expect(controller.track.points, isNotEmpty);
      expect(controller.trolls, isNotEmpty);
      expect(controller.collectedTrollsCount, equals(0));
      expect(controller.hasWon, isFalse);

      // Verify 3 carts behind Thomas in descending X order
      final cart0 = controller.getCartX(0);
      final cart1 = controller.getCartX(1);
      final cart2 = controller.getCartX(2);

      expect(cart0, lessThan(controller.trainX));
      expect(cart1, lessThan(cart0));
      expect(cart2, lessThan(cart1));
    });

    test('accelerates when touch is active', () {
      final controller = GameController();
      controller.initialize(800, 400);

      controller.onPointerDown(const Offset(400, 200));
      expect(controller.touchActive, isTrue);

      controller.update(0.5);

      expect(controller.trainSpeed, greaterThan(0.0));
      expect(controller.totalDistance, greaterThan(0.0));
      expect(controller.wheelAngle, greaterThan(0.0));
    });

    test('decelerates and comes to full stop when touch is released', () {
      final controller = GameController();
      controller.initialize(800, 400);

      // Accelerate first
      controller.onPointerDown(const Offset(400, 200));
      for (int i = 0; i < 20; i++) {
        controller.update(0.05);
      }
      expect(controller.trainSpeed, greaterThan(100.0));

      // Release touch
      controller.onPointerUp();
      expect(controller.touchActive, isFalse);

      // Update until train decelerates to stop
      for (int i = 0; i < 60; i++) {
        controller.update(0.05);
      }

      expect(controller.trainSpeed, equals(0.0));
    });

    test('picks up trolls only when vertical track height matches troll height', () {
      final controller = GameController();
      controller.initialize(800, 400);

      final trackY = controller.track.getHeightAt(controller.trainX);

      // 1. Matching height troll
      final matchingTroll = TrollData(
        x: controller.trainX + 20.0,
        y: trackY,
        type: TrollType.poppy,
      );
      controller.trolls.clear();
      controller.trolls.add(matchingTroll);

      expect(matchingTroll.isCollected, isFalse);
      expect(controller.collectedTrollsCount, equals(0));

      controller.onPointerDown(const Offset(400, 200));
      controller.update(0.1);

      expect(matchingTroll.isCollected, isTrue);
      expect(controller.collectedTrollsCount, equals(1));
      expect(controller.sparkleParticles, isNotEmpty);
    });

    test('misses troll when vertical height does not match track height (no penalty)', () {
      final controller = GameController();
      controller.initialize(800, 400);

      final trackY = controller.track.getHeightAt(controller.trainX);

      // Troll is 100px higher up in the sky, far out of reach
      final highTroll = TrollData(
        x: controller.trainX + 15.0,
        y: trackY - 100.0,
        type: TrollType.branch,
      );
      controller.trolls.clear();
      controller.trolls.add(highTroll);

      controller.onPointerDown(const Offset(400, 200));
      // Drive past the troll
      for (int i = 0; i < 15; i++) {
        controller.update(0.05);
      }

      // Troll was missed: not collected, count remains 0, no error
      expect(highTroll.isCollected, isFalse);
      expect(controller.collectedTrollsCount, equals(0));
    });

    test('collecting 10 trolls triggers victory, Troll Village arrival, and confetti', () {
      final controller = GameController();
      controller.initialize(800, 400);

      final trackY = controller.track.getHeightAt(controller.trainX);

      // Collect 10 trolls
      for (int k = 0; k < 10; k++) {
        final troll = TrollData(
          x: controller.trainX + 10.0,
          y: trackY,
          type: TrollType.values[k % TrollType.values.length],
        );
        controller.trolls.clear();
        controller.trolls.add(troll);

        controller.onPointerDown(const Offset(400, 200));
        controller.update(0.08);

        expect(troll.isCollected, isTrue);
      }

      expect(controller.collectedTrollsCount, equals(10));
      expect(controller.hasWon, isTrue);
      expect(controller.villageX, isNotNull);

      // Confetti spawns during victory
      controller.update(0.1);
      expect(controller.confettiParticles, isNotEmpty);
    });

    test('parallax offsets increase monotonically and smoothly without wrapping discontinuities', () {
      final controller = GameController();
      controller.initialize(800, 400);

      controller.onPointerDown(const Offset(400, 200));

      double lastMountains = 0.0;
      double lastHills = 0.0;
      double lastClouds = 0.0;

      for (int i = 0; i < 500; i++) {
        controller.update(0.02);
        expect(controller.parallaxMountains, greaterThanOrEqualTo(lastMountains));
        expect(controller.parallaxHills, greaterThanOrEqualTo(lastHills));
        expect(controller.parallaxClouds, greaterThan(lastClouds));

        lastMountains = controller.parallaxMountains;
        lastHills = controller.parallaxHills;
        lastClouds = controller.parallaxClouds;
      }
    });
  });
}
