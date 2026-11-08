import 'dart:math' as math;
import 'dart:ui';

/// Represents a single point along the railroad track.
class TrackPoint {
  double x;
  double y;

  TrackPoint(this.x, this.y);

  Offset toOffset() => Offset(x, y);
}

/// Manages track geometry, procedural hill/valley generation, and height queries.
class TrackData {
  final List<TrackPoint> points = [];

  double _currentSlope = 0.0;
  static const double stepX = 14.0;
  static const double maxSlope = 0.70; // ~35 degrees max slope for train safety

  /// Initializes the track spanning across the screen at [initialY].
  void initialize({
    required double screenWidth,
    required double initialY,
    double startX = -200.0,
  }) {
    points.clear();
    _currentSlope = 0.0;

    final double endX = screenWidth + 300.0;
    for (double x = startX; x <= endX; x += stepX) {
      points.add(TrackPoint(x, initialY));
    }
  }

  /// The X coordinate of the rightmost track point.
  double get endX => points.isEmpty ? 0.0 : points.last.x;

  /// The Y coordinate of the rightmost track point.
  double get endY => points.isEmpty ? 0.0 : points.last.y;

  /// Shifts all existing track points left by [dx] and appends new points at the right.
  void update({
    required double dx,
    required double screenWidth,
    required double screenHeight,
    required bool isTouching,
    required double? touchY,
  }) {
    if (points.isEmpty) return;

    // 1. Shift all points left
    for (final p in points) {
      p.x -= dx;
    }

    // 2. Remove points far off-screen to the left
    while (points.length > 2 && points[1].x < -250.0) {
      points.removeAt(0);
    }

    // 3. Append new points on the right until reaching screenWidth + 300
    final double targetEndX = screenWidth + 300.0;
    final double minY = 90.0; // Near top of screen
    final double maxY = screenHeight - 65.0; // Near bottom of screen

    while (points.last.x < targetEndX) {
      final double currentX = points.last.x;
      final double currentY = points.last.y;

      double desiredSlope = 0.0;

      if (isTouching && touchY != null) {
        // If finger is above track end (touchY < currentY), slope up (desiredSlope < 0).
        // If finger is below track end (touchY > currentY), slope down (desiredSlope > 0).
        final double diffY = touchY - currentY;
        const double lookaheadDistance = 180.0;
        desiredSlope = (diffY / lookaheadDistance).clamp(-maxSlope, maxSlope);
      } else {
        // When not touching, gently level out to horizontal
        desiredSlope = 0.0;
      }

      // Smoothly steer current slope toward desired slope
      _currentSlope += (desiredSlope - _currentSlope) * 0.12;

      final double nextX = currentX + stepX;
      double nextY = currentY + _currentSlope * stepX;

      // Bound within screen limits
      if (nextY < minY) {
        nextY = minY;
        if (_currentSlope < 0) _currentSlope = 0.0;
      } else if (nextY > maxY) {
        nextY = maxY;
        if (_currentSlope > 0) _currentSlope = 0.0;
      }

      points.add(TrackPoint(nextX, nextY));
    }
  }

  /// Calculates the track Y coordinate at screen position [x].
  double getHeightAt(double x) {
    if (points.isEmpty) return 0.0;
    if (x <= points.first.x) return points.first.y;
    if (x >= points.last.x) return points.last.y;

    // Binary search to find segment containing x
    int low = 0;
    int high = points.length - 1;

    while (low <= high) {
      final mid = (low + high) ~/ 2;
      if (points[mid].x <= x && mid + 1 < points.length && points[mid + 1].x >= x) {
        final p0 = points[mid];
        final p1 = points[mid + 1];
        final span = p1.x - p0.x;
        if (span == 0) return p0.y;
        final t = (x - p0.x) / span;
        return p0.y + t * (p1.y - p0.y);
      } else if (points[mid].x < x) {
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }

    return points.last.y;
  }

  /// Calculates the tangent angle (in radians) of the track at screen position [x].
  double getAngleAt(double x) {
    const double delta = 6.0;
    final double y1 = getHeightAt(x - delta);
    final double y2 = getHeightAt(x + delta);
    return math.atan2(y2 - y1, delta * 2.0);
  }
}
