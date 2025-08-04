// lib/screens/habitos/detalhe_habito_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:health_routine_coach/models/habito.dart';
import 'package:health_routine_coach/screens/habitos/add_edit_habito_screen.dart';

class DetalheHabitoScreen extends StatefulWidget {
  final Habito habito;

  const DetalheHabitoScreen({super.key, required this.habito});

  @override
  State<DetalheHabitoScreen> createState() => _DetalheHabitoScreenState();
}

class _DetalheHabitoScreenState extends State<DetalheHabitoScreen> {
  late Habito _currentHabito;

  final Map<String, String> _simulatedHistory = {
    '22/07/2025': 'Concluído',
    '23/07/2025': 'Concluído',
    '24/07/2025': 'Em progresso',
    '25/07/2025': 'Pendente',
    '26/07/2025': 'Pendente',
  };

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
        final Map<int, String> dayNames = {
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
              child: const Text('EXCLUIR PERMANENTEMENTE'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      if (mounted) {
        Navigator.of(context).pop(null);
      }
    }
  }

  void _markAsComplete() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Hábito "${_currentHabito.name}" marcado como concluído!',
        ),
        backgroundColor: Colors.green,
      ),
    );
    // Lógica para marcar o hábito como concluído no Firebase ou no estado do app
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentHabito.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(_currentHabito);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 20),
            const Text(
              'HISTÓRICO DE CONCLUSÃO',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const Divider(height: 10, thickness: 1),
            Expanded(
              child: Card(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _simulatedHistory.length,
                  itemBuilder: (context, index) {
                    final date = _simulatedHistory.keys.elementAt(index);
                    final status = _simulatedHistory.values.elementAt(index);
                    Color statusColor;
                    switch (status) {
                      case 'Concluído':
                        statusColor = Colors.green;
                        break;
                      case 'Em progresso':
                        statusColor = Colors.orange;
                        break;
                      case 'Pendente':
                        statusColor = Colors.red;
                        break;
                      default:
                        statusColor = Colors.black;
                        break;
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: RichText(
                        // Usando RichText para o texto com duas cores
                        text: TextSpan(
                          text: '- $date: ',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          children: [
                            TextSpan(
                              text: status,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            // NOVO: Botão "Marcar como Concluída"
            ElevatedButton.icon(
              onPressed: _markAsComplete,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('MARCAR COMO CONCLUÍDA'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size.fromHeight(50),
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
                    label: const Text('EXCLUIR HÁBITO'),
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
                      if (updatedHabito != null) {
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
                    label: const Text('EDITAR HÁBITO'),
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
