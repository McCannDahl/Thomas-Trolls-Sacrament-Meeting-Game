import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'models/particle_data.dart';
import 'models/track_data.dart';
import 'models/troll_data.dart';

class GameController extends ChangeNotifier {
  final TrackData track = TrackData();
  final List<TrollData> trolls = [];
  final List<SmokeParticle> smokeParticles = [];
  final List<SparkleParticle> sparkleParticles = [];

  // Physics constants
  static const double maxSpeed = 260.0; // px/sec
  static const double acceleration = 220.0; // px/sec^2 (~1.2s to max speed)
  static const double deceleration = 180.0; // px/sec^2 (~1.4s to stop)
  static const double wheelRadius = 14.0;

  double trainSpeed = 0.0;
  double wheelAngle = 0.0;
  double totalDistance = 0.0;

  bool touchActive = false;
  Offset? touchPosition;

  double parallaxClouds = 0.0;
  double parallaxMountains = 0.0;
  double parallaxHills = 0.0;

  double _smokeTimer = 0.0;
  double _nextTrollSpawnX = 600.0;
  final math.Random _random = math.Random();

  int collectedTrollsCount = 0;
  bool isInitialized = false;

  double screenWidth = 800.0;
  double screenHeight = 400.0;

  // Train screen anchor
  double get trainX => math.max(140.0, screenWidth * 0.22);
  double get carriageX => trainX - 78.0;

  void initialize(double width, double height) {
    screenWidth = width;
    screenHeight = height;
    final initialY = height - 90.0;

    track.initialize(screenWidth: width, initialY: initialY);

    trolls.clear();
    smokeParticles.clear();
    sparkleParticles.clear();

    // Spawn first troll ahead on the track
    _nextTrollSpawnX = width * 0.8;
    trolls.add(
      TrollData(
        x: _nextTrollSpawnX,
        type: TrollType.poppy,
      ),
    );
    _nextTrollSpawnX += 700.0;

    isInitialized = true;
    notifyListeners();
  }

  void onPointerDown(Offset position) {
    touchActive = true;
    touchPosition = position;
    notifyListeners();
  }

  void onPointerMove(Offset position) {
    if (touchActive) {
      touchPosition = position;
    }
  }

  void onPointerUp() {
    touchActive = false;
    touchPosition = null;
    notifyListeners();
  }

  void update(double dt) {
    if (!isInitialized || dt <= 0) return;

    // Cap dt to prevent spiral of death on lag spikes
    final clampedDt = dt.clamp(0.001, 0.05);

    // 1. Accelerate or Decelerate
    if (touchActive) {
      trainSpeed = (trainSpeed + acceleration * clampedDt).clamp(0.0, maxSpeed);
    } else {
      trainSpeed = (trainSpeed - deceleration * clampedDt).clamp(0.0, maxSpeed);
    }

    final double dx = trainSpeed * clampedDt;

    // 2. Parallax and rotation
    if (dx > 0) {
      wheelAngle = (wheelAngle + dx / wheelRadius) % (2 * math.pi);
      totalDistance += dx;

      parallaxMountains = (parallaxMountains + dx * 0.08) % 3000.0;
      parallaxHills = (parallaxHills + dx * 0.25) % 3000.0;
    }

    // Clouds drift slowly on their own + with motion
    parallaxClouds = (parallaxClouds + 15.0 * clampedDt + dx * 0.04) % 3000.0;

    // 3. Update track geometry
    track.update(
      dx: dx,
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      isTouching: touchActive,
      touchY: touchPosition?.dy,
    );

    // 4. Update trolls
    for (int i = trolls.length - 1; i >= 0; i--) {
      final troll = trolls[i];
      troll.update(clampedDt, dx);

      // Check collision with train
      if (!troll.isCollected) {
        final double trollTrackY = track.getHeightAt(troll.x);
        final double trainFrontX = trainX + 35.0;

        if (troll.x <= trainFrontX && troll.x >= trainX - 45.0) {
          troll.isCollected = true;
          collectedTrollsCount++;

          // Burst of sparkles!
          _spawnSparkles(troll.x, trollTrackY - 20.0, troll.hairColor);
        }
      }

      // Cull off-screen trolls
      if (troll.x < -200.0) {
        trolls.removeAt(i);
      }
    }

    // 5. Spawn new trolls
    if (track.endX > _nextTrollSpawnX) {
      final types = TrollType.values;
      final type = types[_random.nextInt(types.length)];
      trolls.add(
        TrollData(
          x: _nextTrollSpawnX,
          type: type,
        ),
      );
      _nextTrollSpawnX = track.endX + 600.0 + _random.nextDouble() * 500.0;
    }

    // 6. Spawn smoke puffs from chimney
    if (trainSpeed > 20.0) {
      _smokeTimer += clampedDt;
      final double smokeInterval = (0.28 - (trainSpeed / maxSpeed) * 0.16).clamp(0.10, 0.28);
      if (_smokeTimer >= smokeInterval) {
        _smokeTimer = 0.0;
        _spawnSmokePuff();
      }
    }

    // 7. Update smoke particles
    smokeParticles.removeWhere((p) => !p.update(clampedDt));

    // 8. Update sparkle particles
    sparkleParticles.removeWhere((p) => !p.update(clampedDt));

    notifyListeners();
  }

  void _spawnSmokePuff() {
    final double trainY = track.getHeightAt(trainX);
    final double angle = track.getAngleAt(trainX);

    // Chimney offset relative to train center: front + upward
    final double chimneyDistX = 22.0;
    final double chimneyDistY = -38.0;

    final cosA = math.cos(angle);
    final sinA = math.sin(angle);

    final smokeX = trainX + (chimneyDistX * cosA - chimneyDistY * sinA);
    final smokeY = trainY + (chimneyDistX * sinA + chimneyDistY * cosA);

    smokeParticles.add(
      SmokeParticle(
        x: smokeX,
        y: smokeY,
        vx: -trainSpeed * 0.4 - 20.0 - _random.nextDouble() * 15.0,
        vy: -35.0 - _random.nextDouble() * 25.0,
        radius: 8.0 + _random.nextDouble() * 4.0,
      ),
    );
  }

  void _spawnSparkles(double x, double y, Color mainColor) {
    for (int i = 0; i < 22; i++) {
      final double angle = _random.nextDouble() * 2 * math.pi;
      final double speed = 40.0 + _random.nextDouble() * 140.0;
      final Color color = _random.nextBool()
          ? mainColor
          : (_random.nextBool() ? const Color(0xFFFFD700) : Colors.white);

      sparkleParticles.add(
        SparkleParticle(
          x: x,
          y: y,
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed - 40.0,
          color: color,
          size: 4.0 + _random.nextDouble() * 5.0,
          vRot: (_random.nextDouble() - 0.5) * 8.0,
        ),
      );
    }
  }
}
