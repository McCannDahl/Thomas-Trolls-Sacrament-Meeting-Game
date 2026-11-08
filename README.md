# Thomas & Trolls: Sacrament Meeting Game

A delightful, toddler-friendly mobile game designed to keep a 3-year-old engaged, happy, and quiet during sacrament meeting.

## 🚂 Gameplay & Mechanics

1. **Horizontal Full-Screen Immersive Experience**:
   - Locked into landscape orientation (`DeviceOrientation.landscapeLeft` / `landscapeRight`).
   - Runs in immersive sticky full-screen mode (`SystemUiMode.immersiveSticky`) with no distracting status or navigation bars.

2. **Touch-to-Drive (Illusion of Acceleration)**:
   - The game starts with Thomas the Tank Engine sitting still on a flat track near the bottom of the screen.
   - Touching and holding anywhere on the screen accelerates the world to the left, creating the sensation of Thomas chugging forward.
   - Releasing the screen smoothly decelerates the train to a gentle stop.

3. **Sculpting Mountains & Valleys**:
   - While driving, if the child moves their finger vertically **above** where the track ends on the screen, new track segments slope **upward** towards the finger, building mountains and hill peaks.
   - If the child moves their finger **below** where the track ends, new track segments slope **downward**, building valleys and dips.
   - Releasing touch or holding level gently transitions the track back to horizontal.
   - Thomas and his carriage follow the track curve dynamically, pitching realistically uphill and downhill with animated rotating wheels and moving connecting rods.

4. **Picking Up Trolls**:
   - Collectible DreamWorks Trolls (Poppy, Branch, Guy Diamond, Tiny Diamond, Cooper, Smidge) spawn along the tracks.
   - When Thomas reaches a Troll, it hops into the train with a burst of colorful star sparkles!
   - Collected Trolls peek out the carriage windows waving happily, and the top HUD tracks the total count.

5. **Church-Friendly Design**:
   - 100% silent by default (no jarring audio to disturb quiet meetings).

## 🛠️ Tech Stack & Architecture

- **Flutter 3.x / Dart 3.x**
- **CustomPainter 60/120 FPS Rendering**:
  - `lib/game/game_controller.dart`: Physics loop, speed acceleration/deceleration, track procedural generation, troll spawning & collision.
  - `lib/game/painters/game_world_painter.dart`: Multi-layer parallax background (sky, smiling sun, drifting clouds, distant mountains, midground hills & trees), terrain embankment, trestle bridge supports, steel rails & wooden ties, Thomas engine, carriage, steam puffs, and sparkles.
  - `lib/game/models/track_data.dart`: Track point geometry, slope smoothing, height and tangent angle interpolation.
  - `lib/game/models/troll_data.dart`: Troll characters, colors, and pickup animation.
  - `lib/game/models/particle_data.dart`: Animated chimney smoke puffs and pickup star sparkles.
  - `lib/game/thomas_game_screen.dart`: Interactive game view with responsive layout and HUD.

## 🚀 Running the App

```bash
# Run unit and widget tests
flutter test

# Run static analysis
dart analyze

# Run on an attached device or simulator
flutter run
```
