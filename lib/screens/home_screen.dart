// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'package:health_routine_coach/screens/habitos/habitos_screen.dart';
import 'package:health_routine_coach/screens/metas/metas_screen.dart';
import 'package:health_routine_coach/screens/rotinas/rotinas_screen.dart';
// NOVO: Importe a tela de usuário
import 'package:health_routine_coach/screens/user_screen.dart';

// Este arquivo agora gerencia toda a navegação principal do app
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Controla o índice do item selecionado na navegação inferior

  // Conteúdo de cada aba
  static final List<Widget> _widgetOptions = <Widget>[
    const _HomeTabContent(), // O conteúdo da aba HOME
    const RotinasScreen(),
    const HabitosScreen(),
    const MetasScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _getCurrentTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Olá, ${FirebaseAuth.instance.currentUser?.displayName?.split(' ').first ?? 'Usuário'}!';
      case 1:
        return 'Minhas Rotinas';
      case 2:
        return 'Meus Hábitos';
      case 3:
        return 'Minhas Metas';
      default:
        return 'Health Routine Coach';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getCurrentTitle(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          // AÇÃO ADICIONADA AQUI: Ao clicar no ícone de perfil, navega para a UserScreen
          IconButton(
            icon: const Icon(Icons.account_circle, size: 30),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const UserScreen()),
              );
            },
          ),
          const SizedBox(width: 8), // Espaçamento
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
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
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}


// --- Conteúdo da Aba HOME (Agora um widget separado) ---
class _HomeTabContent extends StatefulWidget {
  const _HomeTabContent({Key? key}) : super(key: key);

  @override
  State<_HomeTabContent> createState() => _HomeTabContentState();
}

class _HomeTabContentState extends State<_HomeTabContent> {
  double dailyProgress = 0.60;
  int completedHabits = 3;
  int totalHabits = 5;
  int currentStreak = 7;

  List<HomeHabit> todayHabits = [
    HomeHabit(name: 'Beber 2L de água', isCompleted: true),
    HomeHabit(name: 'Fazer 30 min de exercício', isCompleted: true),
    HomeHabit(name: 'Ler 15 páginas de um livro', isCompleted: false),
    HomeHabit(name: 'Meditar por 10 min', isCompleted: true),
    HomeHabit(name: 'Preparar refeições para amanhã', isCompleted: false),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: const Color(0xFFE0E0E0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seu Progresso Hoje',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, dd \'de\' MMMM \'de\' yyyy', 'pt_BR').format(DateTime.now()),
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: dailyProgress,
                    backgroundColor: Colors.grey[400],
                    color: const Color(0xFF03A9F4),
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Você já concluiu $completedHabits dos seus $totalHabits hábitos de hoje!',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Continue assim! Quase lá!',
                    style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        'Sua maior sequência de dias saudáveis: $currentStreak dias!',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            color: const Color(0xFFE0E0E0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hábitos de Hoje',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: todayHabits.length,
                    itemBuilder: (context, index) {
                      final habit = todayHabits[index];
                      return CheckboxListTile(
                        title: Text(
                          habit.name,
                          style: TextStyle(
                            decoration: habit.isCompleted ? TextDecoration.lineThrough : null,
                            color: habit.isCompleted ? Colors.black54 : Colors.black87,
                          ),
                        ),
                        value: habit.isCompleted,
                        onChanged: (bool? newValue) {
                          setState(() {
                            habit.isCompleted = newValue!;
                            completedHabits = todayHabits.where((h) => h.isCompleted).length;
                            totalHabits = todayHabits.length;
                            dailyProgress = totalHabits > 0 ? completedHabits / totalHabits : 0.0;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        checkColor: Colors.white,
                        activeColor: const Color(0xFF12855B),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            color: const Color(0xFFE0E0E0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Inspiração do Dia',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "\"O caminho para a saúde começa com um único passo.\"",
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeHabit {
  final String name;
  bool isCompleted;

  HomeHabit({required this.name, this.isCompleted = false});
}