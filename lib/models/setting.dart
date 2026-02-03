/// 세팅 모델
class Setting {
  final int id;
  final int? sectorId;
  final String? sectorName;
  final String? gymName;
  final DateTime? settingDate;  // 생성 시 null, PUT 후 날짜 설정됨
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? clearDate;  // Mock 데이터용
  final bool isActive;
  final int? problemCount;    // Mock 데이터용
  final int? clearUserCount;  // Mock 데이터용

  Setting({
    required this.id,
    this.sectorId,
    this.sectorName,
    this.gymName,
    this.settingDate,
    this.startDate,
    this.endDate,
    this.clearDate,
    required this.isActive,
    this.problemCount,
    this.clearUserCount,
  });

  /// JSON을 Setting 객체로 변환
  factory Setting.fromJson(Map<String, dynamic> json) {
    return Setting(
      id: json['id'] as int,
      sectorId: json['sectorId'] as int?,
      sectorName: json['sectorName'] as String?,
      gymName: json['gymName'] as String?,
      settingDate: json['settingDate'] != null
          ? DateTime.parse(json['settingDate'] as String)
          : null,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      isActive: json['active'] == true || json['active'] == 'true',
      problemCount: json['problemCount'] as int?,
      clearUserCount: json['clearUserCount'] as int?,
    );
  }

  /// Setting 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (sectorId != null) 'sectorId': sectorId,
      if (sectorName != null) 'sectorName': sectorName,
      if (gymName != null) 'gymName': gymName,
      if (settingDate != null) 'settingDate': settingDate!.toIso8601String().split('T')[0],
      if (startDate != null) 'startDate': startDate!.toIso8601String().split('T')[0],
      if (endDate != null) 'endDate': endDate!.toIso8601String().split('T')[0],
      'active': isActive,
      if (problemCount != null) 'problemCount': problemCount,
      if (clearUserCount != null) 'clearUserCount': clearUserCount,
    };
  }

  /// 세팅일 포맷팅 (null이면 null 반환)
  String? getSettingDateText() {
    if (settingDate == null) return null;
    return '${settingDate!.year}.${settingDate!.month.toString().padLeft(2, '0')}.${settingDate!.day.toString().padLeft(2, '0')}';
  }

  /// 세팅 기간 텍스트
  String? getSettingPeriodText() {
    if (startDate == null || endDate == null) return null;
    return '${_formatDate(startDate!)} ~ ${_formatDate(endDate!)}';
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}