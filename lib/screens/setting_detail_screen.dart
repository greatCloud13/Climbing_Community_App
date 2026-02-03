import 'package:flutter/material.dart';
import '../models/setting.dart';
import '../models/setting_dto.dart';
import '../services/setting_service.dart';
import '../widgets/custom_button.dart';

/// 세팅 상세 화면
/// - startDate, endDate가 null이면 날짜 설정 폼 표시
/// - 날짜 설정 완료 후 문제 관리 영역 표시
class SettingDetailScreen extends StatefulWidget {
  final int settingId;
  final String sectorName;

  const SettingDetailScreen({
    Key? key,
    required this.settingId,
    required this.sectorName,
  }) : super(key: key);

  @override
  State<SettingDetailScreen> createState() => _SettingDetailScreenState();
}

class _SettingDetailScreenState extends State<SettingDetailScreen> {
  final SettingService _settingService = SettingService();

  Setting? _setting;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  // 날짜 설정 폼용
  DateTime? _selectedSettingDate;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  @override
  void initState() {
    super.initState();
    _fetchSettingDetail();
  }

  /// 세팅 상세 조회
  Future<void> _fetchSettingDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final setting = await _settingService.getSettingDetail(widget.settingId);

      setState(() {
        _setting = setting;
        _isLoading = false;

        // 날짜가 이미 설정된 경우 폼에 기본값 세팅
        _selectedSettingDate = setting.settingDate;
        _selectedStartDate = setting.startDate;
        _selectedEndDate = setting.endDate;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  /// 날짜가 미설정 상태인지 판단
  bool get _isDateUnset {
    return _setting != null &&
        _setting!.startDate == null &&
        _setting!.endDate == null;
  }

  /// 날짜 선택 다이얼로그
  Future<void> _selectDate(BuildContext context, _DateType type) async {
    final DateTime now = DateTime.now();

    // 각 날짜 타입별 기본 초기값
    final DateTime initialDate = switch (type) {
      _DateType.settingDate => _selectedSettingDate ?? now,
      _DateType.startDate => _selectedStartDate ?? now,
      _DateType.endDate =>
      _selectedEndDate ?? now.add(const Duration(days: 30)),
    };

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        switch (type) {
          case _DateType.settingDate:
            _selectedSettingDate = picked;
          case _DateType.startDate:
            _selectedStartDate = picked;
          case _DateType.endDate:
            _selectedEndDate = picked;
        }
      });
    }
  }

  /// 날짜 설정 폼 유효성 검사
  bool get _isDateFormValid {
    return _selectedSettingDate != null &&
        _selectedStartDate != null &&
        _selectedEndDate != null;
  }

  /// 날짜 설정 저장
  Future<void> _handleUpdateDates() async {
    if (!_isDateFormValid) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final dto = SettingUpdateDTO(
        settingDate: _selectedSettingDate!,
        startDate: _selectedStartDate!,
        endDate: _selectedEndDate!,
      );

      final updatedSetting =
      await _settingService.updateSetting(widget.settingId, dto);

      setState(() {
        _setting = updatedSetting;
        _isSubmitting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('날짜 설정이 완료되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('날짜 설정 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('세팅 상세')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(_errorMessage!),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _fetchSettingDetail,
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('세팅 상세'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 섹터 정보 카드
            _buildSectorInfoCard(),
            const SizedBox(height: 24),

            // 날짜 미설정 → 날짜 설정 폼
            // 날짜 설정 완료 → 문제 관리 영역
            if (_isDateUnset) _buildDateSetupForm() else _buildProblemManagement(),
          ],
        ),
      ),
    );
  }

  /// 섹터 정보 카드
  Widget _buildSectorInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.grid_view,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '섹터',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                widget.sectorName,
                style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const Spacer(),
          // 세팅 상태 배지
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _isDateUnset ? Colors.orange.shade100 : Colors.green.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _isDateUnset ? '날짜 설정 필요' : '활성',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _isDateUnset ? Colors.orange.shade800 : Colors.green.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 날짜 설정 폼 (startDate, endDate가 null인 경우)
  Widget _buildDateSetupForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 안내 메시지
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '세팅일, 시작일, 종료일을 설정해야 문제를 추가할 수 있습니다.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.orange.shade900,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // 세팅일
        _buildDateField(
          label: '세팅일',
          icon: Icons.build,
          iconColor: Theme.of(context).primaryColor,
          selectedDate: _selectedSettingDate,
          onTap: () => _selectDate(context, _DateType.settingDate),
          onClear: () => setState(() { _selectedSettingDate = null; }),
        ),
        const SizedBox(height: 20),

        // 시작일
        _buildDateField(
          label: '시작일',
          icon: Icons.play_circle_outline,
          iconColor: Colors.green.shade700,
          selectedDate: _selectedStartDate,
          onTap: () => _selectDate(context, _DateType.startDate),
          onClear: () => setState(() { _selectedStartDate = null; }),
        ),
        const SizedBox(height: 20),

        // 종료일
        _buildDateField(
          label: '종료일',
          icon: Icons.stop_circle_outlined,
          iconColor: Colors.red.shade600,
          selectedDate: _selectedEndDate,
          onTap: () => _selectDate(context, _DateType.endDate),
          onClear: () => setState(() { _selectedEndDate = null; }),
        ),
        const SizedBox(height: 40),

        // 저장 버튼
        CustomButton(
          text: '날짜 설정 완료',
          onPressed: _isDateFormValid ? _handleUpdateDates : null,
          isLoading: _isSubmitting,
        ),
      ],
    );
  }

  /// 문제 관리 영역 (날짜 설정 완료 후)
  Widget _buildProblemManagement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 설정된 날짜 정보 카드
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateRow('세팅일', _setting!.settingDate),
              const SizedBox(height: 10),
              _buildDateRow('시작일', _setting!.startDate),
              const SizedBox(height: 10),
              _buildDateRow('종료일', _setting!.endDate),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 문제 관리 영역 (TODO: Problem API 완료 후 구현)
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade300,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            children: [
              Icon(Icons.add_circle_outline, size: 40, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              const Text(
                '문제 관리',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '현재 개발 중입니다.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 날짜 필드 공통 위짓
  Widget _buildDateField({
    required String label,
    required IconData icon,
    required Color iconColor,
    required DateTime? selectedDate,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? _formatDate(selectedDate)
                        : '$label을 선택하세요',
                    style: TextStyle(
                      fontSize: 15,
                      color: selectedDate != null
                          ? Colors.black87
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
                if (selectedDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: onClear,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 날짜 행 표시 (날짜 설정 완료 후 정보 카드용)
  Widget _buildDateRow(String label, DateTime? date) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        Text(
          date != null ? _formatDate(date) : '-',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ]
    );
  }

  /// 날짜 포맷팅
  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }
}

/// 날짜 타입 열거형 (날짜 선택 다이얼로그 구분용)
enum _DateType {
  settingDate,
  startDate,
  endDate,
}