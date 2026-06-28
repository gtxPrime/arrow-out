import '../models/arrow.dart';
import '../models/level.dart';

/// Backtracking solver that verifies a level is solvable.
/// Uses BFS/DFS over grid states to find at least one solution.
/// Returns the solution sequence (list of arrow IDs) or null if unsolvable.
class LevelSolver {
  static const int maxStates = 50000; // Safety cap

  /// Returns a valid solution order of arrow IDs, or null if unsolvable.
  /// This guarantees every generated level has a solution before publishing.
  static List<String>? solve(LevelModel level) {
    final initial = _GridState.fromLevel(level);
    return _bfs(initial, level.gridSize);
  }

  static List<String>? _bfs(_GridState initial, int gridSize) {
    if (initial.isEmpty) return []; // Already solved

    final queue = <_SearchNode>[_SearchNode(initial, [])];
    final visited = <String>{initial.hash};
    int statesVisited = 0;

    while (queue.isNotEmpty) {
      statesVisited++;
      if (statesVisited > maxStates) return null; // Give up

      final node = queue.removeAt(0);
      final state = node.state;
      final moves = node.moves;

      // Try all arrows
      for (final arrow in state.arrows.values) {
        if (arrow.state != ArrowState.idle) continue;

        final result = _tryMove(state, arrow, gridSize);
        if (result == null) continue; // Blocked

        final newMoves = [...moves, arrow.id];

        if (result.isEmpty) {
          return newMoves; // Found solution!
        }

        if (!visited.contains(result.hash)) {
          visited.add(result.hash);
          queue.add(_SearchNode(result, newMoves));
        }
      }
    }

    return null; // No solution found
  }

  /// Returns new state if arrow can move, null if blocked.
  static _GridState? _tryMove(
      _GridState state, ArrowModel arrow, int gridSize) {
    final delta = arrow.direction.delta;
    int newRow = arrow.row + delta[0];
    int newCol = arrow.col + delta[1];

    // Check if path to edge is clear
    while (_isInGrid(newRow, newCol, gridSize)) {
      // Is this cell occupied?
      if (state.arrows.values.any((a) => a.row == newRow && a.col == newCol)) {
        return null; // Blocked
      }
      newRow += delta[0];
      newCol += delta[1];
    }

    // Arrow exits grid — create new state without this arrow
    final newArrows = Map<String, ArrowModel>.from(state.arrows);
    newArrows.remove(arrow.id);
    return _GridState(newArrows);
  }

  static bool _isInGrid(int row, int col, int size) {
    return row >= 0 && row < size && col >= 0 && col < size;
  }
}

// ─── Internal state for BFS ───────────────────────────────────────────────────

class _GridState {
  final Map<String, ArrowModel> arrows;

  _GridState(this.arrows);

  bool get isEmpty => arrows.isEmpty;

  /// Compact hash for visited-state detection
  String get hash {
    final sorted = arrows.values.toList()..sort((a, b) => a.id.compareTo(b.id));
    return sorted
        .map((a) => '${a.row},${a.col},${a.direction.index}')
        .join('|');
  }

  factory _GridState.fromLevel(LevelModel level) {
    final Map<String, ArrowModel> map = {};
    for (final arrow in level.arrows) {
      map[arrow.id] = arrow.copyWith(state: ArrowState.idle);
    }
    return _GridState(map);
  }
}

class _SearchNode {
  final _GridState state;
  final List<String> moves;
  _SearchNode(this.state, this.moves);
}
