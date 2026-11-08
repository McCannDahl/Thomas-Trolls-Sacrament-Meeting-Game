import 'package:flutter/material.dart';

enum TrollType {
  poppy,
  branch,
  guyDiamond,
  tinyDiamond,
  cooper,
  smidge,
}

class TrollData {
  double x;
  double y; // Specific vertical height where this troll is positioned in the world
  final TrollType type;
  bool isCollected;
  double collectionProgress; // 0.0 -> 1.0 when hopping into train
  double bouncePhase;
  int collectedOrder; // 0..9: order in which troll was collected

  TrollData({
    required this.x,
    required this.y,
    required this.type,
    this.isCollected = false,
    this.collectionProgress = 0.0,
    this.bouncePhase = 0.0,
    this.collectedOrder = -1,
  });

  Color get hairColor {
    switch (type) {
      case TrollType.poppy:
        return const Color(0xFFFF1493); // Hot Pink
      case TrollType.branch:
        return const Color(0xFF1E88E5); // Ocean Blue/Indigo
      case TrollType.guyDiamond:
        return const Color(0xFFE0F7FA); // Shimmering Ice/Silver
      case TrollType.tinyDiamond:
        return const Color(0xFFFFD700); // Shimmering Gold
      case TrollType.cooper:
        return const Color(0xFFAB47BC); // Purple/Pink
      case TrollType.smidge:
        return const Color(0xFF00E5FF); // Electric Cyan
    }
  }

  Color get skinColor {
    switch (type) {
      case TrollType.poppy:
        return const Color(0xFFFF8DA1); // Soft pink
      case TrollType.branch:
        return const Color(0xFF78909C); // Slate cyan
      case TrollType.guyDiamond:
        return const Color(0xFFECEFF1); // Silver
      case TrollType.tinyDiamond:
        return const Color(0xFFFFF9C4); // Pale gold
      case TrollType.cooper:
        return const Color(0xFFFF80AB); // Pink
      case TrollType.smidge:
        return const Color(0xFFFFCC80); // Light orange
    }
  }

  String get name {
    switch (type) {
      case TrollType.poppy:
        return 'Poppy';
      case TrollType.branch:
        return 'Branch';
      case TrollType.guyDiamond:
        return 'Guy Diamond';
      case TrollType.tinyDiamond:
        return 'Tiny Diamond';
      case TrollType.cooper:
        return 'Cooper';
      case TrollType.smidge:
        return 'Smidge';
    }
  }

  void update(double dt, double dx) {
    x -= dx;
    bouncePhase += dt * 5.0;

    if (isCollected && collectionProgress < 1.0) {
      collectionProgress = (collectionProgress + dt * 2.2).clamp(0.0, 1.0);
    }
  }
}
