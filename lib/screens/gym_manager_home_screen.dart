import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/gym_provider.dart';
import '../services/mock_data_service.dart';
import '../services/sector_service.dart';
import '../models/gym.dart';
import '../models/gym_stats.dart';
import '../models/sector.dart';
import 'setting_create_screen.dart';
import '../models/feed_item.dart';
import 'login_screen.dart';
import 'sector_create_screen.dart';
import 'sector_update_screen.dart';

/// 지점장 전용 홈 화면
class GymManagerHomeScreen extends StatefulWidget {
  const GymManagerHomeScreen({Key? key}) : super(key: key);

  @override
  State<GymManagerHomeScreen> createState() => _GymManagerHomeScreenState();
}

class _GymManagerHomeScreenState extends State<GymManagerHomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadGym();
  }

  /// 암장 정보 로드
  Future<void> _loadGym() async {
    final user = context.read<AuthProvider>().user;
    if (user?.managedGymId != null) {
      await context.read<GymProvider>().loadGym(user!.managedGymId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _GymManagerHomePage(),
          _SectorManagementPage(),
          _MemberManagementPage(),
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: '대시보드',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_module),
            label: '섹터 관리',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: '회원 관리',
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

/// 대시보드 탭
class _GymManagerHomePage extends StatelessWidget {
  const _GymManagerHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final gym = context.watch<GymProvider>().gym;
    final stats = MockDataService.getGymStats();
    final recentActivity = MockDataService.getMyGymActivity();

    // 암장 정보 로드 중 또는 없는 경우
    if (gym == null) {
      return const Center(child: CircularProgressIndicator());
    }

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
                Text(
                  gym.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '지점장: ${user?.nickname ?? ''}',
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

        // 통계 카드
        SliverToBoxAdapter(
          child: _buildStatsSection(context, stats),
        ),

        // 빠른 작업
        SliverToBoxAdapter(
          child: _buildQuickActionsSection(context, gym),
        ),

        // 최근 활동
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Row(
              children: [
                const Text(
                  '📊 최근 회원 활동',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('전체 활동 보기 - 개발 예정')),
                    );
                  },
                  child: const Text('전체보기'),
                ),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              if (index >= recentActivity.length) return null;
              return _buildActivityItem(context, recentActivity[index]);
            },
            childCount: recentActivity.length,
          ),
        ),

        // 하단 여백
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
      ],
    );
  }

  /// 통계 섹션
  Widget _buildStatsSection(BuildContext context, GymStats stats) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  '총 회원',
                  '${stats.totalMembers}명',
                  Icons.people,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  '오늘 방문',
                  '${stats.todayVisitors}명',
                  Icons.login,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  '활성 섹터',
                  '${stats.activeSectors}개',
                  Icons.view_module,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  '총 문제',
                  '${stats.totalProblems}개',
                  Icons.grid_on,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      BuildContext context,
      String label,
      String value,
      IconData icon,
      Color color,
      ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 빠른 작업 섹션
  Widget _buildQuickActionsSection(BuildContext context, Gym gym) {
    final user = context.watch<AuthProvider>().user;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '⚡ 빠른 작업',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  context,
                  '섹터 추가',
                  Icons.add_circle,
                  Colors.deepOrange,
                      () async {
                    if (user?.managedGymId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('관리 중인 암장 정보가 없습니다.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SectorCreateScreen(
                          gymId: user!.managedGymId!,
                          gymName: gym.name,
                        ),
                      ),
                    );

                    if (result == true && context.mounted) {
                      // 목록 새로고침 알림
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('섹터가 추가되었습니다. 섹터 관리 탭에서 확인하세요.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  context,
                  '세팅 종료',
                  Icons.clear,
                  Colors.grey,
                      () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('세팅 종료 - 개발 예정')),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  context,
                  '회원 통계',
                  Icons.bar_chart,
                  Colors.blue,
                      () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('회원 통계 - 개발 예정')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  context,
                  '공지사항',
                  Icons.announcement,
                  Colors.purple,
                      () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('공지사항 작성 - 개발 예정')),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
      BuildContext context,
      String label,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 활동 아이템
  Widget _buildActivityItem(BuildContext context, FeedItem item) {
    final timeAgo = _getTimeAgo(item.createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Text(
            item.nickname[0],
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: [
              TextSpan(
                text: item.nickname,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: item.action == 'completed' ? ' 님이 완등: ' : ' 님이 평가: ',
              ),
              TextSpan(
                text: item.routeName,
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ],
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.comment != null) ...[
              const SizedBox(height: 4),
              Text(
                item.comment!,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              timeAgo,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        trailing: item.rating != null
            ? Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, size: 16, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                item.rating!.toStringAsFixed(1),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        )
            : null,
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else {
      return '${difference.inDays}일 전';
    }
  }
}

/// 섹터 관리 탭
class _SectorManagementPage extends StatefulWidget {
  const _SectorManagementPage({Key? key}) : super(key: key);

  @override
  State<_SectorManagementPage> createState() => _SectorManagementPageState();
}

class _SectorManagementPageState extends State<_SectorManagementPage> {
  final SectorService _sectorService = SectorService();
  List<Sector> _sectors = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSectors();
  }

  /// 섹터 목록 로드
  Future<void> _loadSectors() async {
    final user = context.read<AuthProvider>().user;

    if (user?.managedGymId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = '관리 중인 암장 정보가 없습니다.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final sectors = await _sectorService.getSectorsByGymId(user!.managedGymId!);

      setState(() {
        _sectors = sectors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '섹터 로드 실패: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final gym = context.watch<GymProvider>().gym;

    return Scaffold(
      appBar: AppBar(
        title: Text('${gym?.name ?? '암장'} - 섹터 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              if (user?.managedGymId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('관리 중인 암장 정보가 없습니다.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SectorCreateScreen(
                    gymId: user!.managedGymId!,
                    gymName: gym?.name ?? '암장',
                  ),
                ),
              );

              if (result == true) {
                _loadSectors();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorState(_errorMessage!)
          : _sectors.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
        onRefresh: _loadSectors,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _sectors.length,
          itemBuilder: (context, index) {
            return _buildSectorCard(_sectors[index]);
          },
        ),
      ),
    );
  }

  /// 에러 상태
  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadSectors,
            icon: const Icon(Icons.refresh),
            label: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  /// 빈 상태
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.grid_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            '등록된 섹터가 없습니다',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '새 섹터를 추가해보세요',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  /// 섹터 카드
  Widget _buildSectorCard(Sector sector) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(
            Icons.grid_view,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          sector.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (sector.settingDate != null) ...[
              Text('세팅일: ${sector.getSettingDateText()}'),
              if (sector.nextSettingDate != null)
                Text(
                  '다음 세팅: ${sector.getNextSettingDateText()}',
                  style: TextStyle(color: Colors.orange.shade700),
                ),
            ] else ...[
              const Text(
                '세팅 정보 없음',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'setting',
              child: Text('새 세팅 등록'),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Text('섹터 수정'),
            ),
          ],
          onSelected: (value) async {
            if (value == 'setting') {
              final user = context.read<AuthProvider>().user;

              if (user?.managedGymId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('관리 중인 암장 정보가 없습니다.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // 세팅 생성 화면으로 이동
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SettingCreateScreen(
                    sectorId: sector.id,
                    gymId: user!.managedGymId!,
                    sectorName: sector.name,
                  ),
                ),
              );
            } else if (value == 'edit') {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SectorUpdateScreen(sector: sector),
                ),
              );

              if (result == true) {
                _loadSectors(); // 목록 새로고침
              }
            }
          },
        ),
      ),
    );
  }
}

/// 회원 관리 탭
class _MemberManagementPage extends StatelessWidget {
  const _MemberManagementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원 관리'),
      ),
      body: const Center(
        child: Text('회원 관리 - 개발 예정'),
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
    final gym = context.watch<GymProvider>().gym;

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
            '@${user?.username ?? 'username'}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Chip(
              avatar: const Icon(Icons.manage_accounts, size: 18),
              label: const Text('지점장'),
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              gym?.name ?? '암장 정보 없음',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('내 암장 정보'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('암장 정보 - 개발 예정')),
              );
            },
          ),
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
      context.read<GymProvider>().clear();

      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }
}