// lib/screens/habitos/habitos_screen.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:health_routine_coach/models/habito.dart';
import 'package:health_routine_coach/screens/habitos/add_edit_habito_screen.dart';
import 'package:health_routine_coach/screens/habitos/detalhe_habito_screen.dart';
import 'package:health_routine_coach/screens/rotinas/rotinas_screen.dart'; // Import para dummyRotinas

// Simulação de dados de hábitos (seriam substituídos por busca do Firebase)
List<Habito> dummyHabitos = [
  Habito(
    id: const Uuid().v4(),
    userId: 'user123',
    name: 'Beber 2L de água',
    description: 'Manter o corpo hidratado para energia.',
    frequencyType: FrequencyType.daily,
    preferredTurn: Turno.manha,
  ),
  Habito(
    id: const Uuid().v4(),
    userId: 'user123',
    name: 'Ler 15 páginas de um livro',
    description: 'Aprimorar conhecimento e relaxar.',
    frequencyType: FrequencyType.weeklyTimes,
    weeklyTarget: 3,
    preferredTurn: Turno.noite,
  ),
  Habito(
    id: const Uuid().v4(),
    userId: 'user123',
    name: 'Meditar por 10 min',
    description: 'Reduzir estresse e aumentar foco.',
    frequencyType: FrequencyType.daily,
    preferredTurn: Turno.manha,
  ),
  Habito(
    id: const Uuid().v4(),
    userId: 'user123',
    name: 'Fazer 30 min de exercício',
    description: 'Manter a forma física e liberar endorfinas.',
    frequencyType: FrequencyType.specificDays,
    specificDays: [1, 3, 5], // Seg, Qua, Sex
    preferredTurn: Turno.tarde,
  ),
];

class HabitosScreen extends StatefulWidget {
  const HabitosScreen({super.key});

  @override
  State<HabitosScreen> createState() => _HabitosScreenState();
}

class _HabitosScreenState extends State<HabitosScreen> {
  final Map<String, double> _simulatedWeeklyProgress = {
    dummyHabitos[0].id: 0.60, // Beber água: 60%
    dummyHabitos[1].id: 0.67, // Ler livro: 67% (2 de 3x)
    dummyHabitos[2].id: 0.57, // Meditar: 57%
    dummyHabitos[3].id: 0.75, // Exercício: 75%
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título e Botão Adicionar Novo Hábito
          GestureDetector(
            onTap: () async {
              final newHabito = await Navigator.of(context).push<Habito>(
                MaterialPageRoute(
                  builder: (context) => const AddEditHabitoScreen(),
                ),
              );
              if (newHabito != null) {
                setState(() {
                  dummyHabitos.add(newHabito);
                  _simulatedWeeklyProgress[newHabito.id] = 0.0;
                });
              }
            },
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Adicione um novo hábito',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    Icon(Icons.add_circle, color: Color(0xFF03A9F4), size: 28),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Meus Hábitos',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: dummyHabitos.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum hábito cadastrado ainda. Que tal adicionar um novo?',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: dummyHabitos.length,
                    itemBuilder: (context, index) {
                      final habito = dummyHabitos[index];
                      final progress =
                          _simulatedWeeklyProgress[habito.id] ?? 0.0;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        child: InkWell(
                          onTap: () async {
                            final updatedHabito = await Navigator.of(context)
                                .push<Habito>(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetalheHabitoScreen(habito: habito),
                                  ),
                                );
                            if (updatedHabito != null) {
                              setState(() {
                                final habitoIndex = dummyHabitos.indexWhere(
                                  (h) => h.id == updatedHabito.id,
                                );
                                if (habitoIndex != -1) {
                                  dummyHabitos[habitoIndex] = updatedHabito;
                                }
                              });
                            } else {
                              setState(() {
                                dummyHabitos.removeWhere(
                                  (h) => h.id == habito.id,
                                );
                                _simulatedWeeklyProgress.remove(habito.id);
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
                                const SizedBox(height: 4),
                                Text(
                                  'Frequência: ${_getFrequencyText(habito)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Progresso Semanal',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: Colors.grey[300],
                                  color: const Color(0xFF03A9F4),
                                  minHeight: 8,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    '${(progress * 100).toInt()}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
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

  String _getFrequencyText(Habito habito) {
    switch (habito.frequencyType) {
      case FrequencyType.daily:
        return 'Diário';
      case FrequencyType.weeklyTimes:
        return '${habito.weeklyTarget}x por semana';
      case FrequencyType.specificDays:
        final Map<int, String> dayMap = {
          1: 'Seg',
          2: 'Ter',
          3: 'Qua',
          4: 'Qui',
          5: 'Sex',
          6: 'Sáb',
          7: 'Dom',
        };
        final days = habito.specificDays
            ?.map((day) => dayMap[day] ?? '')
            .join(', ');
        return 'Dias específicos (${days ?? ''})';
    }
  }
}
