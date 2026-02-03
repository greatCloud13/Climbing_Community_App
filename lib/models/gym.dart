import 'package:flutter/material.dart';
import 'sector.dart';

/// 암장 모델
class Gym {
  final int? id;
  final String name;
  final String? gymType;
  final String location;
  final TimeOfDay? openAt;
  final TimeOfDay? closeAt;
  final TimeOfDay? weekendOpenAt;
  final TimeOfDay? weekendCloseAt;
  final bool isActive;
  final String? memo;
  final String? imageUrl;
  final bool isSubscribed;
  final List<Sector> sectorList;

  Gym({
    this.id,
    required this.name,
    this.gymType,
    required this.location,
    this.openAt,
    this.closeAt,
    this.weekendOpenAt,
    this.weekendCloseAt,
    this.isActive = true,
    this.memo,
    this.imageUrl,
    this.isSubscribed = false,
    this.sectorList = const [],
  });

  /// JSON을 Gym 객체로 변환
  factory Gym.fromJson(Map<String, dynamic> json) {
    List<Sector> sectors = [];
    if (json['sectorList'] != null) {
      sectors = (json['sectorList'] as List)
          .map((sectorJson) => Sector.fromJson(sectorJson as Map<String, dynamic>))
          .toList();
    }

    return Gym(
      id: json['id'] as int?,
      name: json['gymName'] as String,
      gymType: json['gymType'] as String?,
      location: json['address'] as String,
      openAt: _parseTimeOfDay(json['openAt']),
      closeAt: _parseTimeOfDay(json['closeAt']),
      weekendOpenAt: _parseTimeOfDay(json['weekendOpenAt']),
      weekendCloseAt: _parseTimeOfDay(json['weekendCloseAt']),
      isActive: json['isActive'] == true || json['isActive'] == 'true',
      memo: json['memo'] as String?,
      isSubscribed: json['isSubscribed'] == true || json['isSubscribed'] == 'true',
      sectorList: sectors,
    );
  }

  /// 주말 영업 여부
  bool get hasWeekendHours => weekendOpenAt != null && weekendCloseAt != null;

  /// 영업 시간 텍스트
  String getOperatingHours() {
    if (openAt == null || closeAt == null) {
      return '영업 시간 미정';
    }

    final weekday = '평일: ${_formatTime(openAt!)} - ${_formatTime(closeAt!)}';

    if (hasWeekendHours) {
      final weekend = '주말: ${_formatTime(weekendOpenAt!)} - ${_formatTime(weekendCloseAt!)}';
      return '$weekday\n$weekend';
    } else {
      return '$weekday\n주말: 휴무';
    }
  }

  /// 암장 타입 한글 변환
  String getGymTypeText() {
    switch (gymType) {
      case 'BOULDER':
        return '볼더링';
      case 'LEAD':
        return '리드';
      case 'BOTH':
        return '볼더링 + 리드';
      default:
        return '미정';
    }
  }

  /// Gym 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'gymName': name,
      if (gymType != null) 'gymType': gymType,
      'address': location,
      if (openAt != null) 'openAt': _timeOfDayToString(openAt!),
      if (closeAt != null) 'closeAt': _timeOfDayToString(closeAt!),
      if (weekendOpenAt != null) 'weekendOpenAt': _timeOfDayToString(weekendOpenAt!),
      if (weekendCloseAt != null) 'weekendCloseAt': _timeOfDayToString(weekendCloseAt!),
      'isActive': isActive,
      if (memo != null) 'memo': memo,
      'sectorList': sectorList.map((sector) => sector.toJson()).toList(),
    };
  }

  /// String을 TimeOfDay로 변환
  static TimeOfDay? _parseTimeOfDay(dynamic value) {
    if (value == null) return null;

    try {
      if (value is String) {
        final parts = value.split(':');
        if (parts.length >= 2) {
          return TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
      }
      return null;
    } catch (e) {
      print('TimeOfDay 파싱 에러: $e, value: $value');
      return null;
    }
  }

  /// TimeOfDay를 String으로 변환
  static String _timeOfDayToString(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  /// TimeOfDay 포맷팅
  static String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}