// lib/screens/rotinas/detalhe_rotina_screen.dart

import 'package:flutter/material.dart';
import 'package:health_routine_coach/models/habito.dart';
import 'package:health_routine_coach/models/rotina.dart';
import 'package:health_routine_coach/services/firestore_service.dart';
import 'package:health_routine_coach/screens/rotinas/add_edit_rotina_screen.dart';

class DetalheRotinaScreen extends StatefulWidget {
  final Rotina rotina;

  const DetalheRotinaScreen({super.key, required this.rotina});

  @override
  State<DetalheRotinaScreen> createState() => _DetalheRotinaScreenState();
}

class _DetalheRotinaScreenState extends State<DetalheRotinaScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late Rotina _currentRotina;
  late Future<List<Habito>> _habitsInRoutineFuture;

  @override
  void initState() {
    super.initState();
    _currentRotina = widget.rotina;
    _loadHabitDetails();
  }

  void _loadHabitDetails() {
    setState(() {
      _habitsInRoutineFuture = _firestoreService.getHabitsOnce().then(
        (allHabits) => allHabits
            .where((h) => _currentRotina.habitIds.contains(h.id))
            .toList(),
      );
    });
  }

  String _formatActiveDays(List<int> days) {
    if (days.length == 7) return 'Todos os dias';
    if (days.isEmpty) return 'Nenhum dia ativo';

    const Map<int, String> dayNames = {
      1: 'Seg',
      2: 'Ter',
      3: 'Qua',
      4: 'Qui',
      5: 'Sex',
      6: 'Sáb',
      7: 'Dom',
    };
    days.sort();
    return days.map((day) => dayNames[day] ?? '').join(', ');
  }

  Future<void> _confirmDelete() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('EXCLUIR ROTINA?'),
          content: Text(
            'Você tem certeza que deseja excluir a rotina "${_currentRotina.name}"? Esta ação não poderá ser desfeita.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('CANCELAR'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('EXCLUIR', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _firestoreService.deleteRoutine(_currentRotina.id);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_currentRotina.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'DETALHE DA ROTINA',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const Divider(height: 10, thickness: 1),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Título da rotina: ${_currentRotina.name}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    if (_currentRotina.description != null &&
                        _currentRotina.description!.isNotEmpty)
                      Text(
                        'Descrição: ${_currentRotina.description}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    if (_currentRotina.description != null &&
                        _currentRotina.description!.isNotEmpty)
                      const SizedBox(height: 8),
                    Text(
                      'Ativa em: ${_formatActiveDays(_currentRotina.activeDays)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total de Hábitos: ${_currentRotina.habitIds.length}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'HÁBITOS DA ROTINA',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const Divider(height: 10, thickness: 1),
            Expanded(
              child: FutureBuilder<List<Habito>>(
                future: _habitsInRoutineFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Erro ao carregar hábitos: ${snapshot.error}',
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhum hábito associado a esta rotina.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  final habitsInRoutine = snapshot.data!;
                  return Card(
                    child: ListView.builder(
                      itemCount: habitsInRoutine.length,
                      itemBuilder: (context, index) {
                        final habit = habitsInRoutine[index];
                        return ListTile(
                          leading: Icon(
                            Icons.check_circle_outline,
                            color: Theme.of(context).primaryColor,
                          ),
                          title: Text(
                            habit.name,
                            style: const TextStyle(fontSize: 16),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _confirmDelete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.delete),
                    label: const Text('EXCLUIR'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              AddEditRotinaScreen(rotina: _currentRotina),
                        ),
                      );
                      // Após voltar da edição, recarrega a tela de detalhes para refletir as mudanças.
                      // Isso é importante caso o nome da rotina ou os hábitos tenham mudado.
                      if (mounted) {
                        // Uma forma simples de recarregar é buscar a rotina atualizada do Firestore,
                        // mas por enquanto, vamos apenas recarregar os detalhes dos hábitos.
                        _loadHabitDetails();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF03A9F4),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.edit),
                    label: const Text('EDITAR'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
