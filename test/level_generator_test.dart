import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_puzzle/data/level_generator/level_generator.dart';
import 'package:arrow_puzzle/data/level_generator/solver.dart';
import 'package:arrow_puzzle/core/constants.dart';

void main() {
  group('LevelSolver', () {
    test('All tutorial levels (1-3) are solvable', () {
      for (int i = 1; i <= 3; i++) {
        final level = LevelGenerator.generateLevel(i);
        final solution = LevelSolver.solve(level);
        expect(solution, isNotNull,
          reason: 'Level $i should be solvable. Grid: ${level.gridSize}×${level.gridSize}, '
                  'Arrows: ${level.arrows.length}, Pattern: ${level.patternName}');
      }
    });

    test('First 50 levels are all solvable', () {
      int failCount = 0;
      final failures = <int>[];
      for (int i = 1; i <= 50; i++) {
        final level = LevelGenerator.generateLevel(i);
        final solution = LevelSolver.solve(level);
        if (solution == null) {
          failCount++;
          failures.add(i);
        }
      }
      expect(failures, isEmpty,
        reason: 'Levels $failures failed solvability check');
    });

    test('Boss and God levels (up to 60) are solvable', () {
      final specialLevels = <int>[];
      for (int i = 1; i <= 60; i++) {
        final type = AppConstants.levelTypeFor(i);
        if (type == LevelType.boss || type == LevelType.god) {
          specialLevels.add(i);
        }
      }
      final failures = <int>[];
      for (final level in specialLevels) {
        final generated = LevelGenerator.generateLevel(level);
        final solution = LevelSolver.solve(generated);
        if (solution == null) failures.add(level);
      }
      expect(failures, isEmpty,
        reason: 'Special levels $failures are unsolvable');
    });

    test('Levels 100, 200, 300, 400, 500 are solvable', () {
      for (final i in [100, 200, 300, 400, 500]) {
        final level = LevelGenerator.generateLevel(i);
        final solution = LevelSolver.solve(level);
        expect(solution, isNotNull,
          reason: 'Level $i (${level.difficulty.label}) should be solvable');
      }
    });
  });

  group('LevelGenerator', () {
    test('Grid size scales correctly by level', () {
      expect(AppConstants.gridSizeForLevel(1),   equals(6));
      expect(AppConstants.gridSizeForLevel(3),   equals(6));
      expect(AppConstants.gridSizeForLevel(4),   equals(6));
      expect(AppConstants.gridSizeForLevel(20),  equals(6));
      expect(AppConstants.gridSizeForLevel(21),  equals(7));
      expect(AppConstants.gridSizeForLevel(50),  equals(7));
      expect(AppConstants.gridSizeForLevel(100), equals(7));
      expect(AppConstants.gridSizeForLevel(101), equals(8));
      expect(AppConstants.gridSizeForLevel(200), equals(8));
      expect(AppConstants.gridSizeForLevel(201), equals(9));
      expect(AppConstants.gridSizeForLevel(400), equals(9));
      expect(AppConstants.gridSizeForLevel(401), equals(10));
    });

    test('Level type classification is correct', () {
      // Tutorial
      expect(AppConstants.levelTypeFor(1), equals(LevelType.tutorial));
      expect(AppConstants.levelTypeFor(3), equals(LevelType.tutorial));
      // God levels (5th, 10th, 15th, etc.)
      expect(AppConstants.levelTypeFor(5),  equals(LevelType.god));
      expect(AppConstants.levelTypeFor(10), equals(LevelType.god));
      expect(AppConstants.levelTypeFor(15), equals(LevelType.god));
      // Boss levels (3rd, 6th, 9th — not divisible by 5)
      expect(AppConstants.levelTypeFor(3),  isNot(equals(LevelType.boss))); // tutorial takes priority
      expect(AppConstants.levelTypeFor(6),  equals(LevelType.boss));
      expect(AppConstants.levelTypeFor(9),  equals(LevelType.boss));
      expect(AppConstants.levelTypeFor(12), equals(LevelType.boss));
      // Normal levels
      expect(AppConstants.levelTypeFor(4),  equals(LevelType.normal));
      expect(AppConstants.levelTypeFor(7),  equals(LevelType.normal));
      expect(AppConstants.levelTypeFor(11), equals(LevelType.normal));
    });

    test('Level generation is deterministic (same seed = same level)', () {
      final level1 = LevelGenerator.generateLevel(42);
      final level2 = LevelGenerator.generateLevel(42);
      expect(level1.arrows.length, equals(level2.arrows.length));
      expect(level1.gridSize,      equals(level2.gridSize));
      expect(level1.patternName,   equals(level2.patternName));
    });

    test('Arrow count increases with difficulty on average', () {
      // Calculate averages to smooth out random pattern size variance
      double avgTutorial = [1, 2, 3]
          .map((l) => LevelGenerator.generateLevel(l).arrows.length)
          .reduce((a, b) => a + b) / 3;

      double avgEasy = [11, 12, 13]
          .map((l) => LevelGenerator.generateLevel(l).arrows.length)
          .reduce((a, b) => a + b) / 3;

      double avgHard = [81, 82, 83]
          .map((l) => LevelGenerator.generateLevel(l).arrows.length)
          .reduce((a, b) => a + b) / 3;

      double avgExpert = [151, 152, 153]
          .map((l) => LevelGenerator.generateLevel(l).arrows.length)
          .reduce((a, b) => a + b) / 3;

      expect(avgEasy, greaterThanOrEqualTo(avgTutorial));
      expect(avgExpert, greaterThan(avgEasy));
    });

    test('All arrows in a level are within grid bounds', () {
      for (int i = 1; i <= 20; i++) {
        final level = LevelGenerator.generateLevel(i);
        for (final arrow in level.arrows) {
          expect(arrow.row, inInclusiveRange(0, level.gridSize - 1),
            reason: 'Arrow row out of bounds in level $i');
          expect(arrow.col, inInclusiveRange(0, level.gridSize - 1),
            reason: 'Arrow col out of bounds in level $i');
        }
      }
    });

    test('No two arrows occupy the same cell in any level', () {
      for (int i = 1; i <= 30; i++) {
        final level = LevelGenerator.generateLevel(i);
        final positions = <String>{};
        for (final arrow in level.arrows) {
          final key = '${arrow.row},${arrow.col}';
          expect(positions.contains(key), isFalse,
            reason: 'Duplicate cell [$key] in level $i');
          positions.add(key);
        }
      }
    });
  });
}
