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

    // 6. Draw Troll Village (Station, Cocoon Pods, Trees) if reached
    if (controller.villageX != null) {
      _drawTrollVillage(canvas, width, height);
    }

    // 7. Draw Railroad Track (Sleepers & Steel Rails)
    _drawTrack(canvas);

    // 8. Draw Trolls (Floating in air or hopping into train)
    _drawTrolls(canvas);

    // 9. Draw 3 Carriages pulled by Thomas
    _drawCarriages(canvas);

    // 10. Draw Thomas Train
    _drawTrain(canvas);

    // 11. Draw Smoke Puffs
    _drawSmoke(canvas);

    // 12. Draw Sparkles
    _drawSparkles(canvas);

    // 13. Draw Confetti if victory reached
    if (controller.hasWon) {
      _drawConfetti(canvas);
    }

    // 14. Draw Touch Feedback Guide
    _drawTouchGuide(canvas, width, height);
  }

  void _drawSky(Canvas canvas, double width, double height) {
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
    final double scroll = controller.parallaxClouds % loopWidth;
    for (final c in clouds) {
      double x = (c['baseX']! - scroll);
      while (x < -200.0) {
        x += loopWidth;
      }
      while (x > loopWidth - 200.0 && x > width + 100.0) {
        x -= loopWidth;
      }
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

    const mountainSpacing = 280.0;
    final double scroll = controller.parallaxMountains;
    final int startIdx = ((scroll - 300.0) / mountainSpacing).floor();
    final int endIdx = ((scroll + width + 300.0) / mountainSpacing).ceil();

    final path = Path();
    final snowPath = Path();

    path.moveTo(-100, height);

    for (int i = startIdx; i <= endIdx; i++) {
      final leftX = i * mountainSpacing - scroll;
      final peakX = leftX + mountainSpacing * 0.5;
      final rightX = leftX + mountainSpacing;

      final hSeed = math.sin(i * 17.13) * 0.5 + 0.5;
      final peakY = height * 0.32 + hSeed * 50.0;

      if (i == startIdx) {
        path.lineTo(leftX, height * 0.78);
      }
      path.lineTo(peakX, peakY);
      path.lineTo(rightX, height * 0.78);

      snowPath.moveTo(peakX, peakY);
      snowPath.lineTo(peakX - 28, peakY + 38);
      snowPath.lineTo(peakX - 10, peakY + 34);
      snowPath.lineTo(peakX, peakY + 40);
      snowPath.lineTo(peakX + 12, peakY + 32);
      snowPath.lineTo(peakX + 28, peakY + 38);
      snowPath.close();
    }

    path.lineTo(width + 100, height);
    path.close();

    canvas.drawPath(path, mountainPaint);
    canvas.drawPath(snowPath, snowPaint);
  }

  void _drawMidgroundHills(Canvas canvas, double width, double height) {
    final hillPaint = Paint()..color = const Color(0xFF81C784).withValues(alpha: 0.75);

    const hillSpacing = 180.0;
    final double scroll = controller.parallaxHills;
    final int startIdx = ((scroll - 250.0) / hillSpacing).floor();
    final int endIdx = ((scroll + width + 250.0) / hillSpacing).ceil();

    final hillPath = Path();
    hillPath.moveTo(-100, height);

    final List<_TreeData> treesToDraw = [];

    for (int j = startIdx; j <= endIdx; j++) {
      final leftX = j * hillSpacing - scroll;
      final crestX = leftX + hillSpacing * 0.5;
      final rightX = leftX + hillSpacing;

      final hSeed = math.sin(j * 9.71) * 0.5 + 0.5;
      final crestY = height * 0.52 + hSeed * 30.0;
      final baselineY = height * 0.68;

      // Mathematical apex of the quadratic bezier curve at crestX:
      final yApex = (baselineY + crestY) * 0.5;

      if (j == startIdx) {
        hillPath.lineTo(leftX, baselineY);
      }
      hillPath.quadraticBezierTo(crestX, crestY, rightX, baselineY);

      // Trees anchored firmly on top of the green hill crest (no sky floating)
      if (j % 2 == 0) {
        final treeColorIdx = (j.abs() ~/ 2) % 3;
        treesToDraw.add(
          _TreeData(
            position: Offset(crestX, yApex + 2.0),
            colorIndex: treeColorIdx,
          ),
        );
      }
    }

    hillPath.lineTo(width + 100, height);
    hillPath.close();

    canvas.drawPath(hillPath, hillPaint);

    // Draw cartoon trees on the hill tops
    for (final tree in treesToDraw) {
      _drawCartoonTree(canvas, tree.position, 0.85, tree.colorIndex);
    }
  }

  void _drawCartoonTree(Canvas canvas, Offset base, double scale, int colorIndex) {
    final trunkPaint = Paint()
      ..color = const Color(0xFF795548)
      ..strokeWidth = 5.0 * scale
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(base, base + Offset(0, -22 * scale), trunkPaint);

    const foliageColors = [
      Color(0xFF43A047),
      Color(0xFF66BB6A),
      Color(0xFF2E7D32),
    ];
    final color = foliageColors[colorIndex % foliageColors.length];
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

    // Trestle wooden supports at stable world intervals
    final trestleBeamPaint = Paint()
      ..color = const Color(0xFF6D4C41)
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.square;
    final trestleCrossPaint = Paint()
      ..color = const Color(0xFF8D6E63)
      ..strokeWidth = 2.5;

    const double trestleSpacing = 48.0;
    final double worldOffset = controller.totalDistance;
    final int startK = ((worldOffset - 40.0) / trestleSpacing).floor();
    final int endK = ((worldOffset + width + 40.0) / trestleSpacing).ceil();

    final groundBaseline = height;

    for (int k = startK; k <= endK; k++) {
      final double screenX = k * trestleSpacing - worldOffset;
      if (screenX < -30.0 || screenX > width + 30.0) continue;

      final double trackY = controller.track.getHeightAt(screenX);

      if (groundBaseline - trackY > 110.0) {
        canvas.drawLine(Offset(screenX - 7, trackY + 8), Offset(screenX - 12, groundBaseline), trestleBeamPaint);
        canvas.drawLine(Offset(screenX + 7, trackY + 8), Offset(screenX + 12, groundBaseline), trestleBeamPaint);

        for (double by = trackY + 30; by < groundBaseline - 15; by += 40) {
          canvas.drawLine(Offset(screenX - 8, by), Offset(screenX + 8, by + 35), trestleCrossPaint);
          canvas.drawLine(Offset(screenX + 8, by), Offset(screenX - 8, by + 35), trestleCrossPaint);
          canvas.drawLine(Offset(screenX - 9, by), Offset(screenX + 9, by), trestleCrossPaint);
        }
      }
    }

    // Solid Lush Green Rolling Hill under the track
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

  void _drawTrollVillage(Canvas canvas, double width, double height) {
    final double vx = controller.villageX!;
    final double vy = controller.track.getHeightAt(vx);

    // 1. Giant DreamWorks Troll Trees with Canopy Branches
    final treePaint = Paint()..color = const Color(0xFF5D4037);
    final canopyPaint = Paint()..color = const Color(0xFF00E676).withValues(alpha: 0.85);

    // Tree 1 Trunk
    final trunk1 = Path()
      ..moveTo(vx - 20, height)
      ..lineTo(vx + 10, vy - 120)
      ..lineTo(vx + 45, vy - 120)
      ..lineTo(vx + 60, height)
      ..close();
    canvas.drawPath(trunk1, treePaint);

    // Canopy foliage
    canvas.drawCircle(Offset(vx + 25, vy - 140), 65, canopyPaint);
    canvas.drawCircle(Offset(vx + 80, vy - 160), 55, canopyPaint);
    canvas.drawCircle(Offset(vx - 20, vy - 150), 50, canopyPaint);

    // Tree 2 Trunk (farther right)
    final trunk2 = Path()
      ..moveTo(vx + 160, height)
      ..lineTo(vx + 185, vy - 110)
      ..lineTo(vx + 215, vy - 110)
      ..lineTo(vx + 230, height)
      ..close();
    canvas.drawPath(trunk2, treePaint);
    canvas.drawCircle(Offset(vx + 200, vy - 135), 60, canopyPaint);
    canvas.drawCircle(Offset(vx + 245, vy - 150), 50, canopyPaint);

    // 2. Hanging Egg-Shaped Cocoon Pod Houses
    // Pod 1: Hot Pink Cocoon
    _drawCocoonPod(
      canvas,
      anchor: Offset(vx - 10, vy - 140),
      podCenter: Offset(vx - 15, vy - 85),
      podColor: const Color(0xFFFF1493),
      capColor: const Color(0xFF00E5FF),
    );

    // Pod 2: Bright Golden Yellow Cocoon
    _drawCocoonPod(
      canvas,
      anchor: Offset(vx + 45, vy - 150),
      podCenter: Offset(vx + 40, vy - 95),
      podColor: const Color(0xFFFFD700),
      capColor: const Color(0xFFFF4081),
    );

    // Pod 3: Glitter Cyan Cocoon
    _drawCocoonPod(
      canvas,
      anchor: Offset(vx + 115, vy - 155),
      podCenter: Offset(vx + 110, vy - 100),
      podColor: const Color(0xFF00E5FF),
      capColor: const Color(0xFFAB47BC),
    );

    // Pod 4: Royal Purple Cocoon
    _drawCocoonPod(
      canvas,
      anchor: Offset(vx + 180, vy - 130),
      podCenter: Offset(vx + 175, vy - 80),
      podColor: const Color(0xFFAB47BC),
      capColor: const Color(0xFF76FF03),
    );

    // 3. Station Platform & Wooden Shelter
    final platformPaint = Paint()..color = const Color(0xFF8D6E63);
    final platformTopPaint = Paint()..color = const Color(0xFFA1887F);
    final platformRect = Rect.fromLTWH(vx - 40, vy - 4, 300, 18);
    canvas.drawRect(platformRect, platformPaint);
    canvas.drawRect(Rect.fromLTWH(vx - 40, vy - 6, 300, 4), platformTopPaint);

    // Festive Bunting Flags between posts
    final flagColors = [
      const Color(0xFFFF1493),
      const Color(0xFFFFEB3B),
      const Color(0xFF00E5FF),
      const Color(0xFF76FF03),
      const Color(0xFFFF5722),
    ];

    final polePaint = Paint()
      ..color = const Color(0xFF4E342E)
      ..strokeWidth = 3.5;
    canvas.drawLine(Offset(vx - 20, vy - 6), Offset(vx - 20, vy - 50), polePaint);
    canvas.drawLine(Offset(vx + 240, vy - 6), Offset(vx + 240, vy - 50), polePaint);

    // Bunting cord
    final cordPath = Path()
      ..moveTo(vx - 20, vy - 46)
      ..quadraticBezierTo(vx + 110, vy - 32, vx + 240, vy - 46);
    canvas.drawPath(
      cordPath,
      Paint()
        ..color = const Color(0xFFFFF9C4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Bunting triangular flags
    for (int f = 0; f < 9; f++) {
      final t = (f + 0.5) / 9.0;
      final fx = (vx - 20) + 260.0 * t;
      final fy = (vy - 46) + math.sin(t * math.pi) * 14.0;
      final fColor = flagColors[f % flagColors.length];

      final flagPath = Path()
        ..moveTo(fx - 7, fy)
        ..lineTo(fx + 7, fy)
        ..lineTo(fx, fy + 12)
        ..close();
      canvas.drawPath(flagPath, Paint()..color = fColor);
    }

    // 4. Village Station Signboard on platform posts (placed low so it doesn't block cocoons)
    final signCenter = Offset(vx - 5, vy - 24);
    final signBg = RRect.fromRectAndRadius(
      Rect.fromCenter(center: signCenter, width: 110, height: 18),
      const Radius.circular(5),
    );

    final postPaint = Paint()
      ..color = const Color(0xFF4E342E)
      ..strokeWidth = 2.5;
    canvas.drawLine(Offset(vx - 45, vy - 4), Offset(vx - 45, vy - 24), postPaint);
    canvas.drawLine(Offset(vx + 35, vy - 4), Offset(vx + 35, vy - 24), postPaint);

    canvas.drawRRect(signBg, Paint()..color = const Color(0xFF880E4F));
    canvas.drawRRect(
      signBg,
      Paint()
        ..color = const Color(0xFFFFD54F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    final signText = TextPainter(
      text: const TextSpan(
        text: '🌸 TROLL VILLAGE 🌸',
        style: TextStyle(
          color: Colors.white,
          fontSize: 9.0,
          fontWeight: FontWeight.w900,
          fontFamily: 'sans-serif',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    signText.paint(canvas, Offset(signCenter.dx - signText.width / 2, signCenter.dy - signText.height / 2));
  }

  void _drawCocoonPod(
    Canvas canvas, {
    required Offset anchor,
    required Offset podCenter,
    required Color podColor,
    required Color capColor,
  }) {
    // Hanging vine thread
    final vinePaint = Paint()
      ..color = const Color(0xFF43A047)
      ..strokeWidth = 2.0;
    canvas.drawLine(anchor, podCenter + const Offset(0, -22), vinePaint);

    // Pod Leaf Cap
    final capPaint = Paint()..color = capColor;
    final capPath = Path()
      ..moveTo(podCenter.dx - 14, podCenter.dy - 16)
      ..quadraticBezierTo(podCenter.dx, podCenter.dy - 25, podCenter.dx + 14, podCenter.dy - 16)
      ..close();
    canvas.drawPath(capPath, capPaint);

    // Egg-shaped cocoon body
    final podRect = Rect.fromCenter(center: podCenter, width: 28, height: 38);
    canvas.drawOval(podRect, Paint()..color = podColor);

    // Pod highlight shine
    final shinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawArc(podRect.deflate(3.0), -2.2, 1.2, false, shinePaint);

    // Cozy lit circular window with warm golden glow
    final winCenter = podCenter + const Offset(0, 2);
    canvas.drawCircle(winCenter, 6.0, Paint()..color = const Color(0xFFFFF176));
    canvas.drawCircle(
      winCenter,
      6.0,
      Paint()
        ..color = const Color(0xFFFFD54F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    // Window cross pane
    canvas.drawLine(winCenter - const Offset(5, 0), winCenter + const Offset(5, 0), Paint()..color = const Color(0xFFF57F17));
    canvas.drawLine(winCenter - const Offset(0, 5), winCenter + const Offset(0, 5), Paint()..color = const Color(0xFFF57F17));
  }

  void _drawTrack(Canvas canvas) {
    final points = controller.track.points;
    if (points.length < 2) return;

    // Wooden Ties along the curve
    final tiePaint = Paint()
      ..color = const Color(0xFF4E342E)
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
        canvas.drawLine(
          top + Offset(normalY * 1.5, -normalX * 1.5),
          bottom + Offset(normalY * 1.5, -normalX * 1.5),
          tieHighlightPaint,
        );
      }
    }

    // Parallel Steel Rails
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

      canvas.drawPath(
        railPath,
        Paint()
          ..color = baseColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.8
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );

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

    drawRail(railOffsets, const Color(0xFF37474F), const Color(0xFF78909C));
    drawRail(-railOffsets, const Color(0xFF263238), const Color(0xFFCFD8DC));
  }

  void _drawTrolls(Canvas canvas) {
    // Uncollected floating trolls
    for (final troll in controller.trolls) {
      _drawStandingTroll(canvas, troll);
    }
    // Hopping collected trolls in mid-air
    for (final troll in controller.collectedTrolls) {
      if (troll.collectionProgress < 1.0) {
        _drawCollectedTrollHop(canvas, troll);
      }
    }
  }

  void _drawStandingTroll(Canvas canvas, TrollData troll) {
    // Trolls appear at diverse heights with a cute little floating cloud under them
    final bounceY = math.sin(troll.bouncePhase) * 4.0;
    final posY = troll.y + bounceY;

    canvas.save();
    canvas.translate(troll.x, posY);

    // Floating cloud platform beneath troll's feet
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.88);
    final cloudShadow = Paint()..color = const Color(0xFFBBDEFB).withValues(alpha: 0.80);
    canvas.drawCircle(const Offset(-8, 3), 7, cloudShadow);
    canvas.drawCircle(const Offset(8, 3), 7, cloudShadow);
    canvas.drawCircle(const Offset(0, 1), 9, cloudShadow);
    canvas.drawCircle(const Offset(-8, 1), 7, cloudPaint);
    canvas.drawCircle(const Offset(8, 1), 7, cloudPaint);
    canvas.drawCircle(const Offset(0, -1), 9, cloudPaint);

    _drawTrollFigure(canvas, troll, isWaving: true);

    canvas.restore();
  }

  void _drawCollectedTrollHop(Canvas canvas, TrollData troll) {
    if (troll.collectionProgress >= 1.0) return;

    final progress = troll.collectionProgress;
    final startX = troll.x;
    final startY = troll.y;

    double targetX;
    double targetY;

    if (troll.collectedOrder >= 0 && troll.collectedOrder < 9) {
      final cartIdx = troll.collectedOrder ~/ 3;
      final winIdx = troll.collectedOrder % 3;
      final cartX = controller.getCartX(cartIdx);
      targetX = cartX + (winIdx - 1) * 14.0;
      targetY = controller.track.getHeightAt(cartX) - 20.0;
    } else {
      // 10th troll hops into Thomas's cab window
      targetX = controller.trainX - 22.0;
      targetY = controller.track.getHeightAt(controller.trainX) - 30.0;
    }

    final currentX = startX + (targetX - startX) * progress;
    final arcHeight = math.sin(progress * math.pi) * 80.0;
    final currentY = (startY + (targetY - startY) * progress) - arcHeight;

    canvas.save();
    canvas.translate(currentX, currentY);
    canvas.rotate(progress * math.pi * 2.0);

    _drawTrollFigure(canvas, troll, isWaving: true, scale: 1.0 - progress * 0.35);

    canvas.restore();
  }

  void _drawTrollFigure(
    Canvas canvas,
    TrollData troll, {
    bool isWaving = false,
    double scale = 1.0,
  }) {
    canvas.scale(scale, scale);

    final bodyPaint = Paint()..color = troll.skinColor;
    final outfitPaint = Paint()
      ..color = troll.type == TrollType.poppy
          ? const Color(0xFF039BE5)
          : (troll.type == TrollType.branch ? const Color(0xFF6D4C41) : const Color(0xFFFFB300));

    // Feet
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-5, -3), width: 7, height: 5),
      bodyPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(5, -3), width: 7, height: 5),
      bodyPaint,
    );

    // Dress / Vest
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
      canvas.drawLine(const Offset(-6, -14), const Offset(-14, -24), armPaint);
      canvas.drawCircle(const Offset(-14, -24), 2.5, bodyPaint);
      canvas.drawLine(const Offset(6, -14), const Offset(14, -18), armPaint);
      canvas.drawCircle(const Offset(14, -18), 2.5, bodyPaint);
    } else {
      canvas.drawLine(const Offset(-6, -14), const Offset(-12, -8), armPaint);
      canvas.drawLine(const Offset(6, -14), const Offset(12, -8), armPaint);
    }

    // Big Pointy DreamWorks Troll Hair
    final hairPaint = Paint()..color = troll.hairColor;
    final hairPath = Path();
    hairPath.moveTo(-11, -22);
    hairPath.quadraticBezierTo(-18, -35, -12, -50);
    hairPath.quadraticBezierTo(-5, -64, 0, -70);
    hairPath.quadraticBezierTo(5, -64, 12, -50);
    hairPath.quadraticBezierTo(18, -35, 11, -22);
    hairPath.close();
    canvas.drawPath(hairPath, hairPaint);

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
      canvas.drawCircle(const Offset(-7, -23), 3.0, Paint()..color = const Color(0xFF00E5FF));
      canvas.drawCircle(const Offset(0, -25), 3.5, Paint()..color = const Color(0xFFFF4081));
      canvas.drawCircle(const Offset(7, -23), 3.0, Paint()..color = const Color(0xFF00E5FF));
    }

    // Cute Face & Head
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, -20), width: 18, height: 14),
      bodyPaint,
    );

    // Pointy Troll Ears
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

    // Eyes
    final eyePaint = Paint()..color = const Color(0xFF212121);
    canvas.drawCircle(const Offset(-3.5, -21), 2.2, eyePaint);
    canvas.drawCircle(const Offset(3.5, -21), 2.2, eyePaint);
    final eyeGleam = Paint()..color = Colors.white;
    canvas.drawCircle(const Offset(-4.0, -22), 0.9, eyeGleam);
    canvas.drawCircle(const Offset(3.0, -22), 0.9, eyeGleam);

    // Button Nose
    canvas.drawCircle(
      const Offset(0, -19),
      1.8,
      Paint()..color = troll.skinColor.withValues(alpha: 0.85),
    );

    // Smile
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

  void _drawCarriages(Canvas canvas) {
    // 3 Carts behind Thomas (Cart 0, Cart 1, Cart 2)
    // Cart 0 holds trolls 1, 2, 3
    // Cart 1 holds trolls 4, 5, 6
    // Cart 2 holds trolls 7, 8, 9
    final cartColors = [
      const Color(0xFFC62828), // Clarabel / Annie Red
      const Color(0xFFE65100), // Amber / Warm Orange Coach
      const Color(0xFF6A1B9A), // Royal Plum Coach
    ];

    for (int c = 2; c >= 0; c--) {
      final cartX = controller.getCartX(c);
      final trackY = controller.track.getHeightAt(cartX);
      final angle = controller.track.getAngleAt(cartX);

      canvas.save();
      canvas.translate(cartX, trackY);
      canvas.rotate(angle);

      // Coupler linking forward
      final nextVehicleX = (c == 0) ? controller.trainX : controller.getCartX(c - 1);
      final couplerLength = nextVehicleX - cartX;

      final couplerPaint = Paint()
        ..color = const Color(0xFF212121)
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(const Offset(24, -10), Offset(24 + (couplerLength - 48), -10), couplerPaint);

      // Coach body
      const coachWidth = 48.0;
      const coachHeight = 34.0;
      final coachRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: const Offset(0, -coachHeight / 2 - 8),
          width: coachWidth,
          height: coachHeight,
        ),
        const Radius.circular(5.0),
      );

      canvas.drawRRect(coachRect, Paint()..color = cartColors[c]);
      canvas.drawRRect(
        coachRect,
        Paint()
          ..color = const Color(0xFFFFD54F)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );

      // Coach curved roof
      final roofPaint = Paint()..color = const Color(0xFF37474F);
      final roofPath = Path()
        ..moveTo(-coachWidth / 2 - 2, -coachHeight - 8)
        ..quadraticBezierTo(0, -coachHeight - 16, coachWidth / 2 + 2, -coachHeight - 8)
        ..close();
      canvas.drawPath(roofPath, roofPaint);

      // 3 Passenger Windows for this cart
      final windowPaint = Paint()..color = const Color(0xFFFFF9C4);
      final windowFramePaint = Paint()
        ..color = const Color(0xFFFFD54F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3;

      for (int w = 0; w < 3; w++) {
        final winX = (w - 1) * 14.0;
        final wRect = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(winX, -coachHeight / 2 - 9),
            width: 9,
            height: 13,
          ),
          const Radius.circular(3.0),
        );
        canvas.drawRRect(wRect, windowPaint);
        canvas.drawRRect(wRect, windowFramePaint);

        // Find if the troll for this cart and window is collected
        final trollOrder = c * 3 + w;
        final seatedTroll = controller.collectedTrolls.cast<TrollData?>().firstWhere(
          (t) => t != null && t.collectedOrder == trollOrder && t.collectionProgress >= 1.0,
          orElse: () => null,
        );

        if (seatedTroll != null) {
          canvas.save();
          final winBounce = math.sin(seatedTroll.bouncePhase) * 1.2;
          canvas.translate(winX, -coachHeight / 2 - 1 + winBounce);
          _drawTrollFigure(canvas, seatedTroll, scale: 0.38);
          canvas.restore();
        }
      }

      // Wheels
      _drawWheel(canvas, const Offset(-15, -7), 7.0, controller.wheelAngle);
      _drawWheel(canvas, const Offset(15, -7), 7.0, controller.wheelAngle);

      canvas.restore();
    }
  }

  void _drawTrain(Canvas canvas) {
    final trainX = controller.trainX;

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
    // Chassis & Running Board (Red)
    final runningBoardPaint = Paint()..color = const Color(0xFFD32F2F);
    final chassisRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(0, -9), width: 88, height: 7),
      const Radius.circular(3.0),
    );
    canvas.drawRRect(chassisRect, runningBoardPaint);

    // Front & Back Buffers
    final bufferPaint = Paint()..color = const Color(0xFF212121);
    canvas.drawCircle(const Offset(45, -9), 4.5, bufferPaint);
    canvas.drawCircle(const Offset(-45, -9), 4.5, bufferPaint);

    // 1. Cab
    final cabPaint = Paint()..color = const Color(0xFF1976D2);
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

    // Brass Whistle
    final whistlePaint = Paint()..color = const Color(0xFFFFD54F);
    canvas.drawRect(const Rect.fromLTWH(-18, -55, 3.5, 9), whistlePaint);

    // Cab Window (Arched) - Where the 10th Troll Driver rides!
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

    // Troll 10 in the driver's window!
    final driverTroll = controller.collectedTrolls.cast<TrollData?>().firstWhere(
      (t) => t != null && t.collectedOrder == 9 && t.collectionProgress >= 1.0,
      orElse: () => null,
    );
    if (driverTroll != null) {
      canvas.save();
      final winBounce = math.sin(driverTroll.bouncePhase) * 1.2;
      canvas.translate(-22, -22 + winBounce);
      _drawTrollFigure(canvas, driverTroll, scale: 0.42);
      canvas.restore();
    }

    // 2. Boiler & Side Tanks
    final boilerRect = Rect.fromLTWH(-6, -38, 32, 26);
    canvas.drawRect(boilerRect, cabPaint);

    final stripePaint = Paint()
      ..color = const Color(0xFFD32F2F)
      ..strokeWidth = 2.0;
    canvas.drawLine(const Offset(-5, -36), const Offset(24, -36), stripePaint);
    canvas.drawLine(const Offset(-5, -14), const Offset(24, -14), stripePaint);

    // Number "1"
    _drawNumberOne(canvas, const Offset(10, -25));

    // Brass Dome
    final domePaint = Paint()..color = const Color(0xFFFFD54F);
    final domePath = Path()
      ..moveTo(4, -38)
      ..quadraticBezierTo(9, -49, 14, -38)
      ..close();
    canvas.drawPath(domePath, domePaint);

    // 3. Smokebox & Chimney
    final smokeboxPaint = Paint()..color = const Color(0xFF263238);
    final smokeboxRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(32, -26), width: 20, height: 26),
      const Radius.circular(3.0),
    );
    canvas.drawRRect(smokeboxRect, smokeboxPaint);

    final chimneyPath = Path()
      ..moveTo(27, -38)
      ..lineTo(26, -53)
      ..lineTo(37, -53)
      ..lineTo(36, -38)
      ..close();
    canvas.drawPath(chimneyPath, smokeboxPaint);
    canvas.drawLine(const Offset(25, -53), const Offset(38, -53), domePaint..strokeWidth = 2.5);

    // 4. Face Plate
    final faceCenter = const Offset(42, -26);
    final facePaint = Paint()..color = const Color(0xFFECEFF1);
    final faceBorderPaint = Paint()
      ..color = const Color(0xFF90A4AE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(faceCenter, 13.0, facePaint);
    canvas.drawCircle(faceCenter, 13.0, faceBorderPaint);

    // Eyes
    final eyeWhite = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = const Color(0xFF1565C0);
    final pupilBlack = Paint()..color = const Color(0xFF212121);
    final eyeGleam = Paint()..color = Colors.white;

    canvas.drawOval(Rect.fromCenter(center: faceCenter + const Offset(-4, -3), width: 6.5, height: 7.5), eyeWhite);
    canvas.drawOval(Rect.fromCenter(center: faceCenter + const Offset(4, -3), width: 6.5, height: 7.5), eyeWhite);

    canvas.drawCircle(faceCenter + const Offset(-2.8, -3), 2.2, pupilPaint);
    canvas.drawCircle(faceCenter + const Offset(5.2, -3), 2.2, pupilPaint);
    canvas.drawCircle(faceCenter + const Offset(-2.8, -3), 1.2, pupilBlack);
    canvas.drawCircle(faceCenter + const Offset(5.2, -3), 1.2, pupilBlack);
    canvas.drawCircle(faceCenter + const Offset(-3.2, -4), 0.8, eyeGleam);
    canvas.drawCircle(faceCenter + const Offset(4.8, -4), 0.8, eyeGleam);

    final browPaint = Paint()
      ..color = const Color(0xFF455A64)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCenter(center: faceCenter + const Offset(-4, -7), width: 6, height: 3), 0.3, math.pi - 0.6, false, browPaint);
    canvas.drawArc(Rect.fromCenter(center: faceCenter + const Offset(4, -7), width: 6, height: 3), 0.3, math.pi - 0.6, false, browPaint);

    final cheekPaint = Paint()..color = const Color(0xFFFF8A80).withValues(alpha: 0.50);
    canvas.drawCircle(faceCenter + const Offset(-8, 1), 3.0, cheekPaint);
    canvas.drawCircle(faceCenter + const Offset(8, 1), 3.0, cheekPaint);

    canvas.drawCircle(faceCenter + const Offset(0, 0), 1.6, Paint()..color = const Color(0xFFB0BEC5));

    final mouthPaint = Paint()
      ..color = const Color(0xFFB71C1C)
      ..style = PaintingStyle.fill;
    final mouthPath = Path()
      ..moveTo(faceCenter.dx - 5.5, faceCenter.dy + 3.5)
      ..quadraticBezierTo(faceCenter.dx, faceCenter.dy + 9.5, faceCenter.dx + 5.5, faceCenter.dy + 3.5)
      ..close();
    canvas.drawPath(mouthPath, mouthPaint);

    // 5. Wheels & Connecting Rods
    const double wheelR = 10.5;
    final wheelPositions = [
      const Offset(-28, -6),
      const Offset(2, -6),
      const Offset(30, -6),
    ];

    for (final pos in wheelPositions) {
      _drawWheel(canvas, pos, wheelR, controller.wheelAngle);
    }

    final rodAngle = controller.wheelAngle;
    const pinDist = 6.0;
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

    for (final pos in wheelPositions) {
      canvas.drawCircle(Offset(pos.dx + rodXOffset, pos.dy + rodYOffset), 2.5, Paint()..color = const Color(0xFF37474F));
    }

    canvas.restore();
  }

  void _drawNumberOne(Canvas canvas, Offset center) {
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
    final rimPaint = Paint()..color = const Color(0xFF1565C0);
    final steelTirePaint = Paint()
      ..color = const Color(0xFF90A4AE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, radius, rimPaint);
    canvas.drawCircle(center, radius, steelTirePaint);

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

  void _drawConfetti(Canvas canvas) {
    for (final p in controller.confettiParticles) {
      final paint = Paint()..color = p.color;

      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rotation);

      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: p.width,
        height: p.height,
      );
      canvas.drawRect(rect, paint);

      canvas.restore();
    }
  }

  void _drawTouchGuide(Canvas canvas, double width, double height) {
    if (!controller.touchActive || controller.touchPosition == null || controller.hasWon) return;

    final touchPos = controller.touchPosition!;
    final trackEndX = controller.track.endX;
    final trackEndY = controller.track.endY;

    final touchGlowPaint = Paint()
      ..color = const Color(0x66FFEB3B)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0);
    canvas.drawCircle(touchPos, 22.0, touchGlowPaint);

    final touchRingPaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(touchPos, 14.0, touchRingPaint);

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

class _TreeData {
  final Offset position;
  final int colorIndex;

  _TreeData({required this.position, required this.colorIndex});
}
