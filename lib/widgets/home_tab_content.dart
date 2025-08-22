// lib/widgets/home_tab_content.dart

// --- IMPORTAÇÕES ---
import 'package:flutter/material.dart';
// Pacote para formatação de datas.
import 'package:intl/intl.dart';
// Importa os modelos de dados e o serviço do Firestore.
import '../models/home_models.dart';
import '../services/firestore_service.dart';

// --- WIDGET DO CONTEÚDO DA ABA HOME ---
// StatefulWidget porque seu estado (progresso, hábitos marcados) pode mudar.
class HomeTabContent extends StatefulWidget {
  // Dados recebidos da HomeScreen.
  final List<HomeHabit> todayHabits;
  final int currentStreak;

  const HomeTabContent({
    super.key,
    required this.todayHabits,
    required this.currentStreak,
  });

  @override
  State<HomeTabContent> createState() => _HomeTabContentState();
}

// --- CLASSE DE ESTADO ---
class _HomeTabContentState extends State<HomeTabContent> {
  // --- ESTADO E SERVIÇOS ---
  late List<HomeHabit>
  _todayHabits; // Cópia local da lista de hábitos para manipulação.
  double _dailyProgress = 0.0; // Progresso do dia (0.0 a 1.0).
  String _dailyQuote = ''; // Frase de inspiração do dia.
  final FirestoreService _firestoreService =
      FirestoreService(); // Instância do serviço.

  // Lista de frases de inspiração.
  final List<String> _inspirationalQuotes = [
    "\"Acredite em você mesmo e tudo será possível.\"",
    "\"O sucesso é a soma de pequenos esforços repetidos dia após dia.\"",
    "\"O único lugar onde o sucesso vem antes do trabalho é no dicionário.\"",
    "\"Comece onde você está. Use o que você tem. Faça o que você pode.\"",
    "\"A persistência realiza o impossível.\"",
    "\"Não espere por oportunidades, crie-as.\"",
    "\"Sua saúde é um investimento, não uma despesa.\"",
    "\"Cuide do seu corpo. É o único lugar que você tem para viver.\"",
    "\"Um pequeno progresso a cada dia resulta em grandes resultados.\"",
    "\"A força não vem da capacidade física, mas de uma vontade indomável.\"",
  ];

  // --- CICLO DE VIDA ---
  @override
  void initState() {
    super.initState();
    // Inicializa o estado com os dados recebidos da HomeScreen.
    _todayHabits = widget.todayHabits;
    _loadDailyQuote();
    _updateProgress();
  }

  // --- MÉTODOS DE LÓGICA ---

  /// Seleciona uma citação da lista com base no dia do ano.
  void _loadDailyQuote() {
    final dayOfYear = int.parse(DateFormat("D").format(DateTime.now()));
    final quoteIndex = dayOfYear % _inspirationalQuotes.length;
    _dailyQuote = _inspirationalQuotes[quoteIndex];
  }

  /// Calcula e atualiza a barra de progresso.
  void _updateProgress() {
    int completed = _todayHabits.where((h) => h.isCompleted).length;
    int total = _todayHabits.length;
    setState(() {
      _dailyProgress = total > 0 ? completed / total : 0.0;
    });
  }

  // --- CONSTRUÇÃO DA INTERFACE ---
  @override
  Widget build(BuildContext context) {
    // SingleChildScrollView permite que a tela seja rolável.
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      // Column organiza os cards verticalmente.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Card de Progresso Diário ---
          Card(
            color: const Color(0xFFE0E0E0),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seu Progresso Hoje',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat(
                      'EEEE, dd \'de\' MMMM \'de\' yyyy',
                      'pt_BR',
                    ).format(DateTime.now()),
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  // Mostra a barra de progresso ou uma mensagem se não houver hábitos.
                  if (_todayHabits.isNotEmpty) ...[
                    LinearProgressIndicator(
                      value: _dailyProgress,
                      backgroundColor: Colors.grey[400],
                      color: const Color(0xFF03A9F4),
                      minHeight: 12,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Você já concluiu ${_todayHabits.where((h) => h.isCompleted).length} dos seus ${_todayHabits.length} hábitos de hoje!',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ] else ...[
                    const Text(
                      'Nenhum hábito para hoje. Adicione um na aba "Hábitos"!',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Exibe a sequência de dias.
                  Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Sua sequência atual: ${widget.currentStreak} dias!',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // --- Card de Hábitos de Hoje ---
          Card(
            color: const Color(0xFFE0E0E0),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hábitos de Hoje',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Se não houver hábitos, mostra uma mensagem.
                  if (_todayHabits.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(
                        child: Text(
                          'Nenhum hábito agendado para hoje!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    )
                  // Se houver hábitos, constrói a lista.
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _todayHabits.length,
                      itemBuilder: (context, index) {
                        final habit = _todayHabits[index];
                        // CheckboxListTile é um item de lista com uma caixa de seleção.
                        return CheckboxListTile(
                          title: Text(
                            habit.name,
                            style: TextStyle(
                              decoration: habit.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: habit.isCompleted
                                  ? Colors.black54
                                  : Colors.black87,
                            ),
                          ),
                          value: habit.isCompleted,
                          onChanged: (bool? newValue) {
                            // Atualiza o estado local e salva a mudança no Firestore.
                            setState(() {
                              habit.isCompleted = newValue!;
                              _updateProgress();
                            });
                            _firestoreService.updateHabitStatus(
                              habit.id,
                              newValue!,
                            );
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
          // --- Card de Inspiração do Dia ---
          Card(
            color: const Color(0xFFE0E0E0),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              width:
                  double.infinity, // Garante que o card ocupe toda a largura.
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Inspiração do Dia',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _dailyQuote,
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20), // Garante uma altura mínima.
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
