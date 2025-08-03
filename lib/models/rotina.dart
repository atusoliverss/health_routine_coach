// lib/models/rotina.dart
import 'package:flutter/foundation.dart';

class Rotina {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final List<int>
  activeDays; // Dias da semana em que a rotina está ativa (1=Seg, 7=Dom)
  final List<String> habitIds; // IDs dos hábitos que compõem esta rotina

  Rotina({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.activeDays,
    required this.habitIds,
  });

  factory Rotina.fromJson(Map<String, dynamic> json) {
    return Rotina(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      description: json['description'],
      activeDays: List<int>.from(json['activeDays']),
      habitIds: List<String>.from(json['habitIds']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'activeDays': activeDays,
      'habitIds': habitIds,
    };
  }

  Rotina copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    List<int>? activeDays,
    List<String>? habitIds,
  }) {
    return Rotina(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      activeDays: activeDays ?? this.activeDays,
      habitIds: habitIds ?? this.habitIds,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Rotina &&
        other.id == id &&
        other.userId == userId &&
        other.name == name &&
        other.description == description &&
        _listEquals(other.activeDays, activeDays) &&
        _listEquals(other.habitIds, habitIds);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        name.hashCode ^
        description.hashCode ^
        _listHashCode(activeDays) ^
        _listHashCode(habitIds);
  }

  static bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static int _listHashCode<T>(List<T>? list) {
    if (list == null) return 0;
    int hash = 0;
    for (final item in list) {
      hash = hash ^ item.hashCode;
    }
    return hash;
  }
}
