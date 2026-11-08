import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/thomas_game_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to landscape mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Full-screen immersive mode for distraction-free toddler play
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );

  runApp(const ThomasTrollsApp());
}

class ThomasTrollsApp extends StatelessWidget {
  const ThomasTrollsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thomas & Trolls',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1976D2)),
        useMaterial3: true,
      ),
      home: const ThomasGameScreen(),
    );
  }
}
