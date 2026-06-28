import 'dart:math';
import '../models/arrow.dart';
import '../models/level.dart';
import '../../core/constants.dart';
import 'pattern_library.dart';
import 'solver.dart';

/// Level Generator Engine
/// Builds levels BACKWARDS from a valid solved state, guaranteeing solvability.
/// Boss/God levels have additional constraints to make them harder.
class LevelGenerator {
  // No shared state — all generation is seeded per level number for determinism

  /// Generate a specific level by number (deterministic seed for reproducibility)
  static LevelModel generateLevel(int levelNumber) {
    final seed = levelNumber * 31337 + 42;
    final rng = Random(seed);
    final type = AppConstants.levelTypeFor(levelNumber);
    final gridSize = AppConstants.gridSizeForLevel(levelNumber);

    // Pick difficulty params
    final params = _paramsForLevel(levelNumber, type);

    LevelModel? level;
    int retries = 0;
    while (level == null && retries < 15) {
      level = _generateAttempt(
        levelNumber: levelNumber,
        gridSize: gridSize,
        arrowCount: params.arrowCount,
        type: type,
        rng: rng,
        patternComplexity: params.patternComplexity,
      );
      retries++;
    }

    // Fallback: generate a simple guaranteed-solvable level
    return level ?? _generateFallback(levelNumber, gridSize, type);
  }

  // ── Generation attempt ──────────────────────────────────────────────────────

  static LevelModel? _generateAttempt({
    required int levelNumber,
    required int gridSize,
    required int arrowCount,
    required LevelType type,
    required Random rng,
    required double patternComplexity,
  }) {
    // Deterministic ID prefix per level
    int idCounter = 0;
    String nextId(String prefix) => '${prefix}_${levelNumber}_${idCounter++}';
    // 1. Pick pattern
    final availablePatterns = PatternLibrary.patternsForGridSize(gridSize);
    if (availablePatterns.isEmpty) return null;

    final patternName = availablePatterns[rng.nextInt(availablePatterns.length)];
    final patternCoords = PatternLibrary.centeredCoordinates(patternName, gridSize);

    // 2. Determine how many pattern cells to use as arrows
    // (for larger grids/harder levels, more of the pattern is arrows)
    final patternArrowCount = (patternCoords.length * patternComplexity).ceil()
        .clamp(3, patternCoords.length);
    final selectedCoords = List<List<int>>.from(patternCoords)..shuffle(rng);
    final arrowCoords = selectedCoords.take(patternArrowCount).toList();

    // 3. Build arrows — strategy: assign directions that allow exit
    final arrows = <ArrowModel>[];
    for (int i = 0; i < arrowCoords.length; i++) {
      final coord = arrowCoords[i];
      final direction = _pickSolvableDirection(
        row: coord[0],
        col: coord[1],
        gridSize: gridSize,
        existingArrows: arrows,
        rng: rng,
        levelType: type,
      );
      arrows.add(ArrowModel(
        id: nextId('arrow'),
        row: coord[0],
        col: coord[1],
        direction: direction,
        isPartOfPattern: true,
      ));
    }

    // 4. For boss/god levels: add extra blocking arrows not in pattern
    if (type == LevelType.boss || type == LevelType.god) {
      final extraCount = type == LevelType.god ? 
          (arrowCount - arrowCoords.length).clamp(2, 8) :
          (arrowCount - arrowCoords.length).clamp(1, 4);
      _addBlockingArrows(arrows, gridSize, extraCount, rng, levelNumber, idCounter);
    }

    if (arrows.isEmpty) return null;

    // 5. Build level model
    final level = LevelModel(
      levelNumber: levelNumber,
      gridSize: gridSize,
      arrows: arrows,
      patternName: patternName,
      difficulty: _difficultyFor(levelNumber, type),
    );

    // 6. Verify solvability
    final solution = LevelSolver.solve(level);
    if (solution == null) return null; // Retry

    // 7. Return with solution embedded
    return LevelModel(
      levelNumber: levelNumber,
      gridSize: gridSize,
      arrows: arrows,
      patternName: patternName,
      difficulty: _difficultyFor(levelNumber, type),
      solutionOrder: solution,
    );
  }

  // ── Pick direction ────────────────────────────────────────────────────────────

  static ArrowDirection _pickSolvableDirection({
    required int row,
    required int col,
    required int gridSize,
    required List<ArrowModel> existingArrows,
    required Random rng,
    required LevelType levelType,
  }) {
    // Get set of occupied cells
    final occupied = {for (final a in existingArrows) '${a.row},${a.col}'};

    // Find directions where path to edge is initially clear
    final clearDirections = <ArrowDirection>[];
    for (final dir in ArrowDirection.values) {
      if (_isPathClear(row, col, dir, gridSize, occupied)) {
        clearDirections.add(dir);
      }
    }

    if (clearDirections.isNotEmpty && rng.nextDouble() > 0.35) {
      // Prefer clear direction 65% of the time (allows more solvable configs)
      return clearDirections[rng.nextInt(clearDirections.length)];
    }

    // Otherwise random (solver will verify solvability)
    return ArrowDirection.values[rng.nextInt(4)];
  }

