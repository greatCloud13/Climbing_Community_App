import 'package:flutter/material.dart';
import '../models/sector.dart';
import '../models/sector_dto.dart';
import '../services/sector_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

/// 섹터 수정 화면 (세팅일 업데이트)
class SectorUpdateScreen extends StatefulWidget {
  final Sector sector;

  const SectorUpdateScreen({
    Key? key,
    required this.sector,
  }) : super(key: key);

  @override
  State<SectorUpdateScreen> createState() => _SectorUpdateScreenState();
}

class _SectorUpdateScreenState extends State<SectorUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sectorNameController = TextEditingController();
  final SectorService _sectorService = SectorService();

  DateTime? _selectedSettingDate;
  DateTime? _selectedNextSettingDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _sectorNameController.text = widget.sector.name;
    _selectedSettingDate = widget.sector.settingDate;
    _selectedNextSettingDate = widget.sector.nextSettingDate;
  }

  @override
  void dispose() {
    _sectorNameController.dispose();
    super.dispose();
  }

  /// 날짜 선택
  Future<void> _selectDate(BuildContext context, bool isSettingDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isSettingDate
          ? (_selectedSettingDate ?? DateTime.now())
          : (_selectedNextSettingDate ?? DateTime.now().add(const Duration(days: 30))),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isSettingDate) {
          _selectedSettingDate = picked;
        } else {
          _selectedNextSettingDate = picked;
        }
      });
    }
  }

  /// 섹터 수정 처리
  Future<void> _handleUpdateSector() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final dto = SectorUpdateDTO(
        sectorName: _sectorNameController.text.trim(),
        settingDate: _selectedSettingDate,
        nextSettingDate: _selectedNextSettingDate,
      );

      await _sectorService.updateSector(widget.sector.id, dto);

      if (!mounted) return;

      Navigator.of(context).pop(true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('섹터 정보가 수정되었습니다.'),
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
            content: Text('섹터 수정 실패: $e'),
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
        title: const Text('섹터 수정'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 섹터 이름 수정
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
              const SizedBox(height: 24),

              // 세팅일 선택
              const Text(
                '세팅일',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDate(context, true),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedSettingDate != null
                              ? _formatDate(_selectedSettingDate!)
                              : '세팅일을 선택하세요',
                          style: TextStyle(
                            fontSize: 15,
                            color: _selectedSettingDate != null
                                ? Colors.black87
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                      if (_selectedSettingDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            setState(() {
                              _selectedSettingDate = null;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 다음 세팅 예정일 선택
              const Text(
                '다음 세팅 예정일',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDate(context, false),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.event,
                        color: Colors.orange.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedNextSettingDate != null
                              ? _formatDate(_selectedNextSettingDate!)
                              : '다음 세팅 예정일을 선택하세요 (선택사항)',
                          style: TextStyle(
                            fontSize: 15,
                            color: _selectedNextSettingDate != null
                                ? Colors.black87
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                      if (_selectedNextSettingDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            setState(() {
                              _selectedNextSettingDate = null;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

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
                        '다음 세팅 예정일을 설정하면 회원들에게 미리 알릴 수 있습니다',
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

              // 수정 버튼
              CustomButton(
                text: '수정 완료',
                onPressed: _handleUpdateSector,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }
}