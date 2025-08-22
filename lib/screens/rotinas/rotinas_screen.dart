// lib/screens/rotinas/rotinas_screen.dart

// --- IMPORTAÇÕES ---
import 'package:flutter/material.dart';
// Importa o modelo de dados para Rotina.
import 'package:health_routine_coach/models/rotina.dart';
// Importa o serviço que se comunica com o Firestore.
import 'package:health_routine_coach/services/firestore_service.dart';
// Importa as telas de adicionar/editar e de detalhes da rotina.
import 'package:health_routine_coach/screens/rotinas/add_edit_rotina_screen.dart';
import 'package:health_routine_coach/screens/rotinas/detalhe_rotina_screen.dart';

// --- WIDGET DA TELA DE ROTINAS ---
// StatefulWidget porque seu conteúdo (a lista de rotinas) pode mudar.
class RotinasScreen extends StatefulWidget {
  const RotinasScreen({super.key});

  @override
  State<RotinasScreen> createState() => _RotinasScreenState();
}

// --- CLASSE DE ESTADO DA TELA DE ROTINAS ---
class _RotinasScreenState extends State<RotinasScreen> {
  // Instância do serviço que se comunica com o Firestore.
  final FirestoreService _firestoreService = FirestoreService();

  /// Converte a lista de números de dias da semana para um texto legível para a UI.
  String _getDaysText(List<int> days) {
    if (days.length == 7) return 'Todos os dias';
    if (days.isEmpty) return 'Nenhum dia ativo';

    const Map<int, String> dayMap = {
      1: 'Seg',
      2: 'Ter',
      3: 'Qua',
      4: 'Qui',
      5: 'Sex',
      6: 'Sáb',
      7: 'Dom',
    };
    // Ordena os dias para uma exibição consistente (ex: Seg, Ter, Qua).
    days.sort();
    return days.map((day) => dayMap[day] ?? '').join(', ');
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
                'Minhas Rotinas',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            // Card que funciona como um botão para adicionar uma nova rotina.
            Card(
              color: Colors.grey[200],
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  // Navega para a tela de adicionar/editar rotina.
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AddEditRotinaScreen(),
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
                        'Adicione uma nova rotina',
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

            // Lista de rotinas que se atualiza em tempo real.
            Expanded(
              // StreamBuilder ouve as mudanças na coleção de rotinas do Firestore.
              child: StreamBuilder<List<Rotina>>(
                stream: _firestoreService.getRoutinesStream(),
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
                        'Nenhuma rotina cadastrada.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  // Se os dados foram carregados com sucesso.
                  final rotinas = snapshot.data!;
                  // ListView.builder constrói a lista de forma eficiente.
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: rotinas.length,
                    itemBuilder: (context, index) {
                      final rotina = rotinas[index];
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
                            // Navega para a tela de detalhes da rotina selecionada.
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetalheRotinaScreen(rotina: rotina),
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
                                    Text(
                                      rotina.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
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
                                  'Ativa em: ${_getDaysText(rotina.activeDays)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${rotina.habitIds.length} Hábitos',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
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
