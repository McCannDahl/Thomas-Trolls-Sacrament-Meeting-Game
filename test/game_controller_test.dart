import 'package:flutter_test/flutter_test.dart';
import 'package:thomas_trolls/game/game_controller.dart';
import 'package:thomas_trolls/game/models/troll_data.dart';

void main() {
  group('GameController', () {
    test('initializes with zero speed and spawns initial track and trolls', () {
      final controller = GameController();
      controller.initialize(800, 400);

      expect(controller.isInitialized, isTrue);
      expect(controller.trainSpeed, equals(0.0));
      expect(controller.touchActive, isFalse);
      expect(controller.track.points, isNotEmpty);
      expect(controller.trolls, isNotEmpty);
      expect(controller.collectedTrollsCount, equals(0));
    });

    test('accelerates when touch is active', () {
      final controller = GameController();
      controller.initialize(800, 400);

      controller.onPointerDown(const Offset(400, 200));
      expect(controller.touchActive, isTrue);

      // Advance 0.5 seconds
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

    test('picks up trolls when train reaches them', () {
      final controller = GameController();
      controller.initialize(800, 400);

      // Place a troll just ahead of train
      final troll = TrollData(x: controller.trainX + 20.0, type: TrollType.poppy);
      controller.trolls.clear();
      controller.trolls.add(troll);

      expect(troll.isCollected, isFalse);
      expect(controller.collectedTrollsCount, equals(0));

      // Train moves forward
      controller.onPointerDown(const Offset(400, 200));
      controller.update(0.1);

      expect(troll.isCollected, isTrue);
      expect(controller.collectedTrollsCount, equals(1));
      expect(controller.sparkleParticles, isNotEmpty);
    });

    test('parallax offsets increase monotonically and smoothly without wrapping discontinuities', () {
      final controller = GameController();
      controller.initialize(800, 400);

      controller.onPointerDown(const Offset(400, 200));

      double lastMountains = 0.0;
      double lastHills = 0.0;
      double lastClouds = 0.0;

      // Simulate extended driving (500 frames)
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
