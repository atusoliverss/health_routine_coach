// lib/models/rotina.dart

/// Representa a estrutura de uma Rotina, que é um agrupamento de hábitos.
class Rotina {
  // --- PROPRIEDADES ---
  final String id; // ID único da rotina.
  final String name; // Nome da rotina (ex: "Rotina Matinal").
  final String? description; // Descrição opcional.
  final List<int>
  activeDays; // Dias da semana em que a rotina está ativa (1=Seg, 7=Dom).
  final List<String>
  habitIds; // Lista de IDs dos hábitos que compõem esta rotina.

  // --- CONSTRUTOR ---
  Rotina({
    required this.id,
    required this.name,
    this.description,
    required this.activeDays,
    required this.habitIds,
  });

  // --- CONVERSÃO DE DADOS (FIRESTORE) ---

  /// Construtor factory para criar um objeto Rotina a partir de dados do Firestore.
  factory Rotina.fromFirestore(String id, Map<String, dynamic> data) {
    return Rotina(
      id: id,
      name: data['name'] ?? '',
      description: data['description'],
      activeDays: List<int>.from(data['activeDays'] ?? []),
      habitIds: List<String>.from(data['habitIds'] ?? []),
    );
  }

  /// Método para converter o objeto Rotina em um Map para salvar no Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'activeDays': activeDays,
      'habitIds': habitIds,
    };
  }
}
