/// 암장 모델
class Gym {
  final int id;
  final String name;
  final String location;
  final String? imageUrl;
  final bool isSubscribed;

  Gym({
    required this.id,
    required this.name,
    required this.location,
    this.imageUrl,
    this.isSubscribed = false,
  });
}