/// 암장 소식 모델
class GymNews {
  final int id;
  final int gymId;
  final String gymName;
  final String title;
  final String content;
  final String newsType; // 'SETTING', 'NOTICE', 'EVENT'
  final DateTime createdAt;
  final String? imageUrl;

  GymNews({
    required this.id,
    required this.gymId,
    required this.gymName,
    required this.title,
    required this.content,
    required this.newsType,
    required this.createdAt,
    this.imageUrl,
  });

  /// 소식 타입 한글 변환
  String getNewsTypeText() {
    switch (newsType) {
      case 'SETTING':
        return '새 세팅';
      case 'NOTICE':
        return '공지';
      case 'EVENT':
        return '이벤트';
      default:
        return '소식';
    }
  }

  /// JSON을 GymNews 객체로 변환
  factory GymNews.fromJson(Map<String, dynamic> json) {
    return GymNews(
      id: json['id'] as int,
      gymId: json['gymId'] as int,
      gymName: json['gymName'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      newsType: json['newsType'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      imageUrl: json['imageUrl'] as String?,
    );
  }

  /// GymNews 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gymId': gymId,
      'gymName': gymName,
      'title': title,
      'content': content,
      'newsType': newsType,
      'createdAt': createdAt.toIso8601String(),
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }
}