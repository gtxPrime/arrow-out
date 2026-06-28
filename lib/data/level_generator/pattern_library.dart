/// Pattern Library
/// Each pattern is a list of [row, col] offsets (0-indexed from top-left).
/// The bounding box of each pattern is its natural size.
/// The generator scales/fits these into the target grid.
class PatternLibrary {
  PatternLibrary._();

  // ── Animals ──────────────────────────────────────────────────────────────────

  static const Map<String, List<List<int>>> patterns = {
    // 3x3 patterns (simple)
    'line_h': [
      [1, 0], [1, 1], [1, 2],
    ],
    'line_v': [
      [0, 1], [1, 1], [2, 1],
    ],
    'corner_tl': [
      [0, 0], [1, 0], [2, 0], [2, 1], [2, 2],
    ],
    'cross': [
      [0, 1], [1, 0], [1, 1], [1, 2], [2, 1],
    ],
    'diagonal': [
      [0, 0], [1, 1], [2, 2],
    ],

    // 4x4 patterns
    'square': [
      [0, 0], [0, 1], [0, 2], [0, 3],
      [1, 0],                 [1, 3],
      [2, 0],                 [2, 3],
      [3, 0], [3, 1], [3, 2], [3, 3],
    ],
    'heart': [
      [0, 1], [0, 2],
      [1, 0], [1, 1], [1, 2], [1, 3],
      [2, 0], [2, 1], [2, 2], [2, 3],
      [3, 1], [3, 2],
      [4, 2],
    ],
    'star': [
      [0, 2],
      [1, 1], [1, 2], [1, 3],
      [2, 0], [2, 1], [2, 2], [2, 3], [2, 4],
      [3, 1], [3, 2], [3, 3],
      [4, 0],         [4, 4],
    ],
    'arrow_shape': [
      [0, 2],
      [1, 1], [1, 2], [1, 3],
      [2, 0], [2, 1], [2, 2], [2, 3], [2, 4],
      [3, 2],
      [4, 2],
    ],

    // Cat (5x5)
    'cat': [
      [0, 0],                 [0, 4],
      [0, 1],                 [0, 3],
      [1, 0], [1, 1], [1, 2], [1, 3], [1, 4],
      [2, 0],         [2, 2],         [2, 4],
      [3, 0], [3, 1], [3, 2], [3, 3], [3, 4],
      [4, 1],         [4, 3],
    ],

    // Dog (5x5)
    'dog': [
      [0, 0], [0, 1], [0, 2], [0, 3],
      [1, 0],                 [1, 3], [1, 4],
      [2, 0], [2, 1], [2, 2], [2, 3], [2, 4],
      [3, 0],         [3, 2],         [3, 4],
      [4, 0],                         [4, 4],
    ],

    // Fish (5x5)
    'fish': [
      [0, 0],
      [1, 0], [1, 1],
      [2, 0], [2, 1], [2, 2], [2, 3], [2, 4],
      [3, 0], [3, 1],
      [4, 0],
    ],

    // Bird (5x5)
    'bird': [
      [0, 1], [0, 3],
      [1, 0], [1, 1], [1, 2], [1, 3], [1, 4],
      [2, 1], [2, 2], [2, 3],
      [3, 2],
      [4, 1], [4, 3],
    ],

    // Rabbit (6x5)
    'rabbit': [
      [0, 1], [0, 3],
      [1, 1], [1, 3],
      [2, 0], [2, 1], [2, 2], [2, 3], [2, 4],
      [3, 0],         [3, 2],         [3, 4],
      [4, 0], [4, 1], [4, 2], [4, 3], [4, 4],
      [5, 1],         [5, 3],
    ],

    // Rocket (6x5)
    'rocket': [
      [0, 2],
      [1, 1], [1, 2], [1, 3],
      [2, 0], [2, 1], [2, 2], [2, 3], [2, 4],
      [3, 0], [3, 1], [3, 2], [3, 3], [3, 4],
      [4, 1], [4, 2], [4, 3],
      [5, 0],         [5, 4],
    ],

    // House (6x5)
    'house': [
      [0, 2],
      [1, 1], [1, 2], [1, 3],
      [2, 0], [2, 1], [2, 2], [2, 3], [2, 4],
      [3, 0],         [3, 2],         [3, 4],
      [4, 0],         [4, 2],         [4, 4],
      [5, 0], [5, 1], [5, 2], [5, 3], [5, 4],
    ],

    // Tree (6x5)
    'tree': [
      [0, 2],
      [1, 1], [1, 2], [1, 3],
      [2, 0], [2, 1], [2, 2], [2, 3], [2, 4],
      [3, 1], [3, 2], [3, 3],
      [4, 2],
      [5, 2],
    ],

    // Car (4x7)
    'car': [
      [0, 1], [0, 2], [0, 3], [0, 4], [0, 5],
      [1, 0], [1, 1], [1, 2], [1, 3], [1, 4], [1, 5], [1, 6],
      [2, 0],                                           [2, 6],
      [3, 1],                                           [3, 5],
    ],

    // Trophy (6x5)
    'trophy': [
      [0, 0], [0, 1], [0, 2], [0, 3], [0, 4],
      [1, 0],         [1, 2],         [1, 4],
      [2, 0],         [2, 2],         [2, 4],
      [3, 0], [3, 1], [3, 2], [3, 3], [3, 4],
      [4, 2],
      [5, 1], [5, 2], [5, 3],
    ],

    // Crown (4x7)
    'crown': [
      [0, 0], [0, 3], [0, 6],
      [1, 0], [1, 1], [1, 2], [1, 3], [1, 4], [1, 5], [1, 6],
      [2, 0],                                           [2, 6],
      [3, 0], [3, 1], [3, 2], [3, 3], [3, 4], [3, 5], [3, 6],
    ],

    // Lightning bolt (5x4)
    'lightning': [
      [0, 2], [0, 3],
      [1, 1], [1, 2], [1, 3],
      [2, 1], [2, 2],
      [3, 0], [3, 1], [3, 2],
      [4, 0], [4, 1],
    ],

    // Diamond (5x5)
    'diamond': [
      [0, 2],
      [1, 1], [1, 2], [1, 3],
      [2, 0], [2, 1], [2, 2], [2, 3], [2, 4],
      [3, 1], [3, 2], [3, 3],
      [4, 2],
    ],

    // Moon (5x5)
    'moon': [
      [0, 2], [0, 3],
      [1, 1],         [1, 4],
      [2, 0],
      [3, 1],
      [4, 2], [4, 3],
    ],

    // Sun (5x5)
    'sun': [
      [0, 0], [0, 2], [0, 4],
      [1, 1], [1, 2], [1, 3],
      [2, 0], [2, 1], [2, 2], [2, 3], [2, 4],
      [3, 1], [3, 2], [3, 3],
      [4, 0], [4, 2], [4, 4],
    ],

    // Skull (6x5)
    'skull': [
      [0, 1], [0, 2], [0, 3],
      [1, 0], [1, 1], [1, 2], [1, 3], [1, 4],
      [2, 0], [2, 1], [2, 2], [2, 3], [2, 4],
      [3, 0], [3, 1], [3, 2], [3, 3], [3, 4],
      [4, 1],         [4, 3],
      [5, 1], [5, 2], [5, 3],
    ],

    // Letter A (5x5)
    'letter_a': [
      [0, 2],
      [1, 1], [1, 3],
      [2, 0], [2, 1], [2, 2], [2, 3], [2, 4],
      [3, 0],                         [3, 4],
      [4, 0],                         [4, 4],
    ],

    // Number 7 (5x4)
    'number_7': [
      [0, 0], [0, 1], [0, 2], [0, 3],
      [1, 3],
      [2, 2],
      [3, 1], [3, 2],
      [4, 1],
    ],
  };

