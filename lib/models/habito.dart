// lib/models/habito.dart
import 'package:flutter/foundation.dart';

enum FrequencyType {
  daily, // Diário
  weeklyTimes, // X vezes por semana
  specificDays, // Dias específicos da semana
}

enum Turno {
  manha, // Manhã
  tarde, // Tarde
  noite, // Noite
}

class Habito {
  final String id; // ID único do hábito
  final String userId; // ID do usuário a quem o hábito pertence
  final String name; // Nome do hábito (ex: "Beber 2L de água")
  final String? description; // Descrição detalhada do hábito (opcional)
  final FrequencyType frequencyType; // Tipo de frequência
  final int? weeklyTarget; // Alvo semanal (ex: 3x por semana)
  final List<int>? specificDays; // Lista de dias da semana (1=Seg, 7=Dom)
  final Turno? preferredTurn; // Turno preferido para realizar o hábito

  Habito({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.frequencyType,
    this.weeklyTarget,
    this.specificDays,
    this.preferredTurn,
  });

  factory Habito.fromJson(Map<String, dynamic> json) {
    return Habito(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      description: json['description'],
      frequencyType: FrequencyType.values.firstWhere(
        (e) => e.toString() == 'FrequencyType.${json['frequencyType']}',
      ),
      weeklyTarget: json['weeklyTarget'],
      specificDays: json['specificDays'] != null
          ? List<int>.from(json['specificDays'])
          : null,
      preferredTurn: json['preferredTurn'] != null
          ? Turno.values.firstWhere(
              (e) => e.toString() == 'Turno.${json['preferredTurn']}',
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'frequencyType': frequencyType.toString().split('.').last,
      'weeklyTarget': weeklyTarget,
      'specificDays': specificDays,
      'preferredTurn': preferredTurn?.toString().split('.').last,
    };
  }

  Habito copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    FrequencyType? frequencyType,
    int? weeklyTarget,
    List<int>? specificDays,
    Turno? preferredTurn,
  }) {
    return Habito(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      frequencyType: frequencyType ?? this.frequencyType,
      weeklyTarget: weeklyTarget ?? this.weeklyTarget,
      specificDays: specificDays ?? this.specificDays,
      preferredTurn: preferredTurn ?? this.preferredTurn,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Habito &&
        other.id == id &&
        other.userId == userId &&
        other.name == name &&
        other.description == description &&
        other.frequencyType == frequencyType &&
        other.weeklyTarget == weeklyTarget &&
        _listEquals(other.specificDays, specificDays) &&
        other.preferredTurn == preferredTurn;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        name.hashCode ^
        description.hashCode ^
        frequencyType.hashCode ^
        weeklyTarget.hashCode ^
        _listHashCode(specificDays) ^
        preferredTurn.hashCode;
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
