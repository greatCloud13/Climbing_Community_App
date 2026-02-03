/// 세팅 생성 요청 DTO
/// POST /api/setting
class SettingCreateDTO {
  final int sectorId;
  final int gymId;

  SettingCreateDTO({
    required this.sectorId,
    required this.gymId,
  });

  /// DTO를 JSON으로 변환 (요청 body)
  Map<String, dynamic> toJson() {
    return {
      'sectorId': sectorId,
      'gymId': gymId,
    };
  }
}

/// 세팅 날짜 수정 요청 DTO
/// PUT /api/setting/{id}
class SettingUpdateDTO {
  final DateTime settingDate;
  final DateTime startDate;
  final DateTime endDate;

  SettingUpdateDTO({
    required this.settingDate,
    required this.startDate,
    required this.endDate,
  });

  /// DTO를 JSON으로 변환 (요청 body)
  /// 날짜 형식: yyyy-MM-dd (백엔드 expects)
  Map<String, dynamic> toJson() {
    return {
      'settingDate': _formatDate(settingDate),
      'startDate': _formatDate(startDate),
      'endDate': _formatDate(endDate),
    };
  }

  /// 날짜를 yyyy-MM-dd 형식으로 변환
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}