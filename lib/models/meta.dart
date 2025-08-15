import 'package:cloud_firestore/cloud_firestore.dart';

// Enum para o status da meta.
enum MetaStatus { emProgresso, concluido, expirado }

class Meta {
  final String id;
  String name;
  String? description;
  DateTime deadline;
  MetaStatus status;

  Meta({
    required this.id,
    required this.name,
    this.description,
    required this.deadline,
    this.status = MetaStatus.emProgresso,
  });

  /// Construtor para criar uma Meta a partir de dados do Firestore.
  factory Meta.fromFirestore(String id, Map<String, dynamic> data) {
    return Meta(
      id: id,
      name: data['name'] ?? '',
      description: data['description'],
      // Converte o Timestamp do Firestore para DateTime.
      deadline: (data['deadline'] as Timestamp).toDate(),
      status: MetaStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => MetaStatus.emProgresso,
      ),
    );
  }

  /// Método para converter uma Meta em um formato para salvar no Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'deadline': Timestamp.fromDate(
        deadline,
      ), // Converte DateTime para Timestamp.
      'status': status.name, // Salva o enum como string.
    };
  }

  // Método para calcular os dias restantes.
  int get daysLeft {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadlineDateOnly = DateTime(
      deadline.year,
      deadline.month,
      deadline.day,
    );
    final difference = deadlineDateOnly.difference(today).inDays;
    return difference < 0 ? 0 : difference;
  }
}
