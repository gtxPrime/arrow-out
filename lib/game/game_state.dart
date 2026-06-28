import 'package:flutter/foundation.dart';
import '../data/models/arrow.dart';
import '../data/models/level.dart';
import '../core/constants.dart';

/// Manages the current game state: lives, moves, arrows remaining.
class GameState extends ChangeNotifier {
  // ── Level ─────────────────────────────────────────────────────────────────────
  late LevelModel _currentLevel;
  late List<ArrowModel> _arrows;
  int _lives = AppConstants.maxLives;
  int _movesUsed = 0;
  int _livesLost = 0;
  bool _isComplete = false;
  bool _isGameOver = false;

  // ── Callbacks ─────────────────────────────────────────────────────────────────
  final void Function() onLevelComplete;
  final void Function() onGameOver;
  final void Function() onLifeLost;

  GameState({
    required LevelModel level,
    required this.onLevelComplete,
    required this.onGameOver,
    required this.onLifeLost,
  }) {
    _currentLevel = level;
    _arrows = level.arrows.map((a) => a.copyWith()).toList();
  }

  // ── Getters ───────────────────────────────────────────────────────────────────
  List<ArrowModel> get arrows => List.unmodifiable(_arrows);
  int get lives => _lives;
  int get movesUsed => _movesUsed;
  int get livesLost => _livesLost;
  bool get isComplete => _isComplete;
  bool get isGameOver => _isGameOver;
  int get arrowsRemaining => _arrows.length;
  LevelModel get level => _currentLevel;

  // ── Tap Handler ───────────────────────────────────────────────────────────────

  /// Returns the outcome of tapping an arrow.
  TapResult tapArrow(String arrowId) {
    if (_isComplete || _isGameOver) return TapResult.ignored;

    final index = _arrows.indexWhere((a) => a.id == arrowId);
    if (index == -1) return TapResult.ignored;

    final arrow = _arrows[index];
    if (arrow.state != ArrowState.idle) return TapResult.ignored;

    _movesUsed++;

    // Check if path to edge is clear
    if (_isBlocked(arrow)) {
      // Blocked — lose a life
      _arrows[index] = arrow.copyWith(state: ArrowState.blocked);
      _lives--;
      _livesLost++;
      onLifeLost();

      // Reset arrow state after animation
      Future.delayed(AppConstants.arrowShakeDuration, () {
        final idx = _arrows.indexWhere((a) => a.id == arrowId);
        if (idx != -1) {
          _arrows[idx] = _arrows[idx].copyWith(state: ArrowState.idle);
          notifyListeners();
        }
      });

      if (_lives <= 0) {
        _isGameOver = true;
        onGameOver();
        notifyListeners();
        return TapResult.blocked;
      }

      notifyListeners();
      return TapResult.blocked;
    }

    // Clear path — arrow exits
    _arrows[index] = arrow.copyWith(state: ArrowState.sliding);
    notifyListeners();

    Future.delayed(AppConstants.arrowExitDuration, () {
      _arrows.removeWhere((a) => a.id == arrowId);

      if (_arrows.isEmpty) {
        _isComplete = true;
        onLevelComplete();
      }
      notifyListeners();
    });

    return TapResult.exited;
  }

  bool _isBlocked(ArrowModel arrow) {
    final delta = arrow.direction.delta;
    int r = arrow.row + delta[0];
    int c = arrow.col + delta[1];
    final gridSize = _currentLevel.gridSize;

    while (r >= 0 && r < gridSize && c >= 0 && c < gridSize) {
      if (_arrows.any((a) => a.id != arrow.id && a.row == r && a.col == c)) {
        return true; // Another arrow is in the path
      }
      r += delta[0];
      c += delta[1];
    }
    return false;
  }

  // ── Reset ─────────────────────────────────────────────────────────────────────

  void resetLevel() {
    _arrows = _currentLevel.arrows.map((a) => a.copyWith(state: ArrowState.idle)).toList();
    _lives = AppConstants.maxLives; // Full lives on restart
    _movesUsed = 0;
    _livesLost = 0;
    _isComplete = false;
    _isGameOver = false;
    notifyListeners();
  }

  void restoreLife() {
    if (_lives < AppConstants.maxLives) {
      _lives++;
      if (_isGameOver && _lives > 0) {
        _isGameOver = false;
      }
      notifyListeners();
    }
  }
}

enum TapResult { exited, blocked, ignored }
