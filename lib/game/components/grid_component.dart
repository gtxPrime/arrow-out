import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../core/constants.dart';
import '../../../data/models/arrow.dart';
import '../game_state.dart';
import 'arrow_component.dart';

/// Renders the NxN grid and all arrow components inside it.
class GridComponent extends PositionComponent {
  final GameState gameState;
  double gridPixelSize;

  final Map<String, ArrowComponent> _arrowComponents = {};

  GridComponent({
    required this.gameState,
    required this.gridPixelSize,
    required Vector2 position,
  }) : super(position: position);

  double get cellSize => gridPixelSize / gameState.level.gridSize;

  @override
  Future<void> onLoad() async {
    size = Vector2.all(gridPixelSize);
    _buildArrows();
  }

  void _buildArrows() {
    removeAll(children.whereType<ArrowComponent>());
    _arrowComponents.clear();

    for (final arrow in gameState.arrows) {
      final comp = ArrowComponent(
        arrowModel: arrow,
        cellSize: cellSize,
        gameState: gameState,
      )..position = Vector2(
          arrow.col * cellSize,
          arrow.row * cellSize,
        );
      _arrowComponents[arrow.id] = comp;
      add(comp);
    }
  }

  void rebuild() => _buildArrows();

  void resize(double newGridPixelSize) {
    gridPixelSize = newGridPixelSize;
    size = Vector2.all(gridPixelSize);
    for (final child in children) {
      if (child is ArrowComponent) {
        child.updateCellSize(cellSize);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final gridSize = gameState.level.gridSize;

    // Draw grid of faint dots at the center of each cell
    final dotPaint = Paint()
      ..color = const Color(0xFFDCD5C5)
      ..style = PaintingStyle.fill;

    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        final cx = (c + 0.5) * cellSize;
        final cy = (r + 0.5) * cellSize;
        canvas.drawCircle(Offset(cx, cy), 1.8, dotPaint);
      }
    }

    super.render(canvas);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Remove exited arrows from components
    final currentIds = gameState.arrows.map((a) => a.id).toSet();
    final toRemove = _arrowComponents.keys.where((id) => !currentIds.contains(id)).toList();
    for (final id in toRemove) {
      _arrowComponents[id]?.removeFromParent();
      _arrowComponents.remove(id);
    }
  }
}