  static bool _isPathClear(
    int row, int col, ArrowDirection dir, int gridSize, Set<String> occupied) {
    final delta = dir.delta;
    int r = row + delta[0];
    int c = col + delta[1];
    while (r >= 0 && r < gridSize && c >= 0 && c < gridSize) {
      if (occupied.contains('$r,$c')) return false;
      r += delta[0];
      c += delta[1];
    }
    return true;
  }

  // ── Add blocking arrows for boss/god levels ───────────────────────────────

  static void _addBlockingArrows(
    List<ArrowModel> arrows, int gridSize, int count, Random rng,
    [int levelNumber = 0, int idStart = 100]) {
    final occupied = {for (final a in arrows) '${a.row},${a.col}'};
    int added = 0;
    int attempts = 0;
    int idCounter = idStart;

    while (added < count && attempts < 50) {
      attempts++;
      final row = rng.nextInt(gridSize);
      final col = rng.nextInt(gridSize);
      if (occupied.contains('$row,$col')) continue;

      arrows.add(ArrowModel(
        id: 'blocker_${levelNumber}_${idCounter++}',
        row: row,
        col: col,
        direction: ArrowDirection.values[rng.nextInt(4)],
        isPartOfPattern: false,
      ));
      occupied.add('$row,$col');
      added++;
    }
  }

  // ── Level params ──────────────────────────────────────────────────────────────

  static _LevelParams _paramsForLevel(int level, LevelType type) {
    // Base arrow count and pattern complexity by level
    int baseArrows;
    double complexity;

    if (level <= 3) {
      baseArrows = 4;
      complexity = 0.5;
    } else if (level <= 20) {
      baseArrows = _lerp(4, 10, (level - 3) / 17);
      complexity = _lerpD(0.5, 0.7, (level - 3) / 17);
    } else if (level <= 50) {
      baseArrows = _lerp(10, 18, (level - 20) / 30);
      complexity = _lerpD(0.7, 0.85, (level - 20) / 30);
    } else if (level <= 100) {
      baseArrows = _lerp(18, 28, (level - 50) / 50);
      complexity = 0.85;
    } else if (level <= 200) {
      baseArrows = _lerp(28, 38, (level - 100) / 100);
      complexity = 0.9;
    } else {
      baseArrows = _lerp(38, 55, min((level - 200) / 800, 1));
      complexity = 0.95;
    }

    // Boss: +30% arrows, +complexity
    // God: +60% arrows, max complexity
    switch (type) {
      case LevelType.boss:
        baseArrows = (baseArrows * 1.3).ceil();
        complexity = min(complexity + 0.1, 1.0);
        break;
      case LevelType.god:
        baseArrows = (baseArrows * 1.6).ceil();
        complexity = min(complexity + 0.15, 1.0);
        break;
      default:
        break;
    }

    return _LevelParams(arrowCount: baseArrows, patternComplexity: complexity);
  }

  static int _lerp(int a, int b, double t) => (a + (b - a) * t.clamp(0, 1)).round();
  static double _lerpD(double a, double b, double t) => a + (b - a) * t.clamp(0, 1);

  // ── Difficulty label ──────────────────────────────────────────────────────────

  static Difficulty _difficultyFor(int level, LevelType type) {
    if (type == LevelType.tutorial) return Difficulty.tutorial;
    if (type == LevelType.god) return Difficulty.legend;
    if (type == LevelType.boss) {
      if (level <= 20)  return Difficulty.hard;
      if (level <= 50)  return Difficulty.expert;
      if (level <= 100) return Difficulty.master;
      return Difficulty.legend;
    }
    if (level <= 20)  return Difficulty.easy;
    if (level <= 50)  return Difficulty.medium;
    if (level <= 100) return Difficulty.hard;
    if (level <= 200) return Difficulty.expert;
    if (level <= 400) return Difficulty.master;
    return Difficulty.legend;
  }

  // ── Fallback (always solvable) ────────────────────────────────────────────────

  static LevelModel _generateFallback(int levelNumber, int gridSize, LevelType type) {
    // Simple row of arrows all pointing right — trivially solvable
    final arrows = <ArrowModel>[];
    final mid = gridSize ~/ 2;
    for (int col = 0; col < min(4, gridSize); col++) {
      arrows.add(ArrowModel(
        id: 'fallback_${levelNumber}_$col',
        row: mid,
        col: col,
        direction: ArrowDirection.right,
        isPartOfPattern: true,
      ));
    }
    return LevelModel(
      levelNumber: levelNumber,
      gridSize: gridSize,
      arrows: arrows,
      patternName: 'line_h',
      difficulty: Difficulty.easy,
      solutionOrder: arrows.map((a) => a.id).toList(),
    );
  }
}

class _LevelParams {
  final int arrowCount;
  final double patternComplexity;
  _LevelParams({required this.arrowCount, required this.patternComplexity});
}
