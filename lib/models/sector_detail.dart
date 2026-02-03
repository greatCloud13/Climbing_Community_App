import 'setting.dart';

/// 섹터 상세 정보 모델 (세팅 이력 포함)
class SectorDetail {
  final int id;
  final String gymName;
  final String sectorName;
  final DateTime? settingDate;
  final DateTime? nextSettingDate;
  final List<Setting> settingList;

  SectorDetail({
    required this.id,
    required this.gymName,
    required this.sectorName,
    this.settingDate,
    this.nextSettingDate,
    this.settingList = const [],
  });

  /// JSON을 SectorDetail 객체로 변환
  factory SectorDetail.fromJson(Map<String, dynamic> json) {
    List<Setting> settings = [];
    if (json['settingList'] != null) {
      settings = (json['settingList'] as List)
          .map((settingJson) => Setting.fromJson(settingJson as Map<String, dynamic>))
          .toList();
    }

    return SectorDetail(
      id: json['id'] as int,
      gymName: json['gymName'] as String,
      sectorName: json['sectorName'] as String,
      settingDate: json['settingDate'] != null
          ? DateTime.parse(json['settingDate'] as String)
          : null,
      nextSettingDate: json['nextSettingDate'] != null
          ? DateTime.parse(json['nextSettingDate'] as String)
          : null,
      settingList: settings,
    );
  }

  /// 현재 활성 세팅
  Setting? get currentSetting {
    try {
      return settingList.firstWhere((setting) => setting.isActive);
    } catch (e) {
      return null;
    }
  }

  /// 세팅 이력 개수
  int get settingCount => settingList.length;
}