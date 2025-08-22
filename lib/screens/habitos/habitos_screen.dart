// lib/screens/habitos/habitos_screen.dart

// --- IMPORTAÇÕES ---
import 'package:flutter/material.dart';
// Importa o modelo de dados para Hábito.
import 'package:health_routine_coach/models/habito.dart';
// Importa o serviço que se comunica com o Firestore.
import 'package:health_routine_coach/services/firestore_service.dart';
// Importa as telas de adicionar/editar e de detalhes do hábito.
import 'package:health_routine_coach/screens/habitos/add_edit_habito_screen.dart';
import 'package:health_routine_coach/screens/habitos/detalhe_habito_screen.dart';

// --- WIDGET DA TELA DE HÁBITOS ---
// StatefulWidget porque seu conteúdo (a lista de hábitos) pode mudar.
class HabitosScreen extends StatefulWidget {
  const HabitosScreen({super.key});

  @override
  State<HabitosScreen> createState() => _HabitosScreenState();
}

// --- CLASSE DE ESTADO DA TELA DE HÁBITOS ---
class _HabitosScreenState extends State<HabitosScreen> {
  // Instância do serviço que se comunica com o Firestore.
  final FirestoreService _firestoreService = FirestoreService();

  /// Converte os dados de frequência do hábito em um texto legível para a UI.
  String _getFrequencyText(Habito habito) {
    switch (habito.frequencyType) {
      case FrequencyType.daily:
        return 'Diário';
      case FrequencyType.weeklyTimes:
        return '${habito.weeklyTarget}x por semana';
      case FrequencyType.specificDays:
        if (habito.specificDays == null || habito.specificDays!.isEmpty) {
          return 'Dias específicos (nenhum selecionado)';
        }
        const Map<int, String> dayMap = {
          1: 'Seg',
          2: 'Ter',
          3: 'Qua',
          4: 'Qui',
          5: 'Sex',
          6: 'Sáb',
          7: 'Dom',
        };
        habito.specificDays!.sort();
        final days = habito.specificDays!
            .map((day) => dayMap[day] ?? '')
            .join(', ');
        return 'Dias: $days';
    }
  }

  // --- CONSTRUÇÃO DA INTERFACE ---
  @override
  Widget build(BuildContext context) {
    // Scaffold fornece a estrutura base da tela.
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        // Column organiza os widgets verticalmente.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título grande da página.
            const Padding(
              padding: EdgeInsets.only(top: 24.0, bottom: 16.0),
              child: Text(
                'Meus Hábitos',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            // Card que funciona como um botão para adicionar um novo hábito.
            Card(
              color: Colors.grey[200],
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  // Navega para a tela de adicionar/editar hábito.
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AddEditHabitoScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 20.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Adicione um novo hábito',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      const Icon(
                        Icons.add_circle,
                        color: Color(0xFF03A9F4),
                        size: 28,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Lista de hábitos que se atualiza em tempo real.
            Expanded(
              // StreamBuilder ouve as mudanças na coleção de hábitos do Firestore.
              child: StreamBuilder<List<Habito>>(
                stream: _firestoreService.getHabitsStream(),
                builder: (context, snapshot) {
                  // Enquanto os dados estão carregando.
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // Se ocorrer um erro.
                  if (snapshot.hasError) {
                    return Center(child: Text('Erro: ${snapshot.error}'));
                  }
                  // Se não houver dados (lista vazia).
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhum hábito cadastrado.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  // Se os dados foram carregados com sucesso.
                  final habitos = snapshot.data!;
                  // ListView.builder constrói a lista de forma eficiente.
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: habitos.length,
                    itemBuilder: (context, index) {
                      final habito = habitos[index];
                      // TODO: A lógica de progresso semanal precisa ser implementada.
                      final progress =
                          (habito.name.length % 5) * 0.2 +
                          0.1; // Valor de exemplo
                      return Card(
                        color: Colors.grey[200],
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            // Navega para a tela de detalhes do hábito selecionado.
                            Navigator.of(context).push<Habito>(
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetalheHabitoScreen(habito: habito),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        habito.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.info_outline,
                                      color: Colors.blueAccent,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Frequência: ${_getFrequencyText(habito)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Progresso Semanal',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        backgroundColor: Colors.grey[400],
                                        color: const Color(0xFF03A9F4),
                                        minHeight: 8,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${(progress * 100).toInt()}%',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
