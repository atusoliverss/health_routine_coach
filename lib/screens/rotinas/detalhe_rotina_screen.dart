// lib/screens/rotinas/detalhe_rotina_screen.dart
import 'package:flutter/material.dart';
import 'package:health_routine_coach/models/habito.dart';
import 'package:health_routine_coach/models/rotina.dart';
import 'package:health_routine_coach/screens/habitos/habitos_screen.dart'; // Import para a lista de dummyHabitos
import 'package:health_routine_coach/screens/rotinas/add_edit_rotina_screen.dart';

class DetalheRotinaScreen extends StatefulWidget {
  final Rotina rotina;

  const DetalheRotinaScreen({super.key, required this.rotina});

  @override
  State<DetalheRotinaScreen> createState() => _DetalheRotinaScreenState();
}

class _DetalheRotinaScreenState extends State<DetalheRotinaScreen> {
  late Rotina _currentRotina;

  @override
  void initState() {
    super.initState();
    _currentRotina = widget.rotina;
  }

  String _formatActiveDays(List<int> days) {
    if (days.length == 7) return 'Todos os dias';
    if (days.isEmpty) return 'Nenhum dia ativo';

    final Map<int, String> dayNames = {
      1: 'Seg',
      2: 'Ter',
      3: 'Qua',
      4: 'Qui',
      5: 'Sex',
      6: 'Sáb',
      7: 'Dom',
    };
    return days.map((day) => dayNames[day] ?? '').join(', ');
  }

  Future<void> _confirmDelete() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text('EXCLUIR ROTINA?')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Você tem certeza que deseja excluir a rotina "${_currentRotina.name}" ?',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Esta ação não poderá ser desfeita',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.red),
              ),
            ],
          ),
          actions: <Widget>[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(false),
                icon: const Icon(
                  Icons.add,
                ), // Ícone de mais para cancelar (pode ser confuso, um ícone de voltar seria mais padrão)
                label: const Text('CANCELAR'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF03A9F4),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(true),
                icon: const Icon(Icons.delete),
                label: const Text('EXCLUIR'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      // Lógica para excluir a rotina do Firebase
      if (mounted) {
        Navigator.of(context).pop(null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Habito> habitsInRoutine = dummyHabitos
        .where((h) => _currentRotina.habitIds.contains(h.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentRotina.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(_currentRotina);
          },
        ),
      ),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
              child: habitsInRoutine.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhum hábito associado a esta rotina.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListView.builder(
                          itemCount: habitsInRoutine.length,
                          itemBuilder: (context, index) {
                            final habit = habitsInRoutine[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: Text(
                                '• ${habit.name}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _confirmDelete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.delete),
                    label: const Text('EXCLUIR ROTINA'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final updatedRotina = await Navigator.of(context)
                          .push<Rotina>(
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddEditRotinaScreen(rotina: _currentRotina),
                            ),
                          );
                      if (updatedRotina != null) {
                        setState(() {
                          _currentRotina = updatedRotina;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF03A9F4),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.edit),
                    label: const Text('EDITAR ROTINA'),
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
