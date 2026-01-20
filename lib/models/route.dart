/// 클라이밍 문제(루트) 모델
class ClimbingRoute {
  final int id;
  final String name;
  final String difficulty; // V0, V1, ... V16
  final String color;
  final String gymName;
  final DateTime createdAt;
  final int completionCount;
  final double? averageRating;

  ClimbingRoute({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.color,
    required this.gymName,
    required this.createdAt,
    required this.completionCount,
    this.averageRating,
  });
}