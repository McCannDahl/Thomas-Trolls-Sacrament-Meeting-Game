import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'models/particle_data.dart';
import 'models/track_data.dart';
import 'models/troll_data.dart';

class GameController extends ChangeNotifier {
  final TrackData track = TrackData();
  final List<TrollData> trolls = [];
  final List<TrollData> collectedTrolls = [];
  final List<SmokeParticle> smokeParticles = [];
  final List<SparkleParticle> sparkleParticles = [];
  final List<ConfettiParticle> confettiParticles = [];

  // Physics constants
  static const double maxSpeed = 260.0; // px/sec
  static const double acceleration = 220.0; // px/sec^2 (~1.2s to max speed)
  static const double deceleration = 180.0; // px/sec^2 (~1.4s to stop)
  static const double wheelRadius = 14.0;
  static const int totalTrollsToWin = 10;

  double trainSpeed = 0.0;
  double wheelAngle = 0.0;
  double totalDistance = 0.0;

  bool touchActive = false;
  Offset? touchPosition;

  double parallaxClouds = 0.0;
  double parallaxMountains = 0.0;
  double parallaxHills = 0.0;

  double _smokeTimer = 0.0;
  double _confettiTimer = 0.0;
  double _trollSpawnTimer = 0.0;
  int _lastHeightTier = 1;
  final math.Random _random = math.Random();

  int collectedTrollsCount = 0;
  int totalTrollsSpawned = 0;
  bool isInitialized = false;

  // Troll Village & Win State
  bool hasWon = false;
  bool villageStationReached = false;
  double? villageX;

  double screenWidth = 800.0;
  double screenHeight = 400.0;

  // Thomas screen anchor: positioned to comfortably fit 3 carts behind him
  double get trainX => math.max(230.0, screenWidth * 0.32);

  // Cart positions (3 carts pulled behind Thomas)
  double getCartX(int cartIndex) {
    switch (cartIndex) {
      case 0:
        return trainX - 58.0;
      case 1:
        return trainX - 116.0;
      case 2:
        return trainX - 174.0;
      default:
        return trainX - 58.0;
    }
  }

  void initialize(double width, double height) {
    screenWidth = width;
    screenHeight = height;
    final initialY = height - 90.0;

    track.initialize(screenWidth: width, initialY: initialY);

    trolls.clear();
    collectedTrolls.clear();
    smokeParticles.clear();
    sparkleParticles.clear();
    confettiParticles.clear();

    collectedTrollsCount = 0;
    totalTrollsSpawned = 2;
    hasWon = false;
    villageStationReached = false;
    villageX = null;
    trainSpeed = 0.0;
    totalDistance = 0.0;
    wheelAngle = 0.0;
    _trollSpawnTimer = 0.0;
    _lastHeightTier = 1;

    // Spawn first troll ahead at a fun reachable height
    trolls.add(
      TrollData(
        x: width * 0.70,
        y: initialY - 35.0,
        type: TrollType.poppy,
      ),
    );

    // Spawn second troll entering right after
    trolls.add(
      TrollData(
        x: width + 150.0,
        y: initialY - 110.0,
        type: TrollType.branch,
      ),
    );

    isInitialized = true;
    notifyListeners();
  }

