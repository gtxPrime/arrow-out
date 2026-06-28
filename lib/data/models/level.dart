import 'arrow.dart';

// ─── Difficulty Enum ──────────────────────────────────────────────────────────

enum Difficulty {
  tutorial,
  easy,
  medium,
  hard,
  expert,
  master,
  legend;

  String get label {
    switch (this) {
      case Difficulty.tutorial: return 'Tutorial';
      case Difficulty.easy:     return 'Easy';
      case Difficulty.medium:   return 'Medium';
      case Difficulty.hard:     return 'Hard';
      case Difficulty.expert:   return 'Expert';
      case Difficulty.master:   return 'Master';
      case Difficulty.legend:   return 'Legend';
    }
  }

  static Difficulty forLevel(int levelNumber) {
    if (levelNumber <= 10) return Difficulty.tutorial;
    if (levelNumber <= 30) return Difficulty.easy;
    if (levelNumber <= 70) return Difficulty.medium;
    if (levelNumber <= 150) return Difficulty.hard;
    if (levelNumber <= 300) return Difficulty.expert;
    if (levelNumber <= 500) return Difficulty.master;
    return Difficulty.legend;
  }
}

// ─── Level Model ──────────────────────────────────────────────────────────────

class LevelModel {
  final int levelNumber;
  final int gridSize;          // NxN grid
  final List<ArrowModel> arrows;
  final String patternName;    // e.g. 'cat', 'star', 'heart'
  final Difficulty difficulty;
  final List<String> solutionOrder; // Arrow IDs in correct exit order (for hints)

  LevelModel({
    required this.levelNumber,
    required this.gridSize,
    required this.arrows,
    required this.patternName,
    required this.difficulty,
    this.solutionOrder = const [],
  });

  int get totalArrows => arrows.length;

  /// Deep copy of level (for game state reset)
  LevelModel copy() {
    return LevelModel(
      levelNumber: levelNumber,
      gridSize: gridSize,
      arrows: arrows.map((a) => a.copyWith()).toList(),
      patternName: patternName,
      difficulty: difficulty,
      solutionOrder: List.from(solutionOrder),
    );
  }

  Map<String, dynamic> toJson() => {
    'levelNumber': levelNumber,
    'gridSize': gridSize,
    'arrows': arrows.map((a) => a.toJson()).toList(),
    'patternName': patternName,
    'difficulty': difficulty.index,
    'solutionOrder': solutionOrder,
  };

  factory LevelModel.fromJson(Map<String, dynamic> json) => LevelModel(
    levelNumber: json['levelNumber'] as int,
    gridSize: json['gridSize'] as int,
    arrows: (json['arrows'] as List)
        .map((a) => ArrowModel.fromJson(a as Map<String, dynamic>))
        .toList(),
    patternName: json['patternName'] as String,
    difficulty: Difficulty.values[json['difficulty'] as int],
    solutionOrder: List<String>.from(json['solutionOrder'] as List? ?? []),
  );
}

// ─── Level Result Model ───────────────────────────────────────────────────────

class LevelResult {
  final int levelNumber;
  final int stars;           // 0–3
  final int score;
  final int movesUsed;
  final int livesLost;
  final bool completed;
  final DateTime completedAt;

  LevelResult({
    required this.levelNumber,
    required this.stars,
    required this.score,
    required this.movesUsed,
    required this.livesLost,
    required this.completed,
    required this.completedAt,
  });

  Map<String, dynamic> toJson() => {
    'levelNumber': levelNumber,
    'stars': stars,
    'score': score,
    'movesUsed': movesUsed,
    'livesLost': livesLost,
    'completed': completed,
    'completedAt': completedAt.toIso8601String(),
  };

  factory LevelResult.fromJson(Map<String, dynamic> json) => LevelResult(
    levelNumber: json['levelNumber'] as int,
    stars: json['stars'] as int,
    score: json['score'] as int,
    movesUsed: json['movesUsed'] as int,
    livesLost: json['livesLost'] as int,
    completed: json['completed'] as bool,
    completedAt: DateTime.parse(json['completedAt'] as String),
  );
}
