/// 암장 통계 모델
class GymStats {
  final int totalMembers;
  final int todayVisitors;
  final int activeSectors;
  final int totalProblems;
  final double averageRating;

  GymStats({
    required this.totalMembers,
    required this.todayVisitors,
    required this.activeSectors,
    required this.totalProblems,
    required this.averageRating,
  });
}