  void onPointerDown(Offset position) {
    if (villageStationReached) return;
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
    if (villageStationReached) {
      trainSpeed = 0.0;
    } else if (hasWon && villageX != null && villageX! <= trainX + 160.0) {
      // Auto-brake into Troll Village station
      trainSpeed = (trainSpeed - deceleration * 1.5 * clampedDt).clamp(0.0, maxSpeed);
      if (villageX! <= trainX + 80.0 || trainSpeed < 10.0) {
        trainSpeed = 0.0;
        villageStationReached = true;
      }
    } else if (touchActive) {
      trainSpeed = (trainSpeed + acceleration * clampedDt).clamp(0.0, maxSpeed);
    } else {
      trainSpeed = (trainSpeed - deceleration * clampedDt).clamp(0.0, maxSpeed);
    }

    final double dx = trainSpeed * clampedDt;

    // 2. Parallax and rotation
    if (dx > 0) {
      wheelAngle = (wheelAngle + dx / wheelRadius) % (2 * math.pi);
      totalDistance += dx;

      parallaxMountains += dx * 0.08;
      parallaxHills += dx * 0.25;

      if (villageX != null) {
        villageX = villageX! - dx;
      }
    }

    // Clouds drift slowly on their own + with motion
    parallaxClouds += 15.0 * clampedDt + dx * 0.04;

    // 3. Update track geometry
    track.update(
      dx: dx,
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      isTouching: touchActive && !hasWon,
      touchY: touchPosition?.dy,
    );

    // 4. Update incoming uncollected trolls
    final double trainY = track.getHeightAt(trainX);

    for (int i = trolls.length - 1; i >= 0; i--) {
      final troll = trolls[i];
      troll.update(clampedDt, dx);

      // Check collision with Thomas
      final double trainFront = trainX + 35.0;
      final double trainBack = trainX - 35.0;

      if (troll.x <= trainFront && troll.x >= trainBack) {
        final double vertDiff = (trainY - troll.y).abs();
        if (vertDiff <= 44.0) {
          // Picked up!
          troll.isCollected = true;
          troll.collectedOrder = collectedTrollsCount;
          collectedTrollsCount++;

          // Move permanently to collectedTrolls so it is never culled!
          collectedTrolls.add(troll);
          trolls.removeAt(i);

          // Burst of celebration sparkles!
          _spawnSparkles(troll.x, troll.y, troll.hairColor);

          if (collectedTrollsCount >= totalTrollsToWin) {
            _triggerVictory();
          }
          continue;
        }
      }

      // Cull off-screen uncollected trolls
      if (troll.x < -220.0) {
        trolls.removeAt(i);
      }
    }

    // Update collected trolls (hop animation progress and idle window bounce)
    for (final troll in collectedTrolls) {
      if (troll.collectionProgress < 1.0) {
        troll.update(clampedDt, dx);
      } else {
        troll.bouncePhase += clampedDt * 5.0;
      }
    }

    // 5. Spawn new trolls periodically every ~2.0 seconds while moving until 10 collected
    if (!hasWon && collectedTrollsCount < totalTrollsToWin) {
      if (trainSpeed > 20.0) {
        _trollSpawnTimer += clampedDt;
        if (_trollSpawnTimer >= 2.0) {
          _trollSpawnTimer = 0.0;
          _spawnNewTroll(screenWidth + 70.0);
        }
      }
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

    // 7. Victory Confetti Celebration
    if (hasWon) {
      _confettiTimer += clampedDt;
      if (_confettiTimer >= 0.04) {
        _confettiTimer = 0.0;
        _spawnConfetti();
      }
    }

    // 8. Update particles
    smokeParticles.removeWhere((p) => !p.update(clampedDt));
    sparkleParticles.removeWhere((p) => !p.update(clampedDt));
    confettiParticles.removeWhere((p) => !p.update(clampedDt, screenHeight));

    notifyListeners();
  }

  void _triggerVictory() {
    hasWon = true;
    villageX = screenWidth + 250.0;
  }

  void _spawnNewTroll(double spawnX) {
    totalTrollsSpawned++;
    final types = TrollType.values;
    final type = types[_random.nextInt(types.length)];

    // Pick a different height tier from previous troll for variety
    int tier = _random.nextInt(4);
    if (tier == _lastHeightTier) {
      tier = (tier + 1 + _random.nextInt(3)) % 4;
    }
    _lastHeightTier = tier;

    double spawnY;
    switch (tier) {
      case 0:
        spawnY = 125.0 + _random.nextDouble() * 30.0; // High mountain
        break;
      case 1:
        spawnY = 165.0 + _random.nextDouble() * 30.0; // Upper hill
        break;
      case 2:
        spawnY = 210.0 + _random.nextDouble() * 30.0; // Mid hill
        break;
      case 3:
      default:
        spawnY = math.min(screenHeight - 75.0, 260.0 + _random.nextDouble() * 30.0); // Valley
        break;
    }

    trolls.add(
      TrollData(
        x: spawnX,
        y: spawnY,
        type: type,
      ),
    );
  }

  void _spawnSmokePuff() {
    final double trainY = track.getHeightAt(trainX);
    final double angle = track.getAngleAt(trainX);

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
    for (int i = 0; i < 24; i++) {
      final double angle = _random.nextDouble() * 2 * math.pi;
      final double speed = 40.0 + _random.nextDouble() * 150.0;
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
          size: 4.0 + _random.nextDouble() * 6.0,
          vRot: (_random.nextDouble() - 0.5) * 8.0,
        ),
      );
    }
  }

  void _spawnConfetti() {
    const colors = [
      Color(0xFFFF1493), // Hot pink
      Color(0xFF00E5FF), // Cyan
      Color(0xFFFFD700), // Gold
      Color(0xFF76FF03), // Lime
      Color(0xFFFF6D00), // Orange
      Color(0xFFE040FB), // Magenta
      Color(0xFF00E676), // Green
    ];

    for (int i = 0; i < 3; i++) {
      confettiParticles.add(
        ConfettiParticle(
          x: _random.nextDouble() * screenWidth,
          y: -15.0,
          vx: (_random.nextDouble() - 0.5) * 40.0,
          vy: 90.0 + _random.nextDouble() * 110.0,
          rotation: _random.nextDouble() * 2 * math.pi,
          vRot: (_random.nextDouble() - 0.5) * 6.0,
          color: colors[_random.nextInt(colors.length)],
          width: 7.0 + _random.nextDouble() * 6.0,
          height: 5.0 + _random.nextDouble() * 4.0,
        ),
      );
    }
  }
}
