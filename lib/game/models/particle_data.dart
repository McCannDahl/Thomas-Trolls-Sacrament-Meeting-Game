import 'package:flutter/material.dart';

/// A smoke puff puffing out of Thomas's funnel.
class SmokeParticle {
  double x;
  double y;
  double vx;
  double vy;
  double radius;
  double alpha;
  double maxAge;
  double age;

  SmokeParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
    this.alpha = 0.85,
    this.maxAge = 1.2,
    this.age = 0.0,
  });

  bool update(double dt) {
    age += dt;
    x += vx * dt;
    y += vy * dt;
    radius += 12.0 * dt; // Smoke expands as it rises
    alpha = (1.0 - (age / maxAge)).clamp(0.0, 1.0) * 0.8;
    return age < maxAge;
  }
}

/// A colorful sparkle when picking up a Troll.
class SparkleParticle {
  double x;
  double y;
  double vx;
  double vy;
  final Color color;
  double size;
  double rotation;
  double vRot;
  double age;
  final double maxAge;

  SparkleParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    this.size = 8.0,
    this.rotation = 0.0,
    this.vRot = 3.0,
    this.age = 0.0,
    this.maxAge = 0.8,
  });

  bool update(double dt) {
    age += dt;
    x += vx * dt;
    y += vy * dt;
    vy += 120.0 * dt; // Gravity
    rotation += vRot * dt;
    return age < maxAge;
  }

  double get progress => (age / maxAge).clamp(0.0, 1.0);
  double get currentAlpha => (1.0 - progress).clamp(0.0, 1.0);
}
