import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../game_controller.dart';
import '../models/troll_data.dart';

class GameWorldPainter extends CustomPainter {
  final GameController controller;

  GameWorldPainter({required this.controller}) : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    if (!controller.isInitialized) return;

    final width = size.width;
    final height = size.height;

    // 1. Draw Sky & Sun
    _drawSky(canvas, width, height);

    // 2. Draw Clouds
    _drawClouds(canvas, width, height);

    // 3. Draw Parallax Distant Mountains
    _drawDistantMountains(canvas, width, height);

    // 4. Draw Parallax Midground Hills & Trees
    _drawMidgroundHills(canvas, width, height);

    // 5. Draw Ground & Trestle Bridges under Track
    _drawGroundAndTrestles(canvas, width, height);

    // 6. Draw Railroad Track (Sleepers & Steel Rails)
    _drawTrack(canvas);

    // 7. Draw Trolls on Track
    _drawTrolls(canvas);

    // 8. Draw Carriage
    _drawCarriage(canvas);

    // 9. Draw Thomas Train
    _drawTrain(canvas);

    // 10. Draw Smoke Puffs
    _drawSmoke(canvas);

    // 11. Draw Sparkles
    _drawSparkles(canvas);

    // 12. Draw Touch Feedback Guide
    _drawTouchGuide(canvas, width, height);
  }

  void _drawSky(Canvas canvas, double width, double height) {
    // Soft sunny sky gradient
    final skyRect = Rect.fromLTWH(0, 0, width, height);
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF64B5F6), // Vibrant Sky Blue
          Color(0xFFBBDEFB), // Light horizon blue
          Color(0xFFE3F2FD),
        ],
        stops: [0.0, 0.65, 1.0],
      ).createShader(skyRect);
    canvas.drawRect(skyRect, skyPaint);

    // Friendly bright smiling sun
    final sunCenter = Offset(width * 0.88, height * 0.20);
    final sunGlowPaint = Paint()
      ..color = const Color(0x33FFEB3B)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20.0);
    canvas.drawCircle(sunCenter, 44.0, sunGlowPaint);

    // Sun rays
    final rayPaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final rayAngleOffset = controller.totalDistance * 0.005;
    for (int i = 0; i < 8; i++) {
      final angle = rayAngleOffset + i * (math.pi / 4);
      final p1 = sunCenter + Offset(math.cos(angle) * 34, math.sin(angle) * 34);
      final p2 = sunCenter + Offset(math.cos(angle) * 44, math.sin(angle) * 44);
      canvas.drawLine(p1, p2, rayPaint);
    }

    final sunPaint = Paint()..color = const Color(0xFFFFEE58);
    canvas.drawCircle(sunCenter, 28.0, sunPaint);

    // Cute smiling face on sun
    final facePaint = Paint()
      ..color = const Color(0xFFF57F17)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Eyes
    final eyePaint = Paint()..color = const Color(0xFFF57F17);
    canvas.drawCircle(sunCenter + const Offset(-8, -4), 2.5, eyePaint);
    canvas.drawCircle(sunCenter + const Offset(8, -4), 2.5, eyePaint);

    // Smile
    final smilePath = Path()
      ..arcTo(
        Rect.fromCircle(center: sunCenter + const Offset(0, 4), radius: 9),
        0.2,
        math.pi - 0.4,
        false,
      );
    canvas.drawPath(smilePath, facePaint);
  }

  void _drawClouds(Canvas canvas, double width, double height) {
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.90);
    final cloudShadowPaint = Paint()..color = const Color(0xFFDCEEFB).withValues(alpha: 0.85);

    final clouds = [
      {'baseX': 100.0, 'y': height * 0.14, 'scale': 1.1},
      {'baseX': 450.0, 'y': height * 0.22, 'scale': 0.85},
      {'baseX': 820.0, 'y': height * 0.10, 'scale': 1.25},
      {'baseX': 1200.0, 'y': height * 0.18, 'scale': 0.95},
      {'baseX': 1600.0, 'y': height * 0.12, 'scale': 1.05},
    ];

    const loopWidth = 1800.0;
    for (final c in clouds) {
      final rawX = (c['baseX']! - controller.parallaxClouds) % loopWidth;
      final x = rawX < -150 ? rawX + loopWidth : rawX;
      final y = c['y']!;
      final s = c['scale']!;

      _drawSingleCloud(canvas, Offset(x, y), s, cloudShadowPaint, cloudPaint);
    }
  }

  void _drawSingleCloud(
    Canvas canvas,
    Offset center,
    double s,
    Paint shadowPaint,
    Paint mainPaint,
  ) {
    void drawPuffs(Paint p, double offsetY) {
      canvas.drawCircle(center + Offset(-24 * s, (4 + offsetY) * s), 18 * s, p);
      canvas.drawCircle(center + Offset(24 * s, (4 + offsetY) * s), 18 * s, p);
      canvas.drawCircle(center + Offset(-10 * s, (-8 + offsetY) * s), 24 * s, p);
      canvas.drawCircle(center + Offset(12 * s, (-6 + offsetY) * s), 22 * s, p);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center + Offset(0, (6 + offsetY) * s),
            width: 70 * s,
            height: 24 * s,
          ),
          Radius.circular(12 * s),
        ),
        p,
      );
    }

    drawPuffs(shadowPaint, 3.0);
    drawPuffs(mainPaint, 0.0);
  }

  void _drawDistantMountains(Canvas canvas, double width, double height) {
    final mountainPaint = Paint()..color = const Color(0xFF90A4AE).withValues(alpha: 0.65);
    final snowPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);

    final path = Path();
    final snowPath = Path();

    path.moveTo(-50, height);

    const mountainSpacing = 280.0;
    const totalSpan = 3000.0;
    final double offset = controller.parallaxMountains % totalSpan;

    double x = -100.0 - (offset % mountainSpacing);
    while (x < width + 200.0) {
      final peakX = x + mountainSpacing * 0.5;
      final peakY = height * 0.38 + ((x.toInt() % 7) * 12.0);

      path.lineTo(x, height * 0.75);
      path.lineTo(peakX, peakY);
      path.lineTo(x + mountainSpacing, height * 0.75);

      // Snow cap
      snowPath.moveTo(peakX, peakY);
      snowPath.lineTo(peakX - 26, peakY + 36);
      snowPath.lineTo(peakX - 10, peakY + 32);
      snowPath.lineTo(peakX, peakY + 38);
      snowPath.lineTo(peakX + 12, peakY + 30);
      snowPath.lineTo(peakX + 26, peakY + 36);
      snowPath.close();

      x += mountainSpacing;
    }

    path.lineTo(width + 50, height);
    path.close();

    canvas.drawPath(path, mountainPaint);
    canvas.drawPath(snowPath, snowPaint);
  }

  void _drawMidgroundHills(Canvas canvas, double width, double height) {
    final hillPaint = Paint()..color = const Color(0xFF81C784).withValues(alpha: 0.75);
    final hillPath = Path();

    hillPath.moveTo(-50, height);

    const hillSpacing = 200.0;
    const totalSpan = 3000.0;
    final double offset = controller.parallaxHills % totalSpan;

    double x = -100.0 - (offset % hillSpacing);
    while (x < width + 250.0) {
      final crestX = x + hillSpacing * 0.5;
      final crestY = height * 0.55 + ((x.toInt() % 5) * 16.0);

      hillPath.quadraticBezierTo(crestX, crestY, x + hillSpacing, height * 0.68);

      // Draw cute lollipop trees on hill crest
      if ((crestX.toInt() % 3) == 0) {
        _drawCartoonTree(canvas, Offset(crestX, crestY + 6), 0.85);
      }

      x += hillSpacing;
    }

    hillPath.lineTo(width + 50, height);
    hillPath.close();

    canvas.drawPath(hillPath, hillPaint);
  }

  void _drawCartoonTree(Canvas canvas, Offset base, double scale) {
    // Trunk
    final trunkPaint = Paint()
      ..color = const Color(0xFF795548)
      ..strokeWidth = 5.0 * scale
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(base, base + Offset(0, -22 * scale), trunkPaint);

    // Leaves
    final foliageColors = [
      const Color(0xFF43A047),
      const Color(0xFF66BB6A),
      const Color(0xFF2E7D32),
    ];
    final color = foliageColors[(base.dx.toInt() ~/ 50) % foliageColors.length];
    final leafPaint = Paint()..color = color;

    canvas.drawCircle(base + Offset(0, -28 * scale), 14 * scale, leafPaint);
    canvas.drawCircle(
      base + Offset(-3 * scale, -31 * scale),
      6 * scale,
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );
  }

  void _drawGroundAndTrestles(Canvas canvas, double width, double height) {
    final points = controller.track.points;
    if (points.length < 2) return;

    // 1. Trestle wooden supports when track is elevated
    final trestleBeamPaint = Paint()
      ..color = const Color(0xFF6D4C41)
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.square;
    final trestleCrossPaint = Paint()
      ..color = const Color(0xFF8D6E63)
      ..strokeWidth = 2.5;

    for (int i = 0; i < points.length; i += 3) {
      final p = points[i];
      if (p.x < -40 || p.x > width + 40) continue;

      final trackY = p.y;
      final groundBaseline = height;

      // Draw trestle if track is elevated above baseline
      if (groundBaseline - trackY > 110.0) {
        // Vertical legs
        canvas.drawLine(Offset(p.x - 7, trackY + 8), Offset(p.x - 12, groundBaseline), trestleBeamPaint);
        canvas.drawLine(Offset(p.x + 7, trackY + 8), Offset(p.x + 12, groundBaseline), trestleBeamPaint);

        // Criss-cross braces
        for (double by = trackY + 30; by < groundBaseline - 15; by += 40) {
          canvas.drawLine(Offset(p.x - 8, by), Offset(p.x + 8, by + 35), trestleCrossPaint);
          canvas.drawLine(Offset(p.x + 8, by), Offset(p.x - 8, by + 35), trestleCrossPaint);
          canvas.drawLine(Offset(p.x - 9, by), Offset(p.x + 9, by), trestleCrossPaint);
        }
      }
    }

    // 2. Solid Lush Green Rolling Hill under the track
    final groundPath = Path();
    groundPath.moveTo(points.first.x, height);
    groundPath.lineTo(points.first.x, points.first.y + 6);

    for (int i = 1; i < points.length; i++) {
      groundPath.lineTo(points[i].x, points[i].y + 6);
    }

    groundPath.lineTo(points.last.x, height);
    groundPath.close();

    final groundGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const [
        Color(0xFF4CAF50), // Lush Green
        Color(0xFF388E3C), // Forest Green
        Color(0xFF5D4037), // Earth Brown at very bottom
      ],
      stops: const [0.0, 0.45, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, width, height));

    canvas.drawPath(groundPath, Paint()..shader = groundGradient);

    // Grass fringe highlight along track line
    final grassFringePath = Path();
    grassFringePath.moveTo(points.first.x, points.first.y + 6);
    for (int i = 1; i < points.length; i++) {
      grassFringePath.lineTo(points[i].x, points[i].y + 6);
    }
    final grassFringePaint = Paint()
      ..color = const Color(0xFF81C784)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(grassFringePath, grassFringePaint);
  }

  void _drawTrack(Canvas canvas) {
    final points = controller.track.points;
    if (points.length < 2) return;

    // 1. Draw Wooden Ties (Sleepers) along the curve
    final tiePaint = Paint()
      ..color = const Color(0xFF4E342E) // Deep wood brown
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round;

    final tieHighlightPaint = Paint()
      ..color = const Color(0xFF8D6E63)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    const double tieSpacing = 20.0;
    double accumulatedDist = 0.0;

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final segDx = p1.x - p0.x;
      final segDy = p1.y - p0.y;
      final segLen = math.sqrt(segDx * segDx + segDy * segDy);
      if (segLen == 0) continue;

      accumulatedDist += segLen;
      if (accumulatedDist >= tieSpacing) {
        accumulatedDist -= tieSpacing;

        final angle = math.atan2(segDy, segDx);
        final normalX = -math.sin(angle);
        final normalY = math.cos(angle);

        final tieHalfLength = 15.0;
        final top = Offset(p0.x - normalX * tieHalfLength, p0.y - normalY * tieHalfLength);
        final bottom = Offset(p0.x + normalX * tieHalfLength, p0.y + normalY * tieHalfLength);

        canvas.drawLine(top, bottom, tiePaint);
        // Highlight on sleeper edge
        canvas.drawLine(
          top + Offset(normalY * 1.5, -normalX * 1.5),
          bottom + Offset(normalY * 1.5, -normalX * 1.5),
          tieHighlightPaint,
        );
      }
    }

    // 2. Draw Parallel Steel Rails (Top rail & Bottom rail)
    const double railOffsets = 6.0;

    void drawRail(double offsetDistance, Color baseColor, Color gleamColor) {
      final railPath = Path();
      final gleamPath = Path();

      for (int i = 0; i < points.length; i++) {
        final p = points[i];
        final angle = controller.track.getAngleAt(p.x);
        final normalX = -math.sin(angle);
        final normalY = math.cos(angle);

        final rx = p.x + normalX * offsetDistance;
        final ry = p.y + normalY * offsetDistance;

        if (i == 0) {
          railPath.moveTo(rx, ry);
          gleamPath.moveTo(rx - normalX * 0.8, ry - normalY * 0.8);
        } else {
          railPath.lineTo(rx, ry);
          gleamPath.lineTo(rx - normalX * 0.8, ry - normalY * 0.8);
        }
      }

      // Base rail bar
      canvas.drawPath(
        railPath,
        Paint()
          ..color = baseColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.8
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );

      // Metallic gleam line on top of rail
      canvas.drawPath(
        gleamPath,
        Paint()
          ..color = gleamColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    // Bottom rail (farther in 2.5D perspective)
    drawRail(railOffsets, const Color(0xFF37474F), const Color(0xFF78909C));
    // Top rail
    drawRail(-railOffsets, const Color(0xFF263238), const Color(0xFFCFD8DC));
  }

  void _drawTrolls(Canvas canvas) {
    for (final troll in controller.trolls) {
      if (troll.isCollected) {
        _drawCollectedTrollHop(canvas, troll);
      } else {
        _drawStandingTroll(canvas, troll);
      }
    }
  }

  void _drawStandingTroll(Canvas canvas, TrollData troll) {
    final trackY = controller.track.getHeightAt(troll.x);
    final trackAngle = controller.track.getAngleAt(troll.x);

    // Idle happy bounce
    final bounceY = math.sin(troll.bouncePhase) * 3.5;

    canvas.save();
    canvas.translate(troll.x, trackY + bounceY);
    canvas.rotate(trackAngle);

    _drawTrollFigure(canvas, troll, isWaving: true);

    canvas.restore();
  }

  void _drawCollectedTrollHop(Canvas canvas, TrollData troll) {
    if (troll.collectionProgress >= 1.0) return;

    final progress = troll.collectionProgress;
    final startX = troll.x;
    final startY = controller.track.getHeightAt(troll.x);

    final targetX = controller.carriageX;
    final targetY = controller.track.getHeightAt(targetX) - 15.0;

    // Arc trajectory
    final currentX = startX + (targetX - startX) * progress;
    final arcHeight = math.sin(progress * math.pi) * 80.0;
    final currentY = (startY + (targetY - startY) * progress) - arcHeight;

    canvas.save();
    canvas.translate(currentX, currentY);
    canvas.rotate(progress * math.pi * 2.0); // Happy flip!

    _drawTrollFigure(canvas, troll, isWaving: true, scale: 1.0 - progress * 0.25);

    canvas.restore();
  }

  void _drawTrollFigure(
    Canvas canvas,
    TrollData troll, {
    bool isWaving = false,
    double scale = 1.0,
  }) {
    canvas.scale(scale, scale);

    // Sits on track ground: feet around (0, -2)
    // 1. Troll Body & Outfit
    final bodyPaint = Paint()..color = troll.skinColor;
    final outfitPaint = Paint()
      ..color = troll.type == TrollType.poppy
          ? const Color(0xFF039BE5)
          : (troll.type == TrollType.branch ? const Color(0xFF6D4C41) : const Color(0xFFFFB300));

    // Little feet
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-5, -3), width: 7, height: 5),
      bodyPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(5, -3), width: 7, height: 5),
      bodyPaint,
    );

    // Dress / Vest body
    final bodyPath = Path();
    bodyPath.moveTo(-8, -4);
    bodyPath.lineTo(-5, -18);
    bodyPath.lineTo(5, -18);
    bodyPath.lineTo(8, -4);
    bodyPath.close();
    canvas.drawPath(bodyPath, outfitPaint);

    // Hands
    final armPaint = Paint()
      ..color = troll.skinColor
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    if (isWaving) {
      // Left arm waving up
      canvas.drawLine(const Offset(-6, -14), const Offset(-14, -24), armPaint);
      canvas.drawCircle(const Offset(-14, -24), 2.5, bodyPaint);
      // Right arm out
      canvas.drawLine(const Offset(6, -14), const Offset(14, -18), armPaint);
      canvas.drawCircle(const Offset(14, -18), 2.5, bodyPaint);
    } else {
      canvas.drawLine(const Offset(-6, -14), const Offset(-12, -8), armPaint);
      canvas.drawLine(const Offset(6, -14), const Offset(12, -8), armPaint);
    }

    // 2. Big Pointy DreamWorks Troll Hair
    final hairPaint = Paint()..color = troll.hairColor;
    final hairPath = Path();
    hairPath.moveTo(-11, -22);
    // Left flare
    hairPath.quadraticBezierTo(-18, -35, -12, -50);
    // Tip reaching high
    hairPath.quadraticBezierTo(-5, -64, 0, -70);
    // Right tip curve
    hairPath.quadraticBezierTo(5, -64, 12, -50);
    // Right flare
    hairPath.quadraticBezierTo(18, -35, 11, -22);
    hairPath.close();
    canvas.drawPath(hairPath, hairPaint);

    // Hair sparkle/shading highlights
    final hairShinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.40)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final hairShine = Path()
      ..moveTo(-3, -28)
      ..quadraticBezierTo(0, -48, 0, -66);
    canvas.drawPath(hairShine, hairShinePaint);

    // Poppy Flower Headband
    if (troll.type == TrollType.poppy) {
      final bandPaint = Paint()
        ..color = const Color(0xFF43A047)
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke;
      canvas.drawArc(
        Rect.fromCenter(center: const Offset(0, -23), width: 22, height: 10),
        0.0,
        math.pi,
        false,
        bandPaint,
      );
      // Pink and blue flowers
      canvas.drawCircle(const Offset(-7, -23), 3.0, Paint()..color = const Color(0xFF00E5FF));
      canvas.drawCircle(const Offset(0, -25), 3.5, Paint()..color = const Color(0xFFFF4081));
      canvas.drawCircle(const Offset(7, -23), 3.0, Paint()..color = const Color(0xFF00E5FF));
    }

    // 3. Cute Troll Face & Head
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, -20), width: 18, height: 14),
      bodyPaint,
    );

    // Big pointy troll ears!
    final earPathLeft = Path()
      ..moveTo(-8, -20)
      ..lineTo(-16, -22)
      ..lineTo(-8, -17)
      ..close();
    final earPathRight = Path()
      ..moveTo(8, -20)
      ..lineTo(16, -22)
      ..lineTo(8, -17)
      ..close();
    canvas.drawPath(earPathLeft, bodyPaint);
    canvas.drawPath(earPathRight, bodyPaint);

    // Rosy Cheeks
    final cheekPaint = Paint()..color = const Color(0xFFFF5252).withValues(alpha: 0.45);
    canvas.drawCircle(const Offset(-5, -18), 2.2, cheekPaint);
    canvas.drawCircle(const Offset(5, -18), 2.2, cheekPaint);

    // Cute Eyes with Shine
    final eyePaint = Paint()..color = const Color(0xFF212121);
    canvas.drawCircle(const Offset(-3.5, -21), 2.2, eyePaint);
    canvas.drawCircle(const Offset(3.5, -21), 2.2, eyePaint);
    final eyeGleam = Paint()..color = Colors.white;
    canvas.drawCircle(const Offset(-4.0, -22), 0.9, eyeGleam);
    canvas.drawCircle(const Offset(3.0, -22), 0.9, eyeGleam);

    // Sweet Button Nose
    canvas.drawCircle(
      const Offset(0, -19),
      1.8,
      Paint()..color = troll.skinColor.withValues(alpha: 0.85),
    );

    // Happy Smile
    final mouthPaint = Paint()
      ..color = const Color(0xFFC2185B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    final mouthPath = Path()
      ..arcTo(
        Rect.fromCircle(center: const Offset(0, -17), radius: 3.2),
        0.1,
        math.pi - 0.2,
        false,
      );
    canvas.drawPath(mouthPath, mouthPaint);
  }

  void _drawCarriage(Canvas canvas) {
    final carriageX = controller.carriageX;
    final trackY = controller.track.getHeightAt(carriageX);
    final angle = controller.track.getAngleAt(carriageX);

    canvas.save();
    canvas.translate(carriageX, trackY);
    canvas.rotate(angle);

    // Carriage Body: Warm Railway Teak Red/Brown
    final coachWidth = 56.0;
    final coachHeight = 36.0;

    // Coupler bar connecting to Thomas
    final couplerPaint = Paint()
      ..color = const Color(0xFF212121)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(coachWidth / 2, -10), Offset(coachWidth / 2 + 25, -10), couplerPaint);

    // Coach Body
    final coachRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(0, -coachHeight / 2 - 8),
        width: coachWidth,
        height: coachHeight,
      ),
      const Radius.circular(5.0),
    );
    final coachPaint = Paint()..color = const Color(0xFFB71C1C); // Clarabel / Annie Red
    canvas.drawRRect(coachRect, coachPaint);

    // Yellow Coach Lining & Trim
    final trimPaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawRRect(coachRect, trimPaint);

    // Roof
    final roofPaint = Paint()..color = const Color(0xFF37474F);
    final roofPath = Path();
    roofPath.moveTo(-coachWidth / 2 - 3, -coachHeight - 8);
    roofPath.quadraticBezierTo(0, -coachHeight - 16, coachWidth / 2 + 3, -coachHeight - 8);
    roofPath.close();
    canvas.drawPath(roofPath, roofPaint);

    // Arched Windows
    final windowPaint = Paint()..color = const Color(0xFFFFF9C4); // Warm interior glow
    final windowFramePaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int w = -1; w <= 1; w++) {
      final wRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(w * 16.0, -coachHeight / 2 - 10),
          width: 10,
          height: 14,
        ),
        const Radius.circular(3.0),
      );
      canvas.drawRRect(wRect, windowPaint);
      canvas.drawRRect(wRect, windowFramePaint);

      // If we collected trolls, show their colorful hair/face smiling through the windows!
      if (controller.collectedTrollsCount > (w + 1)) {
        final trollTypes = TrollType.values;
        final type = trollTypes[(w + 1) % trollTypes.length];
        final peekTroll = TrollData(x: 0, type: type);
        canvas.save();
        canvas.translate(w * 16.0, -coachHeight / 2 - 1);
        _drawTrollFigure(canvas, peekTroll, scale: 0.42);
        canvas.restore();
      }
    }

    // Carriage Wheels
    _drawWheel(canvas, const Offset(-17, -7), 7.0, controller.wheelAngle);
    _drawWheel(canvas, const Offset(17, -7), 7.0, controller.wheelAngle);

    canvas.restore();
  }

  void _drawTrain(Canvas canvas) {
    final trainX = controller.trainX;

    // Contact points for front and rear wheels to align pitch perfectly
    final frontX = trainX + 32.0;
    final rearX = trainX - 32.0;
    final frontY = controller.track.getHeightAt(frontX);
    final rearY = controller.track.getHeightAt(rearX);

    final trainCenterY = (frontY + rearY) * 0.5;
    final pitchAngle = math.atan2(frontY - rearY, frontX - rearX);

    canvas.save();
    canvas.translate(trainX, trainCenterY);
    canvas.rotate(pitchAngle);

    // --- THOMAS THE TANK ENGINE ---
    // Chassis & Running Board (Black & Red)
    final runningBoardPaint = Paint()..color = const Color(0xFFD32F2F); // Red buffer beam / board
    final chassisRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(0, -9), width: 88, height: 7),
      const Radius.circular(3.0),
    );
    canvas.drawRRect(chassisRect, runningBoardPaint);

    // Front & Back Buffers
    final bufferPaint = Paint()..color = const Color(0xFF212121);
    canvas.drawCircle(const Offset(45, -9), 4.5, bufferPaint);
    canvas.drawCircle(const Offset(-45, -9), 4.5, bufferPaint);

    // 1. Cab (Back of engine)
    final cabPaint = Paint()..color = const Color(0xFF1976D2); // Thomas Blue
    final cabRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(-22, -29), width: 34, height: 34),
      const Radius.circular(3.0),
    );
    canvas.drawRRect(cabRect, cabPaint);

    // Cab curved roof
    final roofPaint = Paint()..color = const Color(0xFF212121);
    final cabRoofPath = Path()
      ..moveTo(-41, -46)
      ..quadraticBezierTo(-22, -52, -3, -46)
      ..lineTo(-3, -44)
      ..lineTo(-41, -44)
      ..close();
    canvas.drawPath(cabRoofPath, roofPaint);

    // Brass Whistle on Cab Roof
    final whistlePaint = Paint()..color = const Color(0xFFFFD54F);
    canvas.drawRect(const Rect.fromLTWH(-18, -55, 3.5, 9), whistlePaint);

    // Cab Window (Arched)
    final windowPaint = Paint()..color = const Color(0xFFFFF9C4);
    final windowFrame = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final cabWindowRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(-22, -32), width: 14, height: 16),
      const Radius.circular(5.0),
    );
    canvas.drawRRect(cabWindowRect, windowPaint);
    canvas.drawRRect(cabWindowRect, windowFrame);

    // 2. Boiler & Side Tanks (Thomas Blue with Red Pinstripes)
    final boilerRect = Rect.fromLTWH(-6, -38, 32, 26);
    canvas.drawRect(boilerRect, cabPaint);

    // Red Pinstripes on Side Tank
    final stripePaint = Paint()
      ..color = const Color(0xFFD32F2F)
      ..strokeWidth = 2.0;
    canvas.drawLine(const Offset(-5, -36), const Offset(24, -36), stripePaint);
    canvas.drawLine(const Offset(-5, -14), const Offset(24, -14), stripePaint);

    // Iconic Yellow Number "1" on Side Tank!
    _drawNumberOne(canvas, const Offset(10, -25));

    // Brass Dome on Boiler
    final domePaint = Paint()..color = const Color(0xFFFFD54F);
    final domePath = Path()
      ..moveTo(4, -38)
      ..quadraticBezierTo(9, -49, 14, -38)
      ..close();
    canvas.drawPath(domePath, domePaint);

    // 3. Smokebox & Chimney (Dark Slate / Black)
    final smokeboxPaint = Paint()..color = const Color(0xFF263238);
    final smokeboxRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(32, -26), width: 20, height: 26),
      const Radius.circular(3.0),
    );
    canvas.drawRRect(smokeboxRect, smokeboxPaint);

    // Tall Chimney Funnel
    final chimneyPath = Path()
      ..moveTo(27, -38)
      ..lineTo(26, -53)
      ..lineTo(37, -53)
      ..lineTo(36, -38)
      ..close();
    canvas.drawPath(chimneyPath, smokeboxPaint);
    // Gold rim on chimney
    canvas.drawLine(const Offset(25, -53), const Offset(38, -53), domePaint..strokeWidth = 2.5);

    // 4. Thomas's Iconic Cheerful Round Face!
    final faceCenter = const Offset(42, -26);
    final facePaint = Paint()..color = const Color(0xFFECEFF1); // Soft grey face plate
    final faceBorderPaint = Paint()
      ..color = const Color(0xFF90A4AE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(faceCenter, 13.0, facePaint);
    canvas.drawCircle(faceCenter, 13.0, faceBorderPaint);

    // Big friendly expressive eyes looking ahead!
    final eyeWhite = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = const Color(0xFF1565C0);
    final pupilBlack = Paint()..color = const Color(0xFF212121);
    final eyeGleam = Paint()..color = Colors.white;

    // Left & Right Eyes
    canvas.drawOval(Rect.fromCenter(center: faceCenter + const Offset(-4, -3), width: 6.5, height: 7.5), eyeWhite);
    canvas.drawOval(Rect.fromCenter(center: faceCenter + const Offset(4, -3), width: 6.5, height: 7.5), eyeWhite);

    // Pupils looking eagerly forward
    canvas.drawCircle(faceCenter + const Offset(-2.8, -3), 2.2, pupilPaint);
    canvas.drawCircle(faceCenter + const Offset(5.2, -3), 2.2, pupilPaint);
    canvas.drawCircle(faceCenter + const Offset(-2.8, -3), 1.2, pupilBlack);
    canvas.drawCircle(faceCenter + const Offset(5.2, -3), 1.2, pupilBlack);
    canvas.drawCircle(faceCenter + const Offset(-3.2, -4), 0.8, eyeGleam);
    canvas.drawCircle(faceCenter + const Offset(4.8, -4), 0.8, eyeGleam);

    // Eyebrows
    final browPaint = Paint()
      ..color = const Color(0xFF455A64)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCenter(center: faceCenter + const Offset(-4, -7), width: 6, height: 3), 0.3, math.pi - 0.6, false, browPaint);
    canvas.drawArc(Rect.fromCenter(center: faceCenter + const Offset(4, -7), width: 6, height: 3), 0.3, math.pi - 0.6, false, browPaint);

    // Rosy Cheeks
    final cheekPaint = Paint()..color = const Color(0xFFFF8A80).withValues(alpha: 0.50);
    canvas.drawCircle(faceCenter + const Offset(-8, 1), 3.0, cheekPaint);
    canvas.drawCircle(faceCenter + const Offset(8, 1), 3.0, cheekPaint);

    // Sweet Button Nose
    canvas.drawCircle(faceCenter + const Offset(0, 0), 1.6, Paint()..color = const Color(0xFFB0BEC5));

    // Happy Smiling Mouth
    final mouthPaint = Paint()
      ..color = const Color(0xFFB71C1C)
      ..style = PaintingStyle.fill;
    final mouthPath = Path()
      ..moveTo(faceCenter.dx - 5.5, faceCenter.dy + 3.5)
      ..quadraticBezierTo(faceCenter.dx, faceCenter.dy + 9.5, faceCenter.dx + 5.5, faceCenter.dy + 3.5)
      ..close();
    canvas.drawPath(mouthPath, mouthPaint);

    // 5. Six Rotating Wheels with Counterweights & Connecting Rods!
    const double wheelR = 10.5;
    final wheelPositions = [
      const Offset(-28, -6),
      const Offset(2, -6),
      const Offset(30, -6),
    ];

    for (final pos in wheelPositions) {
      _drawWheel(canvas, pos, wheelR, controller.wheelAngle);
    }

    // Side Connecting Rod connecting all 3 wheels
    final rodAngle = controller.wheelAngle;
    final pinDist = 6.0;
    final rodYOffset = math.sin(rodAngle) * pinDist;
    final rodXOffset = math.cos(rodAngle) * pinDist;

    final rodPaint = Paint()
      ..color = const Color(0xFFECEFF1)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    final rodShadow = Paint()
      ..color = const Color(0xFF455A64)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final pStart = Offset(wheelPositions.first.dx + rodXOffset, wheelPositions.first.dy + rodYOffset);
    final pEnd = Offset(wheelPositions.last.dx + rodXOffset, wheelPositions.last.dy + rodYOffset);

    canvas.drawLine(pStart, pEnd, rodPaint);
    canvas.drawLine(pStart, pEnd, rodShadow);

    // Rod joint pins
    for (final pos in wheelPositions) {
      canvas.drawCircle(Offset(pos.dx + rodXOffset, pos.dy + rodYOffset), 2.5, Paint()..color = const Color(0xFF37474F));
    }

    canvas.restore();
  }

  void _drawNumberOne(Canvas canvas, Offset center) {
    // Yellow "1" with red drop shadow
    final shadowText = TextPainter(
      text: const TextSpan(
        text: '1',
        style: TextStyle(
          color: Color(0xFFD32F2F),
          fontSize: 18.0,
          fontWeight: FontWeight.w900,
          fontFamily: 'sans-serif',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final mainText = TextPainter(
      text: const TextSpan(
        text: '1',
        style: TextStyle(
          color: Color(0xFFFFEB3B),
          fontSize: 18.0,
          fontWeight: FontWeight.w900,
          fontFamily: 'sans-serif',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    shadowText.paint(canvas, center + const Offset(-4, -10));
    mainText.paint(canvas, center + const Offset(-5, -11));
  }

  void _drawWheel(Canvas canvas, Offset center, double radius, double angle) {
    // Wheel Rim
    final rimPaint = Paint()..color = const Color(0xFF1565C0); // Thomas Blue wheel
    final steelTirePaint = Paint()
      ..color = const Color(0xFF90A4AE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, radius, rimPaint);
    canvas.drawCircle(center, radius, steelTirePaint);

    // Counterweight
    final cwPaint = Paint()..color = const Color(0xFF0D47A1);
    final cwPath = Path()
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius - 1.5),
        angle,
        math.pi * 0.7,
        false,
      )
      ..lineTo(center.dx, center.dy)
      ..close();
    canvas.drawPath(cwPath, cwPaint);

    // Spokes
    final spokePaint = Paint()
      ..color = const Color(0xFF42A5F5)
      ..strokeWidth = 1.5;
    for (int i = 0; i < 6; i++) {
      final a = angle + i * (math.pi / 3);
      canvas.drawLine(
        center,
        center + Offset(math.cos(a) * (radius - 2), math.sin(a) * (radius - 2)),
        spokePaint,
      );
    }

    // Hub cap
    canvas.drawCircle(center, 3.2, Paint()..color = const Color(0xFF263238));
  }

  void _drawSmoke(Canvas canvas) {
    for (final p in controller.smokeParticles) {
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: p.alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
      canvas.drawCircle(Offset(p.x, p.y), p.radius, paint);
    }
  }

  void _drawSparkles(Canvas canvas) {
    for (final p in controller.sparkleParticles) {
      final paint = Paint()..color = p.color.withValues(alpha: p.currentAlpha);

      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rotation);

      // Four-point star
      final r = p.size;
      final starPath = Path()
        ..moveTo(0, -r)
        ..quadraticBezierTo(0, 0, r, 0)
        ..quadraticBezierTo(0, 0, 0, r)
        ..quadraticBezierTo(0, 0, -r, 0)
        ..quadraticBezierTo(0, 0, 0, -r)
        ..close();

      canvas.drawPath(starPath, paint);
      canvas.restore();
    }
  }

  void _drawTouchGuide(Canvas canvas, double width, double height) {
    if (!controller.touchActive || controller.touchPosition == null) return;

    final touchPos = controller.touchPosition!;
    final trackEndX = controller.track.endX;
    final trackEndY = controller.track.endY;

    // Glowing finger touch sparkle
    final touchGlowPaint = Paint()
      ..color = const Color(0x66FFEB3B)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0);
    canvas.drawCircle(touchPos, 22.0, touchGlowPaint);

    final touchRingPaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(touchPos, 14.0, touchRingPaint);

    // Dashed guide curve from track end aiming towards touch height
    final guidePaint = Paint()
      ..color = const Color(0xFFFFEB3B).withValues(alpha: 0.70)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final guidePath = Path();
    guidePath.moveTo(trackEndX - 60, trackEndY);
    guidePath.quadraticBezierTo(
      (trackEndX + touchPos.dx) * 0.5,
      (trackEndY + touchPos.dy) * 0.5,
      touchPos.dx,
      touchPos.dy,
    );

    canvas.drawPath(guidePath, guidePaint);
  }

  @override
  bool shouldRepaint(covariant GameWorldPainter oldDelegate) => true;
}
