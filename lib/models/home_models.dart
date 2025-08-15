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

class HomeHabit {
  final String id;
  final String name;
  bool isCompleted;

  HomeHabit({required this.id, required this.name, this.isCompleted = false});
}
