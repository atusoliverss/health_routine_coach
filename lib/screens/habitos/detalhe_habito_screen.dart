import 'package:flutter/material.dart';
import 'package:health_routine_coach/models/habito.dart';
import 'package:health_routine_coach/services/firestore_service.dart';
import 'package:health_routine_coach/screens/habitos/add_edit_habito_screen.dart';

class DetalheHabitoScreen extends StatefulWidget {
  final Habito habito;

  const DetalheHabitoScreen({super.key, required this.habito});

  @override
  State<DetalheHabitoScreen> createState() => _DetalheHabitoScreenState();
}

class _DetalheHabitoScreenState extends State<DetalheHabitoScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late Habito _currentHabito;

  @override
  void initState() {
    super.initState();
    _currentHabito = widget.habito;
  }

  String _getFrequencyText(Habito habito) {
    switch (habito.frequencyType) {
      case FrequencyType.daily:
        return 'Diário';
      case FrequencyType.weeklyTimes:
        return '${habito.weeklyTarget}x por semana';
      case FrequencyType.specificDays:
        const Map<int, String> dayNames = {
          1: 'Segunda',
          2: 'Terça',
          3: 'Quarta',
          4: 'Quinta',
          5: 'Sexta',
          6: 'Sábado',
          7: 'Domingo',
        };
        final days = habito.specificDays
            ?.map((day) => dayNames[day] ?? '')
            .join(', ');
        return 'Dias específicos (${days ?? ''})';
    }
  }

  String _getTurnoText(Turno? turno) {
    switch (turno) {
      case Turno.manha:
        return 'Manhã';
      case Turno.tarde:
        return 'Tarde';
      case Turno.noite:
        return 'Noite';
      default:
        return 'Não definido';
    }
  }

  Future<void> _confirmDelete() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Excluir Hábito?'),
          content: Text(
            'Você tem certeza que deseja excluir o hábito "${_currentHabito.name}"? Esta ação não poderá ser desfeita.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('CANCELAR'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('EXCLUIR'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _firestoreService.deleteHabit(_currentHabito.id);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_currentHabito.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'DETALHE DO HÁBITO',
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
                      'Nome: ${_currentHabito.name}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    if (_currentHabito.description != null &&
                        _currentHabito.description!.isNotEmpty)
                      Text(
                        'Descrição: ${_currentHabito.description}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    if (_currentHabito.description != null &&
                        _currentHabito.description!.isNotEmpty)
                      const SizedBox(height: 8),
                    Text(
                      'Frequência: ${_getFrequencyText(_currentHabito)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Turno Preferido: ${_getTurnoText(_currentHabito.preferredTurn)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
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
                    label: const Text('EXCLUIR'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final updatedHabito = await Navigator.of(context)
                          .push<Habito>(
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddEditHabitoScreen(habito: _currentHabito),
                            ),
                          );
                      if (updatedHabito != null && mounted) {
                        setState(() {
                          _currentHabito = updatedHabito;
                        });
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
