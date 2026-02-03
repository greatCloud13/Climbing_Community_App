import 'package:flutter/material.dart';
import '../models/setting_dto.dart';
import '../services/setting_service.dart';
import '../widgets/custom_button.dart';
import 'setting_detail_screen.dart';

/// 세팅 생성 화면
/// 생성 후 세팅 상세 화면(날짜 설정)으로 자동 이동
class SettingCreateScreen extends StatefulWidget {
  final int sectorId;
  final int gymId;
  final String sectorName;

  const SettingCreateScreen({
    Key? key,
    required this.sectorId,
    required this.gymId,
    required this.sectorName,
  }) : super(key: key);

  @override
  State<SettingCreateScreen> createState() => _SettingCreateScreenState();
}

class _SettingCreateScreenState extends State<SettingCreateScreen> {
  final SettingService _settingService = SettingService();
  bool _isLoading = false;

  /// 세팅 생성 처리
  Future<void> _handleCreateSetting() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dto = SettingCreateDTO(
        sectorId: widget.sectorId,
        gymId: widget.gymId,
      );

      final createdSetting = await _settingService.createSetting(dto);

      if (!mounted) return;

      // 생성된 세팅 상세 화면으로 이동 (날짜 설정 단계)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => SettingDetailScreen(
            settingId: createdSetting.id,
            sectorName: widget.sectorName,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('세팅 생성 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('세팅 추가'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 섹터 정보 카드
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
                  Row(
                    children: [
                      Icon(
                        Icons.grid_view,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        '대상 섹터',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.sectorName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 안내 메시지
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '세팅을 생성하면 날짜 설정 및 문제 추가 화면으로 이동합니다.\n세팅일, 시작일, 종료일을 설정한 후 문제를 추가할 수 있습니다.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade900,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // 세팅 생성 버튼
            CustomButton(
              text: '세팅 생성',
              onPressed: _handleCreateSetting,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}