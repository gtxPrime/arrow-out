import 'dart:math';

// ─── Direction Enum ───────────────────────────────────────────────────────────

enum ArrowDirection {
  up,
  down,
  left,
  right;

  /// Returns the [row, col] delta for movement
  List<int> get delta {
    switch (this) {
      case ArrowDirection.up:    return [-1, 0];
      case ArrowDirection.down:  return [1, 0];
      case ArrowDirection.left:  return [0, -1];
      case ArrowDirection.right: return [0, 1];
    }
  }

  /// Unicode arrow character for display / debugging
  String get symbol {
    switch (this) {
      case ArrowDirection.up:    return '↑';
      case ArrowDirection.down:  return '↓';
      case ArrowDirection.left:  return '←';
      case ArrowDirection.right: return '→';
    }
  }

  /// Rotation angle in radians (base asset points RIGHT = 0 rad)
  double get rotationRadians {
    switch (this) {
      case ArrowDirection.right: return 0;
      case ArrowDirection.down:  return pi / 2;
      case ArrowDirection.left:  return pi;
      case ArrowDirection.up:    return -pi / 2;
    }
  }

  static ArrowDirection random() {
    final rng = Random();
    return ArrowDirection.values[rng.nextInt(4)];
  }
}

// ─── Arrow State Enum ─────────────────────────────────────────────────────────

enum ArrowState {
  idle,       // Waiting for tap
  sliding,    // Currently animating
  blocked,    // Hit a wall — showing error
  exited,     // Successfully left grid
}

// ─── Arrow Model ─────────────────────────────────────────────────────────────

class ArrowModel {
  final String id;
  int row;
  int col;
  ArrowDirection direction;
  ArrowState state;
  bool isPartOfPattern; // Whether this arrow is part of the target shape

  ArrowModel({
    required this.id,
    required this.row,
    required this.col,
    required this.direction,
    this.state = ArrowState.idle,
    this.isPartOfPattern = false,
  });

  ArrowModel copyWith({
    String? id,
    int? row,
    int? col,
    ArrowDirection? direction,
    ArrowState? state,
    bool? isPartOfPattern,
  }) {
    return ArrowModel(
      id: id ?? this.id,
      row: row ?? this.row,
      col: col ?? this.col,
      direction: direction ?? this.direction,
      state: state ?? this.state,
      isPartOfPattern: isPartOfPattern ?? this.isPartOfPattern,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'row': row,
    'col': col,
    'direction': direction.index,
    'state': state.index,
    'isPartOfPattern': isPartOfPattern,
  };

  factory ArrowModel.fromJson(Map<String, dynamic> json) => ArrowModel(
    id: json['id'] as String,
    row: json['row'] as int,
    col: json['col'] as int,
    direction: ArrowDirection.values[json['direction'] as int],
    state: ArrowState.values[json['state'] as int],
    isPartOfPattern: json['isPartOfPattern'] as bool? ?? false,
  );

  @override
  String toString() => 'Arrow($id @ [$row,$col] ${direction.symbol})';
}
