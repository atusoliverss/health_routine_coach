// lib/models/habito.dart

/// Enum para definir o tipo de frequência de um hábito.
enum FrequencyType {
  daily, // Todos os dias.
  weeklyTimes, // Um número específico de vezes por semana.
  specificDays, // Em dias específicos da semana.
}

/// Enum para definir o turno preferido para um hábito.
enum Turno { manha, tarde, noite }

/// Representa a estrutura de um Hábito no aplicativo.
class Habito {
  // --- PROPRIEDADES ---
  final String id; // ID único do hábito, gerado automaticamente.
  final String name; // Nome do hábito (ex: "Beber 2L de água").
  final String? description; // Descrição opcional do hábito.
  final FrequencyType
  frequencyType; // O tipo de frequência (diário, semanal, etc.).
  final int? weeklyTarget; // Alvo de vezes por semana (usado com weeklyTimes).
  final List<int>?
  specificDays; // Dias da semana (1=Seg, 7=Dom) (usado com specificDays).
  final Turno? preferredTurn; // Turno preferido para o hábito.

  // --- CONSTRUTOR ---
  Habito({
    required this.id,
    required this.name,
    this.description,
    required this.frequencyType,
    this.weeklyTarget,
    this.specificDays,
    this.preferredTurn,
  });

  // --- CONVERSÃO DE DADOS (FIRESTORE) ---

  /// Construtor factory para criar um objeto Habito a partir de dados do Firestore.
  factory Habito.fromFirestore(String id, Map<String, dynamic> data) {
    return Habito(
      id: id,
      name: data['name'] ?? '',
      description: data['description'],
      // Converte a string salva no Firestore de volta para o tipo Enum.
      frequencyType: FrequencyType.values.firstWhere(
        (e) => e.name == data['frequencyType'],
        orElse: () => FrequencyType.daily, // Valor padrão em caso de erro.
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

  /// Método para converter o objeto Habito em um Map para salvar no Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'frequencyType':
          frequencyType.name, // Salva o enum como uma string (ex: 'daily').
      'weeklyTarget': weeklyTarget,
      'specificDays': specificDays,
      'preferredTurn': preferredTurn?.name, // Salva o enum como uma string.
    };
  }
}
