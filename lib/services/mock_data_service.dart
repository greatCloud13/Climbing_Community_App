import '../models/gym.dart';
import '../models/sector.dart';
import '../models/setting.dart';
import '../models/problem.dart';
import '../models/feed_item.dart';
import '../models/user_stats.dart';

/// Mock 데이터 서비스
class MockDataService {
  /// 사용자 통계 (Mock)
  static UserStats getUserStats() {
    return UserStats(
      totalCompletions: 142,
      thisMonthCompletions: 23,
      subscribedGyms: 3,
      highestDifficulty: 'V5',
    );
  }

  /// 구독한 암장 목록 (Mock)
  static List<Gym> getSubscribedGyms() {
    return [
      Gym(
        id: 1,
        name: '더클라임 강남점',
        location: '서울 강남구',
        isSubscribed: true,
      ),
      Gym(
        id: 2,
        name: '클라이밍파크 홍대',
        location: '서울 마포구',
        isSubscribed: true,
      ),
      Gym(
        id: 3,
        name: '스파이더클라임 판교',
        location: '경기 성남시',
        isSubscribed: true,
      ),
    ];
  }

  /// 최근 세팅 목록 (섹터별 새 세팅)
  static List<Setting> getRecentSettings() {
    final now = DateTime.now();
    return [
      Setting(
        id: 1,
        sectorId: 1,
        sectorName: 'A 섹터',
        gymName: '더클라임 강남점',
        settingDate: now.subtract(const Duration(days: 2)),
        clearDate: null,
        isActive: true,
        problemCount: 15,
        clearUserCount: 8,
      ),
      Setting(
        id: 2,
        sectorId: 3,
        sectorName: '오버행 구역',
        gymName: '클라이밍파크 홍대',
        settingDate: now.subtract(const Duration(days: 5)),
        clearDate: null,
        isActive: true,
        problemCount: 12,
        clearUserCount: 5,
      ),
      Setting(
        id: 3,
        sectorId: 5,
        sectorName: 'B 섹터',
        gymName: '더클라임 강남점',
        settingDate: now.subtract(const Duration(days: 7)),
        clearDate: null,
        isActive: true,
        problemCount: 18,
        clearUserCount: 12,
      ),
      Setting(
        id: 4,
        sectorId: 7,
        sectorName: '슬랩 구역',
        gymName: '스파이더클라임 판교',
        settingDate: now.subtract(const Duration(days: 10)),
        clearDate: null,
        isActive: true,
        problemCount: 10,
        clearUserCount: 15,
      ),
    ];
  }

  /// 특정 세팅의 문제 목록
  static List<Problem> getProblemsForSetting(int settingId) {
    // 실제로는 settingId에 따라 다른 문제들을 반환
    return [
      Problem(
        id: 1,
        settingId: settingId.toString(),
        difficulty: 'V4',
        color: '빨강',
        level: 1,
        description: '오버행 파워 라인',
        completionCount: 12,
        averageRating: 4.5,
      ),
      Problem(
        id: 2,
        settingId: settingId.toString(),
        difficulty: 'V2',
        color: '파랑',
        level: 2,
        description: '슬랩 밸런스',
        completionCount: 28,
        averageRating: 4.2,
      ),
      Problem(
        id: 3,
        settingId: settingId.toString(),
        difficulty: 'V5',
        color: '검정',
        level: 1,
        description: '크림프 엔듀어런스',
        completionCount: 7,
        averageRating: 4.8,
      ),
    ];
  }

  /// 피드 아이템 목록 (Mock)
  static List<FeedItem> getFeedItems() {
    final now = DateTime.now();
    return [
      FeedItem(
        id: 1,
        username: 'climber123',
        nickname: '클라이머',
        action: 'completed',
        routeName: 'A 섹터 - V4 빨강 #1',
        difficulty: 'V4',
        gymName: '더클라임 강남점',
        createdAt: now.subtract(const Duration(minutes: 30)),
        rating: 4.5,
      ),
      FeedItem(
        id: 2,
        username: 'boulder_king',
        nickname: '볼더왕',
        action: 'rated',
        routeName: '오버행 구역 - V2 파랑 #3',
        difficulty: 'V2',
        gymName: '클라이밍파크 홍대',
        createdAt: now.subtract(const Duration(hours: 1)),
        rating: 5.0,
        comment: '새 세팅 난이도가 딱 좋네요!',
      ),
      FeedItem(
        id: 3,
        username: 'rock_star',
        nickname: '바위별',
        action: 'completed',
        routeName: 'B 섹터 - V5 검정 #1',
        difficulty: 'V5',
        gymName: '더클라임 강남점',
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      FeedItem(
        id: 4,
        username: 'newbie_climber',
        nickname: '뉴비',
        action: 'completed',
        routeName: '슬랩 구역 - V3 초록 #2',
        difficulty: 'V3',
        gymName: '스파이더클라임 판교',
        createdAt: now.subtract(const Duration(hours: 5)),
        rating: 4.0,
      ),
    ];
  }

  /// 역할별 추가 메뉴 (Mock)
  static List<String> getAdminMenus() {
    return ['전체 암장 관리', '사용자 관리', '통계 대시보드'];
  }

  static List<String> getGymManagerMenus() {
    return ['내 암장 관리', '세팅 등록', '회원 관리'];
  }
}