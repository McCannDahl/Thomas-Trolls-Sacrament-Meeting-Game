import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thomas_trolls/game/models/particle_data.dart';
import 'package:thomas_trolls/game/models/track_data.dart';
import 'package:thomas_trolls/game/models/troll_data.dart';

void main() {
  group('TrollData', () {
    test('provides distinct colors and names for each troll type', () {
      for (final type in TrollType.values) {
        final troll = TrollData(x: 100, y: 200, type: type);
        expect(troll.name, isNotEmpty);
        expect(troll.hairColor, isNotNull);
        expect(troll.skinColor, isNotNull);
      }
    });

    test('updates position, bounce, and collection progress', () {
      final troll = TrollData(x: 200, y: 180, type: TrollType.poppy, isCollected: true);
      troll.update(0.1, 10.0);

      expect(troll.x, equals(190.0));
      expect(troll.y, equals(180.0));
      expect(troll.bouncePhase, greaterThan(0.0));
      expect(troll.collectionProgress, greaterThan(0.0));
    });
  });

  group('ParticleData', () {
    test('SmokeParticle updates position, expands radius, and fades out', () {
      final smoke = SmokeParticle(
        x: 100,
        y: 200,
        vx: -20,
        vy: -30,
        radius: 10,
        maxAge: 1.0,
      );

      final alive = smoke.update(0.5);
      expect(alive, isTrue);
      expect(smoke.x, equals(90.0));
      expect(smoke.y, equals(185.0));
      expect(smoke.radius, greaterThan(10.0));
      expect(smoke.alpha, lessThan(0.85));

      final expired = smoke.update(0.6);
      expect(expired, isFalse);
    });

    test('SparkleParticle applies gravity, rotation, and fades', () {
      final sparkle = SparkleParticle(
        x: 50,
        y: 50,
        vx: 10,
        vy: -10,
        color: const Color(0xFFFFD700),
        maxAge: 0.5,
      );

      final alive = sparkle.update(0.2);
      expect(alive, isTrue);
      expect(sparkle.x, equals(52.0));
      expect(sparkle.vy, greaterThan(-10.0));
      expect(sparkle.rotation, isNonZero);
      expect(sparkle.currentAlpha, lessThan(1.0));

      final expired = sparkle.update(0.4);
      expect(expired, isFalse);
    });

    test('ConfettiParticle flutters down and rotates', () {
      final confetti = ConfettiParticle(
        x: 100,
        y: 10,
        vx: 5,
        vy: 50,
        rotation: 0.0,
        vRot: 2.0,
        color: const Color(0xFFFF1493),
        width: 10,
        height: 6,
      );

      final alive = confetti.update(0.1, 400.0);
      expect(alive, isTrue);
      expect(confetti.y, greaterThan(10.0));
      expect(confetti.rotation, isNonZero);
    });
  });

  group('TrackPoint', () {
    test('converts to Offset', () {
      final point = TrackPoint(120.0, 240.0);
      final offset = point.toOffset();
      expect(offset.dx, equals(120.0));
      expect(offset.dy, equals(240.0));
    });
  });
}
