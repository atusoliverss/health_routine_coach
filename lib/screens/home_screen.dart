// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:health_routine_coach/models/home_models.dart';
import 'package:health_routine_coach/services/firestore_service.dart';

// Importa as telas das outras abas
import 'package:health_routine_coach/screens/habitos/habitos_screen.dart';
import 'package:health_routine_coach/screens/metas/metas_screen.dart';
import 'package:health_routine_coach/screens/rotinas/rotinas_screen.dart';
// Importa o nosso widget de AppBar personalizado da pasta de widgets.
import 'package:health_routine_coach/widgets/custom_app_bar.dart';
import 'package:health_routine_coach/widgets/home_tab_content.dart';

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
    // A busca de dados é iniciada apenas uma vez.
    _dataFuture = _firestoreService.fetchDataForHomeScreen();
  }

  @override
  Widget build(BuildContext context) {
    // O FutureBuilder gerencia os estados de carregamento, erro e sucesso.
    return FutureBuilder<HomeScreenData>(
      future: _dataFuture,
      builder: (context, snapshot) {
        // Enquanto os dados estão carregando, exibe um spinner.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Se ocorreu um erro na busca dos dados.
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text("Erro ao carregar dados: ${snapshot.error}"),
            ),
          );
        }

        // Quando os dados chegam com sucesso.
        if (snapshot.hasData) {
          final data = snapshot.data!;
          // Constrói a tela principal com os dados prontos.
          return _buildMainScaffold(data);
        }

        // Estado de fallback, caso algo inesperado aconteça.
        return const Scaffold(body: Center(child: Text("Algo deu errado.")));
      },
    );
  }

  /// Constrói a "casca" principal do aplicativo (Scaffold com AppBar e BottomNavigationBar).
  /// Este método é chamado apenas uma vez, quando os dados estão prontos.
  Widget _buildMainScaffold(HomeScreenData data) {
    // O estado do índice selecionado é gerenciado por este widget.
    int selectedIndex = 0;

    // Lista de telas para a navegação.
    final List<Widget> widgetOptions = <Widget>[
      HomeTabContent(
        todayHabits: data.todayHabits,
        currentStreak: data.currentStreak,
      ),
      const RotinasScreen(),
      const HabitosScreen(),
      const MetasScreen(),
    ];

    // O StatefulBuilder é uma forma eficiente de gerenciar o estado
    // apenas da BottomNavigationBar, sem precisar reconstruir toda a tela
    // e refazer a busca no Firestore a cada troca de aba.
    return StatefulBuilder(
      builder: (context, setScaffoldState) {
        return Scaffold(
          // Usa o widget de AppBar personalizado que criamos.
          appBar: CustomAppBar(userName: data.userName),
          // Exibe a tela correspondente ao índice selecionado.
          body: widgetOptions.elementAt(selectedIndex),
          // Barra de navegação inferior.
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
            currentIndex: selectedIndex,
            selectedItemColor: const Color(0xFF03A9F4),
            unselectedItemColor: Colors.grey,
            onTap: (index) {
              // Atualiza o estado do StatefulBuilder para trocar de aba.
              setScaffoldState(() {
                selectedIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
          ),
        );
      },
    );
  }
}
