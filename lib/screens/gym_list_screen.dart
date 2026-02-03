import 'package:flutter/material.dart';
import '../models/gym.dart';
import '../models/paged_response.dart';
import '../services/gym_service.dart';
import 'gym_detail_screen.dart';

/// 암장 목록 화면 (무한 스크롤)
class GymListScreen extends StatefulWidget {
  final bool showInactive; // 비활성 암장도 표시 여부
  final String? title; // AppBar 제목 (null이면 검색바와 필터만 표시)

  const GymListScreen({
    Key? key,
    this.showInactive = true,
    this.title = '암장 목록',
  }) : super(key: key);

  @override
  State<GymListScreen> createState() => _GymListScreenState();
}

class _GymListScreenState extends State<GymListScreen> {
  final GymService _gymService = GymService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<Gym> _gyms = [];
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _errorMessage;
  String _searchQuery = '';
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _loadGyms();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// 스크롤 이벤트 처리
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      if (!_isLoading && _hasMore) {
        _loadMore();
      }
    }
  }

  /// 초기 로드
  Future<void> _loadGyms() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _gymService.getGyms(page: 0, size: 20);

      setState(() {
        _gyms = response.content;
        _currentPage = 0;
        _hasMore = response.hasMore;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// 다음 페이지 로드
  Future<void> _loadMore() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _gymService.getGyms(
        page: _currentPage + 1,
        size: 20,
      );

      setState(() {
        _gyms.addAll(response.content);
        _currentPage++;
        _hasMore = response.hasMore;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로드 실패: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // title이 null이면 검색바와 필터만 있는 심플한 뷰 (관리자 탭용)
    if (widget.title == null) {
      return CustomScrollView(
        controller: _scrollController,
        slivers: [
          // 검색 바
          SliverToBoxAdapter(
            child: _buildSearchBar(),
          ),

          // 필터 칩
          SliverToBoxAdapter(
            child: _buildFilterChips(),
          ),

          // 암장 목록
          _buildSliverBody(),
        ],
      );
    }

    // title이 있으면 기본 Scaffold
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadGyms,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  /// 검색 바
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '암장 이름 검색...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _searchController.clear();
                _searchQuery = '';
              });
            },
          )
              : null,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  /// 필터 칩
  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              label: const Text('전체'),
              selected: _selectedType == null,
              onSelected: (selected) {
                setState(() {
                  _selectedType = null;
                });
              },
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('볼더링'),
              selected: _selectedType == 'BOULDER',
              onSelected: (selected) {
                setState(() {
                  _selectedType = selected ? 'BOULDER' : null;
                });
              },
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('리드'),
              selected: _selectedType == 'LEAD',
              onSelected: (selected) {
                setState(() {
                  _selectedType = selected ? 'LEAD' : null;
                });
              },
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('복합'),
              selected: _selectedType == 'BOTH',
              onSelected: (selected) {
                setState(() {
                  _selectedType = selected ? 'BOTH' : null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Sliver Body
  Widget _buildSliverBody() {
    if (_errorMessage != null && _gyms.isEmpty) {
      return SliverFillRemaining(
        child: _buildErrorState(),
      );
    }

    if (_gyms.isEmpty && _isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final filteredGyms = _getFilteredGyms();

    if (filteredGyms.isEmpty) {
      return SliverFillRemaining(
        child: _buildEmptyState(),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            if (index >= filteredGyms.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            return _buildGymCard(filteredGyms[index]);
          },
          childCount: filteredGyms.length + (_hasMore ? 1 : 0),
        ),
      ),
    );
  }

  /// 일반 Body (Scaffold용)
  Widget _buildBody() {
    if (_errorMessage != null && _gyms.isEmpty) {
      return _buildErrorState();
    }

    if (_gyms.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredGyms = _getFilteredGyms();

    if (filteredGyms.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadGyms,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: filteredGyms.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= filteredGyms.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          return _buildGymCard(filteredGyms[index]);
        },
      ),
    );
  }

  /// 필터링된 암장 목록
  List<Gym> _getFilteredGyms() {
    var filtered = _gyms;

    // 활성/비활성 필터
    if (!widget.showInactive) {
      filtered = filtered.where((gym) => gym.isActive).toList();
    }

    // 검색어 필터
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((gym) =>
      gym.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          gym.location.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // 타입 필터
    if (_selectedType != null) {
      filtered = filtered.where((gym) => gym.gymType == _selectedType).toList();
    }

    return filtered;
  }

  /// 에러 상태
  Widget _buildErrorState() {
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
            '로드 실패',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadGyms,
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
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            '검색 결과 없음',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '다른 검색어나 필터를 시도해보세요',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  /// 암장 카드
  Widget _buildGymCard(Gym gym) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          if (gym.id != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => GymDetailScreen(gymId: gym.id!),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 (그라데이션)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.8),
                    Theme.of(context).primaryColor.withOpacity(0.6),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gym.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                gym.location,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!gym.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '영업 중지',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 내용
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 암장 타입
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getTypeColor(gym.gymType).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getTypeIcon(gym.gymType),
                              size: 16,
                              color: _getTypeColor(gym.gymType),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              gym.getGymTypeText(),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _getTypeColor(gym.gymType),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 운영 시간
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 18,
                          color: Colors.grey.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            gym.getOperatingHours(),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 메모
                  if (gym.memo != null && gym.memo!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            gym.memo!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 타입별 색상
  Color _getTypeColor(String? type) {
    switch (type) {
      case 'BOULDER':
        return Colors.orange;
      case 'LEAD':
        return Colors.blue;
      case 'BOTH':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  /// 타입별 아이콘
  IconData _getTypeIcon(String? type) {
    switch (type) {
      case 'BOULDER':
        return Icons.terrain;
      case 'LEAD':
        return Icons.height;
      case 'BOTH':
        return Icons.layers;
      default:
        return Icons.category;
    }
  }
}