import 'package:flutter/material.dart';

/// 암장 등록 요청 DTO
class GymCreateDTO {
  final String gymName;
  final String address;
  final String? gymType;
  final TimeOfDay? openAt;
  final TimeOfDay? closeAt;
  final TimeOfDay? weekendOpenAt;
  final TimeOfDay? weekendCloseAt;
  final String? memo;

  GymCreateDTO({
    required this.gymName,
    required this.address,
    this.gymType,
    this.openAt,
    this.closeAt,
    this.weekendOpenAt,
    this.weekendCloseAt,
    this.memo,
  });

  /// 유효성 검사
  String? validate() {
    if (gymName.trim().isEmpty) {
      return '암장 이름은 필수입니다.';
    }
    if (gymName.length < 2 || gymName.length > 20) {
      return '암장 이름은 2~20자 이내여야 합니다.';
    }
    if (address.trim().isEmpty) {
      return '주소는 필수입니다.';
    }
    if (address.length < 4 || address.length > 100) {
      return '주소를 정확하게 입력해주세요 (4~100자).';
    }
    return null;
  }

  /// JSON으로 변환 - String 형식 사용
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'gymName': gymName,
      'address': address,
    };

    // 선택 필드들은 null이 아닐 때만 추가
    if (gymType != null) {
      json['type'] = gymType;
    }
    if (openAt != null) {
      json['openAt'] = _timeOfDayToString(openAt!);
    }
    if (closeAt != null) {
      json['closeAt'] = _timeOfDayToString(closeAt!);
    }
    if (weekendOpenAt != null) {
      json['weekendOpenAt'] = _timeOfDayToString(weekendOpenAt!);
    }
    if (weekendCloseAt != null) {
      json['weekendCloseAt'] = _timeOfDayToString(weekendCloseAt!);
    }
    if (memo != null && memo!.isNotEmpty) {
      json['memo'] = memo;
    }

    return json;
  }

  /// TimeOfDay를 "HH:mm:ss" 문자열로 변환
  static String _timeOfDayToString(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';  // "12:20:00" 형식
  }
}