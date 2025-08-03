// lib/models/meta.dart
import 'package:uuid/uuid.dart';

class Meta {
  final String id;
  final String userId;
  String name;
  String? description;
  DateTime deadline;
  MetaStatus status;

  Meta({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.deadline,
    this.status = MetaStatus.emProgresso,
  });

  // Método para calcular os dias restantes
  int get daysLeft {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadlineDateOnly = DateTime(
      deadline.year,
      deadline.month,
      deadline.day,
    );
    return deadlineDateOnly.difference(today).inDays;
  }
}

enum MetaStatus { emProgresso, concluido, expirado }
