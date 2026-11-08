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

3. **Sculpting Mountains & Valleys to Catch Trolls**:
   - While driving, moving the touch vertically **above** where the track ends slopes new track **upward** towards the finger, building mountains and hill peaks.
   - Moving the touch **below** where the track ends slopes new track **downward**, building valleys and dips.
   - Releasing touch or holding level gently transitions the track back to horizontal.
   - Thomas and his 3 carriages follow the track curve dynamically, pitching realistically uphill and downhill with animated rotating wheels and moving connecting rods.

4. **10 Trolls & 3 Carts**:
   - Trolls spawn floating at different vertical heights (sky, hills, and valleys).
   - The child must steer the track up or down to align Thomas with the troll's height. If a troll is missed, it floats past harmlessly with no penalty—trolls keep appearing until 10 are collected!
   - Each of the 3 carriages holds 3 trolls (3 in Cart 1, 3 in Cart 2, 3 in Cart 3).
   - The 10th and final troll hops into Thomas's cab window to drive the train!

5. **Arrival at Troll Village & Confetti Celebration**:
   - Collecting 10 trolls brings the train to **Troll Village**!
   - Features giant Troll trees with colorful hanging egg-shaped cocoon pod houses, a festive station platform, and bunting banners.
   - The train automatically stops at the platform and colorful confetti showers down across the screen!

6. **Church-Friendly Design**:
   - 100% silent by default (no jarring audio to disturb quiet meetings).

## 🛠️ Tech Stack & Architecture

- **Flutter 3.x / Dart 3.x**
- **CustomPainter 60/120 FPS Rendering**:
  - `lib/game/game_controller.dart`: Physics loop, speed acceleration/deceleration, track procedural generation, troll spawning at variable heights, 3-cart positioning, and victory state.
  - `lib/game/painters/game_world_painter.dart`: Multi-layer parallax background (sky, smiling sun, drifting clouds, distant mountains, grounded midground hills & trees), Troll Village station, hanging cocoon pods, terrain embankment, steel rails & wooden ties, Thomas engine, 3 passenger carts with seated trolls, driver troll in cab, steam puffs, sparkles, and confetti.
  - `lib/game/models/track_data.dart`: Track point geometry, slope smoothing, height and tangent angle interpolation.
  - `lib/game/models/troll_data.dart`: Troll characters, colors, height coordinates, and pickup animations.
  - `lib/game/models/particle_data.dart`: Animated chimney smoke puffs, pickup star sparkles, and celebration confetti.
  - `lib/game/thomas_game_screen.dart`: Interactive game view with responsive layout, HUD counter (`/ 10`), and victory celebration overlay.

## 🚀 Running the App

```bash
# Run unit and widget tests
flutter test

# Run static analysis
dart analyze

# Run on an attached device or simulator
flutter run
```
