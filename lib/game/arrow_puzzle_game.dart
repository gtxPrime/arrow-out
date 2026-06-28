import 'dart:async';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/app_colors.dart';
import '../../data/models/arrow.dart';
import '../../data/models/level.dart';
import 'components/grid_component.dart';
import 'game_state.dart';

class ArrowPuzzleGame extends FlameGame {
  // ── State ─────────────────────────────────────────────────────────────────────
  final LevelModel level;
  late GameState gameState;
  GridComponent? gridComponent;

  // ── Callbacks to Flutter ──────────────────────────────────────────────────────
  final void Function() onLevelComplete;
  final void Function() onGameOver;
  final void Function() onLifeLost;

  ArrowPuzzleGame({
    required this.level,
    required this.onLevelComplete,
    required this.onGameOver,
    required this.onLifeLost,
  });

  @override
  Color backgroundColor() => AppColors.gridBg;

  @override
  Future<void> onLoad() async {
    gameState = GameState(
      level: level,
      onLevelComplete: onLevelComplete,
      onGameOver: onGameOver,
      onLifeLost: onLifeLost,
    );

    final gridSize = size.x * 0.92;
    final gridX = (size.x - gridSize) / 2;
    final gridY = (size.y - gridSize) / 2 - 20;

    gridComponent = GridComponent(
      gameState: gameState,
      gridPixelSize: gridSize,
      position: Vector2(gridX, gridY),
    );

    add(gridComponent!);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    final gridSize = size.x * 0.92;
    final gridX = (size.x - gridSize) / 2;
    final gridY = (size.y - gridSize) / 2 - 20;

    if (gridComponent != null) {
      gridComponent!.position = Vector2(gridX, gridY);
      gridComponent!.resize(gridSize);
    }
  }

  /// Reset board to initial state (restart level)
  void resetLevel() {
    gameState.resetLevel();
    gridComponent?.rebuild();
  }
}
