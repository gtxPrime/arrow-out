/// Player progress data model (snapshot for serialization/display)
class PlayerProgress {
  final int currentLevel;
  final int highestLevel;
  final int lives;
  final int coins;
  final int streakDays;
  final int totalScore;

  const PlayerProgress({
    required this.currentLevel,
    required this.highestLevel,
    required this.lives,
    required this.coins,
    required this.streakDays,
    required this.totalScore,
  });
}
