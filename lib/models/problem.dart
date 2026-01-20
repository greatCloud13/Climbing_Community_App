/// 문제 모델
class Problem {
  final int id;
  final String settingId;
  final String difficulty;
  final String color;
  final int level;
  final String? description;
  final int completionCount;
  final double? averageRating;

  Problem({
    required this.id,
    required this.settingId,
    required this.difficulty,
    required this.color,
    required this.level,
    this.description,
    required this.completionCount,
    this.averageRating,
  });
}