class Rotina {
  final String id;
  final String name;
  final String? description;
  final List<int> activeDays; // Dias da semana (1=Seg, 7=Dom)
  final List<String> habitIds; // IDs dos hábitos que compõem esta rotina

  Rotina({
    required this.id,
    required this.name,
    this.description,
    required this.activeDays,
    required this.habitIds,
  });

  /// Construtor para criar uma Rotina a partir de dados do Firestore.
  factory Rotina.fromFirestore(String id, Map<String, dynamic> data) {
    return Rotina(
      id: id,
      name: data['name'] ?? '',
      description: data['description'],
      activeDays: List<int>.from(data['activeDays'] ?? []),
      habitIds: List<String>.from(data['habitIds'] ?? []),
    );
  }

  /// Método para converter uma Rotina em um formato para salvar no Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'activeDays': activeDays,
      'habitIds': habitIds,
    };
  }
}
