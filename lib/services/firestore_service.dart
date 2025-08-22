// lib/services/firestore_service.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/home_models.dart';
import '../models/rotina.dart';
import '../models/habito.dart';
import '../models/meta.dart';

/// Classe responsável por toda a comunicação com o Firestore.
class FirestoreService {
  // Instâncias do Firestore e do Auth para acesso ao banco de dados e ao usuário.
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Getter para obter o ID do usuário logado de forma segura.
  String? get _uid => _auth.currentUser?.uid;

  // --- MÉTODOS DA HOME SCREEN ---

  /// Retorna um Stream com os dados da HomeScreen, atualizando em tempo real.
  Stream<HomeScreenData> getHomeScreenDataStream() {
    if (_uid == null) {
      return Stream.error(Exception("Utilizador não autenticado."));
    }

    final userDocRef = _db.collection('users').doc(_uid);
    // StreamController combina múltiplos streams em um só.
    final controller = StreamController<HomeScreenData>();

    // Ouve mudanças no documento do usuário, na coleção de hábitos e no log de hábitos.
    final userSub = userDocRef.snapshots().listen(
      (_) => _updateHomeScreenData(controller, userDocRef),
    );
    final habitsSub = userDocRef
        .collection('habits')
        .snapshots()
        .listen((_) => _updateHomeScreenData(controller, userDocRef));
    final logSub = userDocRef
        .collection('habit_log')
        .snapshots()
        .listen((_) => _updateHomeScreenData(controller, userDocRef));

    // Inicia a primeira busca de dados.
    _updateHomeScreenData(controller, userDocRef);

    // Quando o stream não for mais ouvido, cancela os listeners para evitar vazamentos de memória.
    controller.onCancel = () {
      userSub.cancel();
      habitsSub.cancel();
      logSub.cancel();
    };

    return controller.stream;
  }

  /// Função auxiliar que busca e combina os dados para o stream da HomeScreen.
  Future<void> _updateHomeScreenData(
    StreamController<HomeScreenData> controller,
    DocumentReference userDocRef,
  ) async {
    try {
      final userDoc = await userDocRef.get();
      final userData = userDoc.data() as Map<String, dynamic>?;

      final userName =
          userData?['name'] as String? ??
          _auth.currentUser?.displayName ??
          'Utilizador';
      final currentStreak = userData?['currentStreak'] as int? ?? 0;

      final int todayAsInt = DateTime.now().weekday;
      final habitsSnapshot = await userDocRef.collection('habits').get();

      // Filtra os hábitos para pegar apenas os que são diários ou agendados para hoje.
      final dailyAndSpecificHabits = habitsSnapshot.docs.where((doc) {
        final data = doc.data();
        final type = data['frequencyType'];
        if (type == 'daily') return true;
        if (type == 'specificDays' && data['specificDays'] != null) {
          return (data['specificDays'] as List).contains(todayAsInt);
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

      // Envia os dados combinados para o stream.
      if (!controller.isClosed) {
        controller.add(
          HomeScreenData(
            userName: userName,
            todayHabits: todayHabits,
            currentStreak: currentStreak,
          ),
        );
      }
    } catch (e) {
      if (!controller.isClosed) {
        controller.addError(e);
      }
    }
  }

  // --- OUTROS MÉTODOS ---

  /// Busca apenas o nome do usuário uma única vez.
  Future<String> getUserName() async {
    if (_uid == null) return 'Utilizador';
    try {
      final userDoc = await _db.collection('users').doc(_uid).get();
      final data = userDoc.data();
      return data?['name'] ?? _auth.currentUser?.displayName ?? 'Utilizador';
    } catch (e) {
      return _auth.currentUser?.displayName ?? 'Utilizador';
    }
  }

  /// Atualiza o status de um hábito no log diário.
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

  /// Retorna um Stream com a lista de hábitos do usuário.
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

  /// Retorna um Future com a lista de hábitos (para buscas únicas).
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

  /// Adiciona ou atualiza um hábito no Firestore.
  Future<void> saveHabit(Habito habito) async {
    if (_uid == null) return;
    final docRef = _db
        .collection('users')
        .doc(_uid)
        .collection('habits')
        .doc(habito.id);
    await docRef.set(habito.toFirestore());
  }

  /// Exclui um hábito do Firestore.
  Future<void> deleteHabit(String habitId) async {
    if (_uid == null) return;
    await _db
        .collection('users')
        .doc(_uid)
        .collection('habits')
        .doc(habitId)
        .delete();
  }

  /// Busca o histórico de conclusão de um hábito específico.
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
          data['completedHabits'][habitId] != null) {
        history[doc.id] = data['completedHabits'][habitId];
      }
    }
    return history;
  }

  /// Retorna um Stream com a lista de rotinas do usuário.
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

  /// Adiciona ou atualiza uma rotina no Firestore.
  Future<void> saveRoutine(Rotina rotina) async {
    if (_uid == null) return;
    final docRef = _db
        .collection('users')
        .doc(_uid)
        .collection('routines')
        .doc(rotina.id);
    await docRef.set(rotina.toFirestore());
  }

  /// Exclui uma rotina do Firestore.
  Future<void> deleteRoutine(String rotinaId) async {
    if (_uid == null) return;
    await _db
        .collection('users')
        .doc(_uid)
        .collection('routines')
        .doc(rotinaId)
        .delete();
  }

  /// Retorna um Stream com a lista de metas do usuário.
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

  /// Adiciona ou atualiza uma meta no Firestore.
  Future<void> saveGoal(Meta meta) async {
    if (_uid == null) return;
    final docRef = _db
        .collection('users')
        .doc(_uid)
        .collection('goals')
        .doc(meta.id);
    await docRef.set(meta.toFirestore());
  }

  /// Exclui uma meta do Firestore.
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
