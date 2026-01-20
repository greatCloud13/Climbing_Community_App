/// 피드 아이템 모델
class FeedItem {
  final int id;
  final String username;
  final String nickname;
  final String action; // "completed", "rated", "commented"
  final String routeName;
  final String difficulty;
  final String gymName;
  final DateTime createdAt;
  final double? rating;
  final String? comment;

  FeedItem({
    required this.id,
    required this.username,
    required this.nickname,
    required this.action,
    required this.routeName,
    required this.difficulty,
    required this.gymName,
    required this.createdAt,
    this.rating,
    this.comment,
  });
}