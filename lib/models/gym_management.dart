/// 암장 관리 모델
class GymManagement {
  final int id;
  final String name;
  final String location;
  final String managerName;
  final int memberCount;
  final int activeSectors;
  final bool isActive;
  final DateTime createdAt;

  GymManagement({
    required this.id,
    required this.name,
    required this.location,
    required this.managerName,
    required this.memberCount,
    required this.activeSectors,
    required this.isActive,
    required this.createdAt,
  });
}