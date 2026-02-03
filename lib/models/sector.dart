import 'setting.dart';

/// 섹터 모델
class Sector {
  final int id;
  final String name;
  final DateTime? settingDate;
  final DateTime? nextSettingDate;

  // Mock 데이터용 필드 (나중에 제거 예정)
  final int? gymId;
  final Setting? currentSetting;

  Sector({
    required this.id,
    required this.name,
    this.settingDate,
    this.nextSettingDate,
    this.gymId,
    this.currentSetting,
  });

  /// JSON을 Sector 객체로 변환
  factory Sector.fromJson(Map<String, dynamic> json) {
    return Sector(
      id: json['id'] as int,
      name: json['sectorName'] as String,
      settingDate: json['settingDate'] != null
          ? DateTime.parse(json['settingDate'] as String)
          : null,
      nextSettingDate: json['nextSettingDate'] != null
          ? DateTime.parse(json['nextSettingDate'] as String)
          : null,
    );
  }

  /// Sector 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sectorName': name,
      if (settingDate != null) 'settingDate': settingDate!.toIso8601String().split('T')[0],
      if (nextSettingDate != null) 'nextSettingDate': nextSettingDate!.toIso8601String().split('T')[0],
    };
  }

  /// 세팅일 포맷팅
  String getSettingDateText() {
    if (settingDate == null) return '세팅 정보 없음';
    return '${settingDate!.year}.${settingDate!.month.toString().padLeft(2, '0')}.${settingDate!.day.toString().padLeft(2, '0')}';
  }

  /// 다음 세팅일 포맷팅
  String? getNextSettingDateText() {
    if (nextSettingDate == null) return null;
    return '${nextSettingDate!.year}.${nextSettingDate!.month.toString().padLeft(2, '0')}.${nextSettingDate!.day.toString().padLeft(2, '0')}';
  }

  /// 세팅 경과 일수
  int? getDaysSinceSetting() {
    if (settingDate == null) return null;
    return DateTime.now().difference(settingDate!).inDays;
  }
}