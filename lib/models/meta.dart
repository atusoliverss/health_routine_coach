// lib/models/meta.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum para definir o status de uma meta.
enum MetaStatus { emProgresso, concluido, expirado }

/// Representa a estrutura de uma Meta no aplicativo.
class Meta {
  // --- PROPRIEDADES ---
  final String id; // ID único da meta.
  String name; // Nome da meta (ex: "Correr 5km").
  String? description; // Descrição opcional.
  DateTime deadline; // Prazo final para concluir a meta.
  MetaStatus status; // Status atual da meta.

  // --- CONSTRUTOR ---
  Meta({
    required this.id,
    required this.name,
    this.description,
    required this.deadline,
    this.status = MetaStatus.emProgresso,
  });

  // --- CONVERSÃO DE DADOS (FIRESTORE) ---

  /// Construtor factory para criar um objeto Meta a partir de dados do Firestore.
  factory Meta.fromFirestore(String id, Map<String, dynamic> data) {
    return Meta(
      id: id,
      name: data['name'] ?? '',
      description: data['description'],
      // Converte o Timestamp (formato de data do Firestore) para DateTime.
      deadline: (data['deadline'] as Timestamp).toDate(),
      status: MetaStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => MetaStatus.emProgresso,
      ),
    );
  }

  /// Método para converter o objeto Meta em um Map para salvar no Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      // Converte o DateTime do Dart para o formato Timestamp do Firestore.
      'deadline': Timestamp.fromDate(deadline),
      'status': status.name, // Salva o enum como uma string.
    };
  }

  // --- MÉTODOS AUXILIARES ---

  /// Calcula os dias restantes até o prazo final da meta.
  int get daysLeft {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadlineDateOnly = DateTime(
      deadline.year,
      deadline.month,
      deadline.day,
    );
    final difference = deadlineDateOnly.difference(today).inDays;
    // Retorna 0 se o prazo já passou.
    return difference < 0 ? 0 : difference;
  }
}
