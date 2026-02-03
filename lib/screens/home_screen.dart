import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/mock_data_service.dart';
import '../models/user_stats.dart';
import '../models/gym.dart';
import '../models/gym_news.dart';
import '../models/feed_item.dart';
import 'login_screen.dart';
import 'gym_list_screen.dart';
import 'gym_detail_screen.dart';

/// 일반 회원 홈 화면
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _HomeTabPage(),
          GymListScreen(
            title: null, // AppBar 없이 (탭 안에 포함)
            showInactive: false, // 활성 암장만
          ),
          _RecordsPage(),
          _ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: '암장',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: '기록',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '프로필',
          ),
        ],
      ),
    );
  }
}

/// 홈 탭
class _HomeTabPage extends StatelessWidget {
  const _HomeTabPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final userStats = MockDataService.getUserStats();
    final subscribedGyms = MockDataService.getSubscribedGyms();
    final gymNews = MockDataService.getGymNews();
    final feedItems = MockDataService.getFeedItems();

    return CustomScrollView(
      slivers: [
        // AppBar
        SliverAppBar(
          floating: true,
          snap: true,
          expandedHeight: 120,
          flexibleSpace: FlexibleSpaceBar(
            title: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Climbing With!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${user?.nickname ?? ''} 님, 환영합니다!',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('알림 - 개발 예정')),
                );
              },
            ),
          ],
        ),

        // 사용자 통계 카드
        SliverToBoxAdapter(
          child: _buildUserStatsCard(context, userStats),
        ),

        // 역할별 빠른 메뉴 (ADMIN/GYM_MANAGER만)
        if (user?.role == 'ADMIN' || user?.role == 'GYM_MANAGER')
          SliverToBoxAdapter(
            child: _buildQuickMenuSection(context, user!.role),
          ),

        // 구독 암장 소식 섹션
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '📢 구독 암장 소식',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('전체 보기 - 개발 예정')),
                    );
                  },
                  child: const Text('전체 보기'),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _buildGymNewsSection(context, gymNews),
        ),

        // 최근 활동 피드
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: const Text(
              '📋 최근 활동',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final item = feedItems[index];
              return _buildFeedItem(context, item);
            },
            childCount: feedItems.length,
          ),
        ),

        // 하단 여백
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
      ],
    );
  }

  /// 사용자 통계 카드
  Widget _buildUserStatsCard(BuildContext context, UserStats stats) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('총 완등', '${stats.totalCompletions}개', Icons.check_circle),
              _buildStatItem('이번 달', '${stats.thisMonthCompletions}개', Icons.calendar_today),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('구독 암장', '${stats.subscribedGyms}개', Icons.store),
              _buildStatItem('최고 난이도', stats.highestDifficulty, Icons.trending_up),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  /// 역할별 빠른 메뉴
  Widget _buildQuickMenuSection(BuildContext context, String role) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.admin_panel_settings, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Text(
                role == 'ADMIN' ? '관리자 메뉴' : '지점장 메뉴',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (role == 'ADMIN') ...[
                ActionChip(
                  avatar: const Icon(Icons.dashboard, size: 18),
                  label: const Text('관리자 대시보드'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('관리자 대시보드 - 개발 예정')),
                    );
                  },
                ),
                ActionChip(
                  avatar: const Icon(Icons.people, size: 18),
                  label: const Text('사용자 관리'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('사용자 관리 - 개발 예정')),
                    );
                  },
                ),
              ],
              if (role == 'GYM_MANAGER') ...[
                ActionChip(
                  avatar: const Icon(Icons.add_business, size: 18),
                  label: const Text('세팅 등록'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('세팅 등록 - 개발 예정')),
                    );
                  },
                ),
                ActionChip(
                  avatar: const Icon(Icons.people, size: 18),
                  label: const Text('회원 관리'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('회원 관리 - 개발 예정')),
                    );
                  },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// 구독 암장 소식 섹션
  Widget _buildGymNewsSection(BuildContext context, List<GymNews> newsList) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: newsList.length,
        itemBuilder: (context, index) {
          final news = newsList[index];
          final timeAgo = _formatTimeAgo(news.createdAt);

          return Container(
            width: 300,
            margin: const EdgeInsets.only(right: 12),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GymDetailScreen(gymId: news.gymId),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 헤더
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getNewsTypeColor(news.newsType).withOpacity(0.8),
                            _getNewsTypeColor(news.newsType).withOpacity(0.6),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              news.gymName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              news.getNewsTypeText(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 내용
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              news.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Text(
                                news.content,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  timeAgo,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 소식 타입별 색상
  Color _getNewsTypeColor(String type) {
    switch (type) {
      case 'SETTING':
        return Colors.blue;
      case 'NOTICE':
        return Colors.orange;
      case 'EVENT':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  /// 피드 아이템
  Widget _buildFeedItem(BuildContext context, FeedItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            child: Text(item.nickname[0]),
          ),
          title: RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: [
                TextSpan(
                  text: item.nickname,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: ' ${_getActionText(item.action)} '),
                TextSpan(
                  text: item.routeName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text('${item.gymName} • ${item.difficulty}'),
              if (item.comment != null) ...[
                const SizedBox(height: 4),
                Text(item.comment!),
              ],
              if (item.rating != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < item.rating! ? Icons.star : Icons.star_border,
                      size: 16,
                      color: Colors.orange,
                    );
                  }),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                _formatTimeAgo(item.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getActionText(String action) {
    switch (action) {
      case 'completed':
        return '완등했습니다';
      case 'rated':
        return '평가했습니다';
      case 'commented':
        return '댓글을 남겼습니다';
      default:
        return action;
    }
  }

  String _formatTimeAgo(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);

    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}주 전';
    return '${(diff.inDays / 30).floor()}개월 전';
  }
}

/// 기록 탭
class _RecordsPage extends StatelessWidget {
  const _RecordsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 기록'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assessment,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              '기록 화면',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '개발 예정',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 프로필 탭
class _ProfilePage extends StatelessWidget {
  const _ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 24),
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Text(
              user?.nickname[0].toUpperCase() ?? 'U',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.nickname ?? '사용자',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '@${user?.username ?? 'user'}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Chip(
              avatar: const Icon(Icons.person, size: 18),
              label: Text(_getRoleText(user?.role ?? 'MEMBER')),
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('설정'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('설정 - 개발 예정')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('도움말'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('도움말 - 개발 예정')),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('로그아웃', style: TextStyle(color: Colors.red)),
            onTap: () => _handleLogout(context),
          ),
        ],
      ),
    );
  }

  String _getRoleText(String role) {
    switch (role) {
      case 'ADMIN':
        return '관리자';
      case 'GYM_MANAGER':
        return '지점장';
      default:
        return '일반 회원';
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('확인'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await context.read<AuthProvider>().logout();

      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }
}