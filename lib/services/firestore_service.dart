import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/home_models.dart';
import '../models/rotina.dart';
import '../models/habito.dart';
import '../models/meta.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  Future<String> getUserName() async {
    if (_uid == null) return 'Usuário';
    try {
      final userDoc = await _db.collection('users').doc(_uid).get();
      return userDoc.data()?['name'] ??
          _auth.currentUser?.displayName ??
          'Usuário';
    } catch (e) {
      return _auth.currentUser?.displayName ?? 'Usuário';
    }
  }

  Future<HomeScreenData> fetchDataForHomeScreen() async {
    if (_uid == null) throw Exception("Usuário não autenticado.");

    try {
      final userDocRef = _db.collection('users').doc(_uid);
      final userDoc = await userDocRef.get();
      final userName =
          userDoc.data()?['name'] ??
          _auth.currentUser?.displayName ??
          'Usuário';
      final currentStreak = userDoc.data()?['currentStreak'] ?? 0;

      // CORREÇÃO: Busca hábitos de forma mais inteligente.
      // Pega o dia da semana como um número (Segunda=1, Domingo=7).
      final int todayAsInt = DateTime.now().weekday;

      // Faz uma consulta que pega hábitos que são diários OU que contêm o dia de hoje.
      final habitsSnapshot = await userDocRef
          .collection('habits')
          .where('frequencyType', whereIn: ['daily', 'specificDays'])
          .get();

      // Filtra os resultados no lado do cliente.
      final dailyAndSpecificHabits = habitsSnapshot.docs.where((doc) {
        final data = doc.data();
        if (data['frequencyType'] == 'daily') {
          return true; // Inclui todos os hábitos diários.
        }
        if (data['frequencyType'] == 'specificDays' &&
            data['specificDays'] != null) {
          return (data['specificDays'] as List).contains(
            todayAsInt,
          ); // Inclui se o dia de hoje estiver na lista.
        }
        return false;
      }).toList();

      final String todayDateKey = DateFormat(
        'yyyy-MM-dd',
      ).format(DateTime.now());
      final todayLogSnapshot = await userDocRef
          .collection('habit_log')
          .doc(todayDateKey)
          .get();

      final Map<String, dynamic> completedHabitsMap = todayLogSnapshot.exists
          ? (todayLogSnapshot.data()!['completedHabits'] ?? {})
          : {};

      final List<HomeHabit> todayHabits = dailyAndSpecificHabits.map((doc) {
        return HomeHabit(
          id: doc.id,
          name: doc.data()['name'] ?? 'Hábito sem nome',
          isCompleted: completedHabitsMap[doc.id] ?? false,
        );
      }).toList();

      return HomeScreenData(
        userName: userName,
        todayHabits: todayHabits,
        currentStreak: currentStreak,
      );
    } catch (e) {
      throw Exception("Falha ao carregar os dados: $e");
    }
  }

  Future<void> updateHabitStatus(String habitId, bool isCompleted) async {
    if (_uid == null) return;
    final String todayDateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final docRef = _db
        .collection('users')
        .doc(_uid)
        .collection('habit_log')
        .doc(todayDateKey);
    await docRef.set({
      'completedHabits': {habitId: isCompleted},
    }, SetOptions(merge: true));
  }

  Stream<List<Habito>> getHabitsStream() {
    if (_uid == null) return Stream.value([]);
    return _db
        .collection('users')
        .doc(_uid)
        .collection('habits')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Habito.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<List<Habito>> getHabitsOnce() async {
    if (_uid == null) return [];
    final snapshot = await _db
        .collection('users')
        .doc(_uid)
        .collection('habits')
        .get();
    return snapshot.docs
        .map((doc) => Habito.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  Future<void> saveHabit(Habito habito) async {
    if (_uid == null) return;
    final docRef = _db
        .collection('users')
        .doc(_uid)
        .collection('habits')
        .doc(habito.id);
    await docRef.set(habito.toFirestore());
  }

  Future<void> deleteHabit(String habitId) async {
    if (_uid == null) return;
    await _db
        .collection('users')
        .doc(_uid)
        .collection('habits')
        .doc(habitId)
        .delete();
  }

  Future<Map<String, bool>> getHabitHistory(String habitId) async {
    if (_uid == null) return {};

    final Map<String, bool> history = {};
    final snapshot = await _db
        .collection('users')
        .doc(_uid)
        .collection('habit_log')
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data.containsKey('completedHabits') &&
          data['completedHabits'].containsKey(habitId)) {
        history[doc.id] = data['completedHabits'][habitId];
      }
    }
    return history;
  }

  Stream<List<Rotina>> getRoutinesStream() {
    if (_uid == null) return Stream.value([]);
    return _db
        .collection('users')
        .doc(_uid)
        .collection('routines')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Rotina.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> saveRoutine(Rotina rotina) async {
    if (_uid == null) return;
    final docRef = _db
        .collection('users')
        .doc(_uid)
        .collection('routines')
        .doc(rotina.id);
    await docRef.set(rotina.toFirestore());
  }

  Future<void> deleteRoutine(String rotinaId) async {
    if (_uid == null) return;
    await _db
        .collection('users')
        .doc(_uid)
        .collection('routines')
        .doc(rotinaId)
        .delete();
  }

  Stream<List<Meta>> getGoalsStream() {
    if (_uid == null) return Stream.value([]);
    return _db
        .collection('users')
        .doc(_uid)
        .collection('goals')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Meta.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> saveGoal(Meta meta) async {
    if (_uid == null) return;
    final docRef = _db
        .collection('users')
        .doc(_uid)
        .collection('goals')
        .doc(meta.id);
    await docRef.set(meta.toFirestore());
  }

  Future<void> deleteGoal(String metaId) async {
    if (_uid == null) return;
    await _db
        .collection('users')
        .doc(_uid)
        .collection('goals')
        .doc(metaId)
        .delete();
  }
}
