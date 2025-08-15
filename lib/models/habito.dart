// lib/models/habito.dart

// Enum para o tipo de frequência do hábito.
enum FrequencyType { daily, weeklyTimes, specificDays }

// Enum para o turno preferido do hábito.
enum Turno { manha, tarde, noite }

class Habito {
  final String id;
  final String name;
  final String? description;
  final FrequencyType frequencyType;
  final int? weeklyTarget; // Apenas para weeklyTimes
  final List<int>? specificDays; // Apenas para specificDays (1=Seg, 7=Dom)
  final Turno? preferredTurn;

  Habito({
    required this.id,
    required this.name,
    this.description,
    required this.frequencyType,
    this.weeklyTarget,
    this.specificDays,
    this.preferredTurn,
  });

  /// Construtor para criar um Habito a partir de dados do Firestore.
  factory Habito.fromFirestore(String id, Map<String, dynamic> data) {
    return Habito(
      id: id,
      name: data['name'] ?? '',
      description: data['description'],
      frequencyType: FrequencyType.values.firstWhere(
        (e) => e.name == data['frequencyType'],
        orElse: () => FrequencyType.daily,
      ),
      weeklyTarget: data['weeklyTarget'],
      specificDays: data['specificDays'] != null
          ? List<int>.from(data['specificDays'])
          : null,
      preferredTurn: data['preferredTurn'] != null
          ? Turno.values.firstWhere((e) => e.name == data['preferredTurn'])
          : null,
    );
  }

  /// Método para converter um Habito em um formato para salvar no Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'frequencyType': frequencyType.name, // Salva o enum como string
      'weeklyTarget': weeklyTarget,
      'specificDays': specificDays,
      'preferredTurn': preferredTurn?.name, // Salva o enum como string
    };
  }
}
