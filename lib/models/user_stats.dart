/// 사용자 통계 모델
class UserStats {
  final int totalCompletions;
  final int thisMonthCompletions;
  final int subscribedGyms;
  final String highestDifficulty;

  UserStats({
    required this.totalCompletions,
    required this.thisMonthCompletions,
    required this.subscribedGyms,
    required this.highestDifficulty,
  });
}