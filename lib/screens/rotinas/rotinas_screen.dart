// lib/screens/rotinas/rotinas_screen.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; // Para gerar IDs únicos (apenas para dados simulados)

import 'package:health_routine_coach/models/habito.dart';
import 'package:health_routine_coach/models/rotina.dart';
import 'package:health_routine_coach/screens/habitos/habitos_screen.dart'; // Importa os hábitos para a simulação
import 'package:health_routine_coach/screens/rotinas/add_edit_rotina_screen.dart';
import 'package:health_routine_coach/screens/rotinas/detalhe_rotina_screen.dart';

// Simulação de dados (seria substituído por dados do Firebase)
List<Rotina> dummyRotinas = [
  Rotina(
    id: const Uuid().v4(),
    userId: 'user123',
    name: 'Rotina Matinal',
    description: 'Hábitos para começar bem o dia.',
    activeDays: [1, 2, 3, 4, 5], // Seg a Sex
    habitIds: ['hab1', 'hab2', 'hab3'], // IDs de exemplo
  ),
  Rotina(
    id: const Uuid().v4(),
    userId: 'user123',
    name: 'Rotina Noturna',
    description: 'Preparo para uma boa noite de sono.',
    activeDays: [1, 2, 3, 4, 5, 6, 7], // Todos os dias
    habitIds: ['hab4', 'hab5'],
  ),
  Rotina(
    id: const Uuid().v4(),
    userId: 'user123',
    name: 'Rotina de Fim de Semana',
    description: 'Atividades para o descanso.',
    activeDays: [6, 7], // Sáb e Dom
    habitIds: ['hab6', 'hab7', 'hab8'],
  ),
];

class RotinasScreen extends StatefulWidget {
  const RotinasScreen({super.key});

  @override
  State<RotinasScreen> createState() => _RotinasScreenState();
}

class _RotinasScreenState extends State<RotinasScreen> {
  // Converte números de dia para nomes curtos
  String _getDaysText(List<int> days) {
    if (days.length == 7) return 'Todos os dias';
    if (days.isEmpty) return 'Nenhum dia ativo';

    final Map<int, String> dayMap = {
      1: 'Seg',
      2: 'Ter',
      3: 'Qua',
      4: 'Qui',
      5: 'Sex',
      6: 'Sáb',
      7: 'Dom',
    };
    return days.map((day) => dayMap[day] ?? '').join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título e Botão Adicionar Nova Rotina
          GestureDetector(
            onTap: () async {
              // Navegar para a tela de adicionar/editar rotina em modo de adição
              final newRotina = await Navigator.of(context).push<Rotina>(
                MaterialPageRoute(
                  builder: (context) => const AddEditRotinaScreen(),
                ),
              );
              if (newRotina != null) {
                setState(() {
                  dummyRotinas.add(newRotina);
                  // Em um app real, aqui você chamaria um service para salvar no Firebase
                });
              }
            },
            child: Card(
              elevation: 0, // Sem sombra para parecer um botão
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1,
                ), // Borda cinza
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Adicione uma nova rotina',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    Icon(
                      Icons.add_circle,
                      color: Color(0xFF03A9F4),
                      size: 28,
                    ), // Ícone azul
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Minhas Rotinas',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: dummyRotinas.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhuma rotina cadastrada ainda. Que tal adicionar uma?',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: dummyRotinas.length,
                    itemBuilder: (context, index) {
                      final rotina = dummyRotinas[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        child: InkWell(
                          // InkWell para efeito de clique
                          onTap: () async {
                            // Navegar para a tela de detalhes da rotina
                            final updatedRotina = await Navigator.of(context)
                                .push<Rotina>(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetalheRotinaScreen(rotina: rotina),
                                  ),
                                );
                            if (updatedRotina != null) {
                              setState(() {
                                // Lógica para atualizar a rotina na lista após edição
                                final rotinaIndex = dummyRotinas.indexWhere(
                                  (r) => r.id == updatedRotina.id,
                                );
                                if (rotinaIndex != -1) {
                                  dummyRotinas[rotinaIndex] = updatedRotina;
                                }
                                // Em um app real, aqui você chamaria um service para atualizar no Firebase
                              });
                            } else {
                              // Se a rotina foi excluída, atualiza a lista
                              setState(() {
                                dummyRotinas.removeWhere(
                                  (r) => r.id == rotina.id,
                                );
                              });
                            }
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
                                    ), // Ícone de informação
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Ativa em: ${_getDaysText(rotina.activeDays)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${rotina.habitIds.length} Hábitos',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
