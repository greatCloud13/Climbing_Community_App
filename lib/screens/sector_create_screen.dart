import 'package:flutter/material.dart';
import '../models/sector.dart';
import '../models/sector_dto.dart';
import '../services/sector_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

/// 섹터 추가 화면 (GYM_MANAGER용)
class SectorCreateScreen extends StatefulWidget {
  final int gymId;
  final String gymName;

  const SectorCreateScreen({
    Key? key,
    required this.gymId,
    required this.gymName,
  }) : super(key: key);

  @override
  State<SectorCreateScreen> createState() => _SectorCreateScreenState();
}

class _SectorCreateScreenState extends State<SectorCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sectorNameController = TextEditingController();
  final SectorService _sectorService = SectorService();

  bool _isLoading = false;

  @override
  void dispose() {
    _sectorNameController.dispose();
    super.dispose();
  }

  /// 섹터 생성 처리
  Future<void> _handleCreateSector() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final dto = SectorCreateDTO(
        gymId: widget.gymId,
        sectorName: _sectorNameController.text.trim(),
      );

      await _sectorService.createSector(dto);

      if (!mounted) return;

      // 성공 시 이전 화면으로 돌아가며 결과 전달
      Navigator.of(context).pop(true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('섹터가 생성되었습니다.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('섹터 생성 실패: $e'),
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
        title: const Text('섹터 추가'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 암장 정보
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.store,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '암장',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.gymName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 안내 텍스트
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '섹터는 암장 내 특정 구역을 의미합니다',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 섹터 이름 입력
              CustomTextField(
                controller: _sectorNameController,
                label: '섹터 이름',
                hintText: '예: A구역, B구역, 초보자존 등',
                prefixIcon: const Icon(Icons.grid_view),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '섹터 이름을 입력해주세요';
                  }
                  if (value.trim().length < 2) {
                    return '섹터 이름은 2자 이상이어야 합니다';
                  }
                  if (value.trim().length > 20) {
                    return '섹터 이름은 20자 이하여야 합니다';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // 추가 정보
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 18,
                          color: Colors.grey.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '추가 정보',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• 섹터 생성 후 세팅을 등록할 수 있습니다\n'
                          '• 섹터 이름은 나중에 수정할 수 있습니다\n'
                          '• 각 섹터마다 독립적으로 세팅을 관리할 수 있습니다',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // 생성 버튼
              CustomButton(
                text: '섹터 추가',
                onPressed: _handleCreateSector,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}