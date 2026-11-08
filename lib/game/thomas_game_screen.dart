import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'game_controller.dart';
import 'painters/game_world_painter.dart';

class ThomasGameScreen extends StatefulWidget {
  const ThomasGameScreen({super.key});

  @override
  State<ThomasGameScreen> createState() => _ThomasGameScreenState();
}

class _ThomasGameScreenState extends State<ThomasGameScreen>
    with SingleTickerProviderStateMixin {
  late final GameController _controller;
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  bool _hasStartedPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = GameController();
    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (_lastElapsed == Duration.zero) {
      _lastElapsed = elapsed;
      return;
    }

    final double dt = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
    _lastElapsed = elapsed;

    _controller.update(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          // Re-initialize controller when size is first known or changes
          if (!_controller.isInitialized ||
              _controller.screenWidth != width ||
              _controller.screenHeight != height) {
            _controller.initialize(width, height);
          }

          return Stack(
            children: [
              // 1. Interactive Game Surface
              Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: (event) {
                  setState(() {
                    _hasStartedPlaying = true;
                  });
                  _controller.onPointerDown(event.localPosition);
                },
                onPointerMove: (event) {
                  _controller.onPointerMove(event.localPosition);
                },
                onPointerUp: (event) {
                  _controller.onPointerUp();
                },
                onPointerCancel: (event) {
                  _controller.onPointerUp();
                },
                child: SizedBox(
                  width: width,
                  height: height,
                  child: CustomPaint(
                    painter: GameWorldPainter(controller: _controller),
                  ),
                ),
              ),

              // 2. HUD: Top Bar
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Reset button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            _controller.initialize(width, height);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.refresh, size: 20, color: Color(0xFF1976D2)),
                                SizedBox(width: 4),
                                Text(
                                  'Restart',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Color(0xFF1976D2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Trolls Collected Badge
                      ListenableBuilder(
                        listenable: _controller,
                        builder: (context, _) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF4081), Color(0xFFAB47BC)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  '🌟 Trolls: ',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '${_controller.collectedTrollsCount} / 10',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFFFEB3B),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Victory Celebration Banner (Arrived at Troll Village!)
              ListenableBuilder(
                listenable: _controller,
                builder: (context, _) {
                  if (!_controller.villageStationReached) return const SizedBox.shrink();

                  return Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFFF9C4),
                            Color(0xFFFFFFFF),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFFFF4081), width: 3.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('🎉 ', style: TextStyle(fontSize: 26)),
                              Text(
                                'WELCOME TO TROLL VILLAGE!',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFC2185B),
                                ),
                              ),
                              Text(' 🎉', style: TextStyle(fontSize: 26)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'All 10 Trolls arrived safely! (3 in each cart & 1 with Thomas! 🚂)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1976D2),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 4,
                            ),
                            onPressed: () {
                              _controller.initialize(width, height);
                            },
                            icon: const Icon(Icons.replay, size: 22),
                            label: const Text(
                              'Play Again!',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // 3. Toddler-Friendly Animated Instructions (Fades after play starts)
              if (!_hasStartedPlaying)
                Positioned(
                  top: height * 0.30,
                  left: 20,
                  right: 20,
                  child: IgnorePointer(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFF1976D2), width: 3),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '🚂 Press & hold screen to make Thomas go!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0D47A1),
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              '👆 Move finger UP & DOWN to build mountains & valleys! 🏔️',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF388E3C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
