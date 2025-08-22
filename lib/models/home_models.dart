// lib/models/home_models.dart

/// Classe para agrupar todos os dados necessários para a tela principal (HomeScreen).
/// Isso simplifica a passagem de dados entre os widgets.
class HomeScreenData {
  final String userName;
  final List<HomeHabit> todayHabits;
  final int currentStreak;

  HomeScreenData({
    required this.userName,
    required this.todayHabits,
    required this.currentStreak,
  });
}

/// Classe para representar a estrutura simplificada de um hábito na tela principal.
class HomeHabit {
  final String id;
  final String name;
  bool isCompleted;

  HomeHabit({required this.id, required this.name, this.isCompleted = false});
}
