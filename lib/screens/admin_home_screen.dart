import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/mock_data_service.dart';
import '../models/admin_stats.dart';
import '../models/gym_management.dart';
import '../models/user_management.dart';
import 'login_screen.dart';
import 'gym_list_screen.dart';
import 'gym_create_screen.dart';

/// 관리자 전용 홈 화면
class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _AdminDashboardPage(),
          _GymManagementPage(),
          _UserManagementPage(),
          _StatisticsPage(),
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
            icon: Icon(Icons.dashboard),
            label: '대시보드',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: '암장 관리',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: '사용자',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: '통계',
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
class _AdminDashboardPage extends StatelessWidget {
  const _AdminDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final stats = MockDataService.getAdminStats();

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
                  'Climbing With! 관리자',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${user?.nickname ?? ''} 님',
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

        // 주요 통계
        SliverToBoxAdapter(
          child: _buildMainStatsSection(context, stats),
        ),

        // 알림 섹션
        if (stats.pendingReports > 0)
          SliverToBoxAdapter(
            child: _buildAlertSection(context, stats),
          ),

        // 빠른 작업
        SliverToBoxAdapter(
          child: _buildQuickActionsSection(context),
        ),

        // 최근 활동 요약
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Text(
              '📊 시스템 현황',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _buildSystemStatusSection(context, stats),
        ),

        // 하단 여백
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
      ],
    );
  }

  /// 주요 통계 섹션
  Widget _buildMainStatsSection(BuildContext context, AdminStats stats) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  '전체 암장',
                  '${stats.totalGyms}개',
                  Icons.store,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  '전체 사용자',
                  '${stats.totalUsers}명',
                  Icons.people,
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
                  '활성 암장',
                  '${stats.activeGyms}개',
                  Icons.check_circle,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  '오늘 가입',
                  '${stats.todaySignups}명',
                  Icons.person_add,
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

  /// 알림 섹션
  Widget _buildAlertSection(BuildContext context, AdminStats stats) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: Colors.red.shade50,
        child: ListTile(
          leading: Icon(Icons.warning, color: Colors.red.shade700),
          title: Text(
            '처리 대기 중인 신고 ${stats.pendingReports}건',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red.shade900,
            ),
          ),
          subtitle: const Text('확인이 필요합니다'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('신고 관리 - 개발 예정')),
            );
          },
        ),
      ),
    );
  }

  //// 빠른 작업 섹션
  Widget _buildQuickActionsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
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
                  '암장 등록',
                  Icons.add_business,
                  Colors.blue,
                      () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const GymCreateScreen(),
                      ),
                    );

                    if (result == true && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('암장이 성공적으로 등록되었습니다.'),
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
                  '통계 보기',
                  Icons.bar_chart,
                  Colors.green,
                      () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('통계 대시보드 - 개발 예정')),
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
                  '공지사항',
                  Icons.campaign,
                  Colors.orange,
                      () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('공지사항 - 개발 예정')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  context,
                  '시스템 설정',
                  Icons.settings,
                  Colors.purple,
                      () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('시스템 설정 - 개발 예정')),
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

  /// 시스템 현황 섹션
  Widget _buildSystemStatusSection(BuildContext context, AdminStats stats) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildStatusRow('총 세팅 수', '${stats.totalSettings}개', Colors.blue),
              const Divider(height: 24),
              _buildStatusRow('활성 암장 비율', '${((stats.activeGyms / stats.totalGyms) * 100).toStringAsFixed(1)}%', Colors.green),
              const Divider(height: 24),
              _buildStatusRow('평균 회원 수/암장', '${(stats.totalUsers / stats.totalGyms).toStringAsFixed(0)}명', Colors.orange),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// 암장 관리 탭
class _GymManagementPage extends StatelessWidget {
  const _GymManagementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('암장 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const GymCreateScreen(),
                ),
              );

              if (result == true && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('암장이 등록되었습니다.'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('암장 검색 - 개발 예정')),
              );
            },
          ),
        ],
      ),
      body: const GymListScreen(
        title: null, // AppBar 없이 (이미 Scaffold AppBar 있음)
        showInactive: true, // ADMIN은 비활성 암장도 표시
      ),
    );
  }
}


/// 사용자 관리 탭
class _UserManagementPage extends StatelessWidget {
  const _UserManagementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final users = MockDataService.getAllUsers();

    return Scaffold(
      appBar: AppBar(
        title: const Text('사용자 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('사용자 검색 - 개발 예정')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('필터 - 개발 예정')),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: _getRoleColor(user.role).withOpacity(0.2),
                child: Text(
                  user.nickname[0],
                  style: TextStyle(
                    color: _getRoleColor(user.role),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      user.nickname,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildRoleBadge(user.role),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('@${user.username}'),
                  Text(user.email),
                  Text(
                    '가입일: ${user.createdAt.year}.${user.createdAt.month}.${user.createdAt.day}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('정보 수정'),
                  ),
                  const PopupMenuItem(
                    value: 'role',
                    child: Text('역할 변경'),
                  ),
                  PopupMenuItem(
                    value: 'status',
                    child: Text(user.isActive ? '계정 정지' : '계정 활성화'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('삭제', style: TextStyle(color: Colors.red)),
                  ),
                ],
                onSelected: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$value - 개발 예정')),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    Color color;
    String label;

    switch (role) {
      case 'ADMIN':
        color = Colors.red;
        label = '관리자';
        break;
      case 'GYM_MANAGER':
        color = Colors.orange;
        label = '지점장';
        break;
      default:
        color = Colors.blue;
        label = '회원';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'ADMIN':
        return Colors.red;
      case 'GYM_MANAGER':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}

/// 통계 탭
class _StatisticsPage extends StatelessWidget {
  const _StatisticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('통계'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              '상세 통계 대시보드',
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
            backgroundColor: Colors.red.shade100,
            child: Text(
              user?.nickname[0].toUpperCase() ?? 'A',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.nickname ?? '관리자',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '@${user?.username ?? 'admin'}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Chip(
              avatar: const Icon(Icons.admin_panel_settings, size: 18),
              label: const Text('최고 관리자'),
              backgroundColor: Colors.red.shade100,
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('시스템 설정'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('시스템 설정 - 개발 예정')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('보안 설정'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('보안 설정 - 개발 예정')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('활동 로그'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('활동 로그 - 개발 예정')),
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

      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      }
    }
  }
}