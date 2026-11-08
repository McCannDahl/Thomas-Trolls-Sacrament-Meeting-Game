import 'package:flutter_test/flutter_test.dart';
import 'package:thomas_trolls/game/models/track_data.dart';

void main() {
  group('TrackData', () {
    test('initializes flat track across screen width', () {
      final track = TrackData();
      track.initialize(screenWidth: 800, initialY: 300);

      expect(track.points, isNotEmpty);
      expect(track.points.first.x, lessThanOrEqualTo(-150));
      expect(track.points.last.x, greaterThanOrEqualTo(1000));

      // All points should start at initialY
      for (final p in track.points) {
        expect(p.y, equals(300));
      }

      // Height lookup
      expect(track.getHeightAt(400), equals(300));
      expect(track.getAngleAt(400), closeTo(0.0, 0.001));
    });

    test('slopes UP when user finger is above track end', () {
      final track = TrackData();
      track.initialize(screenWidth: 800, initialY: 300);

      final initialEndY = track.endY;

      // User touches above the track end (Y = 150 < 300)
      for (int i = 0; i < 20; i++) {
        track.update(
          dx: 15.0,
          screenWidth: 800,
          screenHeight: 400,
          isTouching: true,
          touchY: 150.0,
        );
      }

      // Track end should have sloped upward (smaller Y)
      expect(track.endY, lessThan(initialEndY));
    });

    test('slopes DOWN when user finger is below track end', () {
      final track = TrackData();
      track.initialize(screenWidth: 800, initialY: 200);

      final initialEndY = track.endY;

      // User touches below the track end (Y = 320 > 200)
      for (int i = 0; i < 20; i++) {
        track.update(
          dx: 15.0,
          screenWidth: 800,
          screenHeight: 400,
          isTouching: true,
          touchY: 320.0,
        );
      }

      // Track end should have sloped downward (larger Y)
      expect(track.endY, greaterThan(initialEndY));
    });

    test('respects min and max height bounds', () {
      final track = TrackData();
      track.initialize(screenWidth: 800, initialY: 200);

      // Try to slope up beyond the screen top (touchY = -500)
      for (int i = 0; i < 100; i++) {
        track.update(
          dx: 20.0,
          screenWidth: 800,
          screenHeight: 400,
          isTouching: true,
          touchY: -500.0,
        );
      }

      // Minimum Y clamped at 90.0
      for (final p in track.points) {
        expect(p.y, greaterThanOrEqualTo(90.0));
      }

      // Now slope down beyond screen bottom (touchY = 1000)
      for (int i = 0; i < 100; i++) {
        track.update(
          dx: 20.0,
          screenWidth: 800,
          screenHeight: 400,
          isTouching: true,
          touchY: 1000.0,
        );
      }

      // Maximum Y clamped at screenHeight - 65.0 = 335.0
      for (final p in track.points) {
        expect(p.y, lessThanOrEqualTo(335.0));
      }
    });

    test('interpolates track height accurately along a slope', () {
      final track = TrackData();
      track.initialize(screenWidth: 800, initialY: 250);

      // Artificially create a known slope
      track.points.clear();
      track.points.add(TrackPoint(0, 200));
      track.points.add(TrackPoint(100, 300));

      expect(track.getHeightAt(0), equals(200));
      expect(track.getHeightAt(50), equals(250));
      expect(track.getHeightAt(100), equals(300));
    });
  });
}
