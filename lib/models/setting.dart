/// 세팅 모델
class Setting {
  final int id;
  final int sectorId;
  final String sectorName;
  final String gymName;
  final DateTime settingDate;
  final DateTime? clearDate;
  final bool isActive;
  final int problemCount;
  final int clearUserCount;

  Setting({
    required this.id,
    required this.sectorId,
    required this.sectorName,
    required this.gymName,
    required this.settingDate,
    this.clearDate,
    required this.isActive,
    required this.problemCount,
    required this.clearUserCount,
  });
}