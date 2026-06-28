import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../core/constants.dart';
import '../../../data/models/arrow.dart';
import '../game_state.dart';
import 'particle_effect.dart';

/// Renders a single arrow cell and handles tap → slide/block animation.
class ArrowComponent extends PositionComponent with TapCallbacks, HasPaint {
  ArrowModel arrowModel;
  double cellSize;
  final GameState gameState;

  void updateCellSize(double newCellSize) {
    cellSize = newCellSize;
    size = Vector2.all(cellSize);
    if (arrowModel.state != ArrowState.sliding) {
      position = Vector2(
        arrowModel.col * cellSize,
        arrowModel.row * cellSize,
      );
    }
  }

  // Visual state
  double _glowIntensity = 0.0;
  bool _isPressing = false;
  bool _isAnimating = false;

  // Colors per direction
  static Color _colorForDirection(ArrowDirection dir) {
    switch (dir) {
      case ArrowDirection.up:    return AppColors.arrowUp;
      case ArrowDirection.down:  return AppColors.arrowDown;
      case ArrowDirection.left:  return AppColors.arrowLeft;
      case ArrowDirection.right: return AppColors.arrowRight;
    }
  }

  ArrowComponent({
    required this.arrowModel,
    required this.cellSize,
    required this.gameState,
  }) : super(size: Vector2.all(cellSize));

  @override
  void onTapDown(TapDownEvent event) {
    if (_isAnimating) return;
    _isPressing = true;
    _glowIntensity = 1.0;
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (_isAnimating) return;
    _isPressing = false;
    _triggerMove();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _isPressing = false;
    _glowIntensity = 0.0;
  }

  void _triggerMove() {
    if (_isAnimating) return;
    _isAnimating = true;

    final result = gameState.tapArrow(arrowModel.id);

    switch (result) {
      case TapResult.exited:
        _playExitAnimation();
        break;
      case TapResult.blocked:
        _playBlockAnimation();
        break;
      case TapResult.ignored:
        _isAnimating = false;
        _glowIntensity = 0.0;
        break;
    }
  }

  void _playExitAnimation() {
    final delta = arrowModel.direction.delta;
    final targetX = position.x + delta[1] * cellSize * (gameState.level.gridSize + 1);
    final targetY = position.y + delta[0] * cellSize * (gameState.level.gridSize + 1);

    // Spawn particle burst at the center of this cell
    parent?.add(ExitParticleEffect(
      position: position + Vector2.all(cellSize / 2),
      direction: arrowModel.direction,
    ));

    // Slide out + fade out
    add(SequenceEffect([
      MoveEffect.to(
        Vector2(targetX, targetY),
        EffectController(duration: AppConstants.arrowSlideDuration.inMilliseconds / 1000),
      ),
      OpacityEffect.fadeOut(
        EffectController(duration: 0.1),
      ),
    ], onComplete: () {
      removeFromParent();
    }));

    // Scale pulse on tap
    add(ScaleEffect.to(
      Vector2.all(1.15),
      EffectController(duration: 0.08, reverseDuration: 0.08),
    ));
  }

  void _playBlockAnimation() {
    // Shake horizontally
    final originalX = position.x;
    add(SequenceEffect([
      MoveEffect.to(
        Vector2(originalX + 6, position.y),
        EffectController(duration: 0.05),
      ),
      MoveEffect.to(
        Vector2(originalX - 6, position.y),
        EffectController(duration: 0.05),
      ),
      MoveEffect.to(
        Vector2(originalX + 4, position.y),
        EffectController(duration: 0.04),
      ),
      MoveEffect.to(
        Vector2(originalX - 4, position.y),
        EffectController(duration: 0.04),
      ),
      MoveEffect.to(
        Vector2(originalX, position.y),
        EffectController(duration: 0.04),
      ),
    ], onComplete: () {
      _glowIntensity = 0.0;
      _isAnimating = false;
    }));
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Fade glow
    if (!_isPressing && _glowIntensity > 0) {
      _glowIntensity = (_glowIntensity - dt * 3).clamp(0.0, 1.0);
    }
    // Update model from state
    final updated = gameState.arrows.where((a) => a.id == arrowModel.id).firstOrNull;
    if (updated != null) arrowModel = updated;
  }

  double _getPathLength() {
    final delta = arrowModel.direction.delta;
    int r = arrowModel.row + delta[0];
    int c = arrowModel.col + delta[1];
    final gridSize = gameState.level.gridSize;
    int steps = 0;

    bool blocked = false;
    while (r >= 0 && r < gridSize && c >= 0 && c < gridSize) {
      steps++;
      final hasArrow = gameState.arrows.any((a) => a.id != arrowModel.id && a.row == r && a.col == c);
      if (hasArrow) {
        blocked = true;
        break;
      }
      r += delta[0];
      c += delta[1];
    }

    if (blocked) {
      return steps * cellSize;
    } else {
      // Goes to the boundary
      return (steps + 0.5) * cellSize;
    }
  }

  @override
  void render(Canvas canvas) {
    final isBlocked = arrowModel.state == ArrowState.blocked;
    final baseColor = isBlocked ? AppColors.accent : _colorForDirection(arrowModel.direction);

    // Apply current opacity from HasPaint
    final paintColor = baseColor.withOpacity(opacity);

    canvas.save();
    canvas.translate(cellSize / 2, cellSize / 2);
    canvas.rotate(arrowModel.direction.rotationRadians);

    // 1. Draw continuous line segment
    final linePaint = Paint()
      ..color = paintColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = cellSize * 0.14
      ..strokeCap = StrokeCap.round;

    final length = _getPathLength();
    canvas.drawLine(Offset.zero, Offset(length, 0), linePaint);

    // 2. Draw chevron arrowhead at (0, 0)
    final chevronPaint = Paint()
      ..color = paintColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = cellSize * 0.14
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final headLen = cellSize * 0.18;
    final headW = cellSize * 0.28;

    final chevronPath = Path();
    chevronPath.moveTo(-headLen, -headW / 2);
    chevronPath.lineTo(0, 0);
    chevronPath.lineTo(-headLen, headW / 2);

    canvas.drawPath(chevronPath, chevronPaint);

    canvas.restore();
  }
}
