// lib/screens/home_screen.dart

// --- IMPORTAÇÕES ---
import 'package:flutter/material.dart';
import 'package:health_routine_coach/models/home_models.dart';
import 'package:health_routine_coach/services/firestore_service.dart';
import 'package:health_routine_coach/widgets/custom_app_bar.dart';
import 'package:health_routine_coach/widgets/home_tab_content.dart';

// Importa as telas das outras abas.
import 'package:health_routine_coach/screens/habitos/habitos_screen.dart';
import 'package:health_routine_coach/screens/metas/metas_screen.dart';
import 'package:health_routine_coach/screens/rotinas/rotinas_screen.dart';

// --- WIDGET "PAI" DA TELA HOME ---
// Este widget é responsável por iniciar a busca de dados.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Um Stream que irá "transmitir" os dados da tela principal em tempo real.
  late Stream<HomeScreenData> _dataStream;
  // Instância do serviço que se comunica com o Firestore.
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    // Inicia a "escuta" dos dados do Firestore assim que a tela é criada.
    _dataStream = _firestoreService.getHomeScreenDataStream();
  }

  @override
  Widget build(BuildContext context) {
    // StreamBuilder constrói a UI com base nos dados recebidos do Stream.
    return StreamBuilder<HomeScreenData>(
      stream: _dataStream,
      builder: (context, snapshot) {
        // Enquanto os dados estão carregando pela primeira vez.
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // Se ocorrer um erro na busca dos dados.
        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text("Erro: ${snapshot.error}")));
        }
        // Se não houver dados (estado inicial antes do primeiro evento).
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: Text("Carregando...")));
        }

        // Se os dados foram recebidos com sucesso.
        final data = snapshot.data!;
        // Constrói a "casca" principal do app com os dados mais recentes.
        return _MainAppShell(data: data);
      },
    );
  }
}

// --- WIDGET "CASCA" PRINCIPAL DO APP ---
// Este widget gerencia a AppBar, o corpo (abas) e a barra de navegação.
class _MainAppShell extends StatefulWidget {
  final HomeScreenData data;

  const _MainAppShell({required this.data});

  @override
  State<_MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<_MainAppShell> {
  // Variável de estado para controlar qual aba está selecionada.
  int _selectedIndex = 0;
  // Lista de widgets que representam o conteúdo de cada aba.
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    // Constrói a lista de abas quando o widget é criado pela primeira vez.
    _buildWidgetOptions();
  }

  @override
  // Este método é chamado quando os dados recebidos do widget pai (StreamBuilder) mudam.
  void didUpdateWidget(covariant _MainAppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Se os dados mudaram (ex: um novo hábito foi adicionado),
    // reconstrói a lista de widgets para atualizar a aba Home.
    if (widget.data != oldWidget.data) {
      _buildWidgetOptions();
    }
  }

  /// Constrói ou reconstrói a lista de widgets para as abas.
  void _buildWidgetOptions() {
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

  /// Função chamada quando um item da barra de navegação é tocado.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usa o widget de AppBar personalizado, passando o nome do usuário.
      appBar: CustomAppBar(userName: widget.data.userName),
      // Exibe o conteúdo da aba selecionada.
      body: _widgetOptions.elementAt(_selectedIndex),
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
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF03A9F4),
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