  // ── Helpers ──────────────────────────────────────────────────────────────────

  /// Returns a list of pattern names appropriate for the given grid size
  static List<String> patternsForGridSize(int gridSize) {
    return patterns.keys.where((name) {
      final coords = patterns[name]!;
      final maxRow = coords.map((c) => c[0]).reduce((a, b) => a > b ? a : b);
      final maxCol = coords.map((c) => c[1]).reduce((a, b) => a > b ? a : b);
      return (maxRow + 1) <= gridSize && (maxCol + 1) <= gridSize;
    }).toList();
  }

  /// Get the bounding box [rows, cols] of a pattern
  static List<int> boundingBox(String name) {
    final coords = patterns[name]!;
    final maxRow = coords.map((c) => c[0]).reduce((a, b) => a > b ? a : b);
    final maxCol = coords.map((c) => c[1]).reduce((a, b) => a > b ? a : b);
    return [maxRow + 1, maxCol + 1];
  }

  /// Center-offset coordinates for fitting pattern into grid
  static List<List<int>> centeredCoordinates(String name, int gridSize) {
    final coords = patterns[name]!;
    final box = boundingBox(name);
    final rowOffset = ((gridSize - box[0]) / 2).floor();
    final colOffset = ((gridSize - box[1]) / 2).floor();
    return coords.map((c) => [c[0] + rowOffset, c[1] + colOffset]).toList();
  }

  static List<String> get allPatternNames => patterns.keys.toList();
}
