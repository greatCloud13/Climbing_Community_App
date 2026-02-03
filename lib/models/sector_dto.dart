/// 섹터 생성 DTO
class SectorCreateDTO {
  final int gymId;
  final String sectorName;

  SectorCreateDTO({
    required this.gymId,
    required this.sectorName,
  });

  Map<String, dynamic> toJson() {
    return {
      'gymId': gymId,
      'sectorName': sectorName,
    };
  }
}

/// 섹터 수정 DTO
class SectorUpdateDTO {
  final String? sectorName;
  final DateTime? settingDate;
  final DateTime? nextSettingDate;

  SectorUpdateDTO({
    this.sectorName,
    this.settingDate,
    this.nextSettingDate,
  });

  Map<String, dynamic> toJson() {
    return {
      if (sectorName != null) 'sectorName': sectorName,
      if (settingDate != null) 'settingDate': settingDate!.toIso8601String().split('T')[0],
      if (nextSettingDate != null) 'nextSettingDate': nextSettingDate!.toIso8601String().split('T')[0],
    };
  }
}