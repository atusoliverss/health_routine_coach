// lib/services/firestore_service.dart

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

  // --- MÉTODO PARA BUSCAR APENAS O NOME DO USUÁRIO ---
  /// Busca apenas o nome do usuário logado no Firestore.
  Future<String> getUserName() async {
    if (_uid == null) return 'Usuário';
    try {
      final userDoc = await _db.collection('users').doc(_uid).get();
      // Retorna o nome do documento ou o displayName do Auth como fallback.
      return userDoc.data()?['name'] ??
          _auth.currentUser?.displayName ??
          'Usuário';
    } catch (e) {
      // Em caso de erro, usa o displayName do Auth como fallback final.
      return _auth.currentUser?.displayName ?? 'Usuário';
    }
  }

  // --- MÉTODOS DA HOME SCREEN ---
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

      final String todayDayOfWeek = DateFormat(
        'EEEE',
      ).format(DateTime.now()).toLowerCase();

      final habitsSnapshot = await userDocRef
          .collection('habits')
          .where('daysOfWeek', arrayContains: todayDayOfWeek)
          .get();

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

      final List<HomeHabit> todayHabits = habitsSnapshot.docs.map((doc) {
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

  // --- MÉTODOS PARA HÁBITOS (CRUD) ---

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

  // --- MÉTODOS PARA ROTINAS (CRUD) ---

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

  // --- MÉTODOS PARA METAS (CRUD) ---

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
