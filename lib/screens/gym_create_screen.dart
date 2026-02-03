import 'package:flutter/material.dart';
import '../models/gym_create_dto.dart';
import '../services/gym_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

/// 암장 등록 화면
class GymCreateScreen extends StatefulWidget {
  const GymCreateScreen({Key? key}) : super(key: key);

  @override
  State<GymCreateScreen> createState() => _GymCreateScreenState();
}

class _GymCreateScreenState extends State<GymCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _gymService = GymService();

  // 필수 입력
  final _gymNameController = TextEditingController();
  final _addressController = TextEditingController();

  // 선택 입력
  final _memoController = TextEditingController();
  String? _selectedGymType;
  TimeOfDay? _openAt;
  TimeOfDay? _closeAt;
  TimeOfDay? _weekendOpenAt;
  TimeOfDay? _weekendCloseAt;

  bool _isLoading = false;

  final List<String> _gymTypes = ['BOULDER', 'LEAD', 'BOTH'];

  @override
  void dispose() {
    _gymNameController.dispose();
    _addressController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  /// 시간 선택 다이얼로그
  Future<void> _selectTime(BuildContext context, String label, TimeOfDay? initialTime, Function(TimeOfDay?) onSelected) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        onSelected(picked);
      });
    }
  }

  /// 암장 등록 처리
  Future<void> _handleCreateGym() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final dto = GymCreateDTO(
      gymName: _gymNameController.text.trim(),
      address: _addressController.text.trim(),
      gymType: _selectedGymType,
      openAt: _openAt,
      closeAt: _closeAt,
      weekendOpenAt: _weekendOpenAt,
      weekendCloseAt: _weekendCloseAt,
      memo: _memoController.text.trim().isNotEmpty ? _memoController.text.trim() : null,
    );

    // 유효성 검사
    final validationError = dto.validate();
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final gym = await _gymService.createGym(dto);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${gym.name} 암장이 등록되었습니다.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop(true); // 성공 결과 반환
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('암장 등록'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 안내 메시지
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '암장 이름과 주소만 입력하면 등록 가능합니다.\n운영시간 등은 나중에 수정할 수 있습니다.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 필수 정보
              Text(
                '필수 정보',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 12),

              // 암장 이름
              CustomTextField(
                controller: _gymNameController,
                label: '암장 이름',
                hintText: '예: 더클라임 강남점',
                prefixIcon: const Icon(Icons.store),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '암장 이름은 필수입니다.';
                  }
                  if (value.length < 2 || value.length > 20) {
                    return '암장 이름은 2~20자 이내여야 합니다.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 주소
              CustomTextField(
                controller: _addressController,
                label: '주소',
                hintText: '예: 서울 강남구 테헤란로 123',
                prefixIcon: const Icon(Icons.location_on),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '주소는 필수입니다.';
                  }
                  if (value.length < 4 || value.length > 100) {
                    return '주소를 정확하게 입력해주세요 (4~100자).';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // 선택 정보
              Text(
                '선택 정보 (나중에 입력 가능)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 12),

              // 암장 타입
              DropdownButtonFormField<String>(
                value: _selectedGymType,
                decoration: InputDecoration(
                  labelText: '암장 타입',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                hint: const Text('선택하세요'),
                items: _gymTypes.map((type) {
                  String displayName;
                  switch (type) {
                    case 'BOULDER':
                      displayName = '볼더링';
                      break;
                    case 'LEAD':
                      displayName = '리드';
                      break;
                    case 'BOTH':
                      displayName = '볼더링 + 리드';
                      break;
                    default:
                      displayName = type;
                  }
                  return DropdownMenuItem(
                    value: type,
                    child: Text(displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGymType = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // 평일 운영시간
              Text(
                '평일 운영시간',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildTimeButton(
                      context,
                      '오픈',
                      _openAt,
                          (time) => _openAt = time,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTimeButton(
                      context,
                      '마감',
                      _closeAt,
                          (time) => _closeAt = time,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 주말 운영시간
              Text(
                '주말 운영시간',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildTimeButton(
                      context,
                      '오픈',
                      _weekendOpenAt,
                          (time) => _weekendOpenAt = time,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTimeButton(
                      context,
                      '마감',
                      _weekendCloseAt,
                          (time) => _weekendCloseAt = time,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 메모
              CustomTextField(
                controller: _memoController,
                label: '메모',
                hintText: '특이사항이나 추가 정보를 입력하세요',
                prefixIcon: const Icon(Icons.note),
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 32),

              // 등록 버튼
              CustomButton(
                text: '암장 등록',
                onPressed: _handleCreateGym,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 시간 선택 버튼
  Widget _buildTimeButton(
      BuildContext context,
      String label,
      TimeOfDay? time,
      Function(TimeOfDay?) onSelected,
      ) {
    return OutlinedButton.icon(
      onPressed: () => _selectTime(context, label, time, onSelected),
      icon: const Icon(Icons.access_time),
      label: Text(
        time != null ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}' : label,
        style: TextStyle(
          color: time != null ? Colors.black87 : Colors.grey.shade600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}