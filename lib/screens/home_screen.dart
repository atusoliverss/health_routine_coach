// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:health_routine_coach/models/home_models.dart';
import 'package:health_routine_coach/services/firestore_service.dart';
import 'package:health_routine_coach/widgets/custom_app_bar.dart';
import 'package:health_routine_coach/widgets/home_tab_content.dart';

// Importa as telas das outras abas
import 'package:health_routine_coach/screens/habitos/habitos_screen.dart';
import 'package:health_routine_coach/screens/metas/metas_screen.dart';
import 'package:health_routine_coach/screens/rotinas/rotinas_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<HomeScreenData> _dataFuture;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _dataFuture = _firestoreService.fetchDataForHomeScreen();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<HomeScreenData>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Erro ao carregar dados: ${snapshot.error}",
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        if (snapshot.hasData) {
          final data = snapshot.data!;
          // CORREÇÃO: Passa os dados para um novo widget que gerencia seu próprio estado de navegação.
          return _MainAppShell(data: data);
        }

        return const Scaffold(body: Center(child: Text("Algo deu errado.")));
      },
    );
  }
}

/// NOVO: Widget que representa a "casca" principal do app (AppBar + Body + BottomNav).
/// Ele é um StatefulWidget para gerenciar corretamente o `selectedIndex`.
class _MainAppShell extends StatefulWidget {
  final HomeScreenData data;

  const _MainAppShell({required this.data});

  @override
  State<_MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<_MainAppShell> {
  // CORREÇÃO: `selectedIndex` agora é uma variável de estado desta classe.
  // Isso garante que seu valor seja preservado durante a navegação.
  int _selectedIndex = 0;

  // A lista de telas (widgets) para cada aba.
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    // A lista é inicializada uma vez com os dados recebidos.
    _widgetOptions = <Widget>[
      HomeTabContent(
        todayHabits: widget.data.todayHabits,
        currentStreak: widget.data.currentStreak,
      ),
      const RotinasScreen(),
      const HabitosScreen(),
      const MetasScreen(),
    ];
  }

  /// Função para atualizar o índice da aba selecionada.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // A AppBar personalizada é construída com o nome de usuário correto.
      appBar: CustomAppBar(userName: widget.data.userName),
      // O corpo da tela muda de acordo com o `_selectedIndex`.
      body: _widgetOptions.elementAt(_selectedIndex),
      // A barra de navegação inferior.
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            activeIcon: Icon(Icons.list),
            label: 'ROTINAS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box_outlined),
            activeIcon: Icon(Icons.check_box),
            label: 'HÁBITOS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_outline),
            activeIcon: Icon(Icons.star),
            label: 'METAS',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF03A9F4),
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped, // Chama a função para trocar de aba.
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
