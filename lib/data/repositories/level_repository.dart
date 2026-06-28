import '../models/level.dart';
import '../level_generator/level_generator.dart';

/// Caches generated levels and provides access by level number.
/// Generates up to 1000+ levels on demand.
class LevelRepository {
  final Map<int, LevelModel> _cache = {};

  /// Get or generate a level by number
  LevelModel getLevel(int levelNumber) {
    return _cache.putIfAbsent(levelNumber, () {
      return LevelGenerator.generateLevel(levelNumber);
    });
  }

  /// Pre-generate a range of levels (e.g. next 10 ahead)
  void preGenerate(int from, int count) {
    for (int i = from; i < from + count; i++) {
      getLevel(i);
    }
  }

  /// Clear cache to free memory (keep current ±5 levels)
  void trimCache(int currentLevel) {
    final keys = _cache.keys.toList();
    for (final key in keys) {
      if (key < currentLevel - 5 || key > currentLevel + 10) {
        _cache.remove(key);
      }
    }
  }

  /// Total levels available (effectively infinite, capped at 10000)
  static int get totalLevels => 10000;
}
