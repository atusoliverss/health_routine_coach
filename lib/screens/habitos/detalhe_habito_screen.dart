// lib/screens/habitos/detalhe_habito_screen.dart

import 'package:flutter/material.dart';
import 'package:health_routine_coach/models/habito.dart';
import 'package:health_routine_coach/services/firestore_service.dart';
import 'package:health_routine_coach/screens/habitos/add_edit_habito_screen.dart';
import 'package:health_routine_coach/widgets/custom_app_bar.dart';
import 'package:intl/intl.dart';

class DetalheHabitoScreen extends StatefulWidget {
  final Habito habito;

  const DetalheHabitoScreen({super.key, required this.habito});

  @override
  State<DetalheHabitoScreen> createState() => _DetalheHabitoScreenState();
}

class _DetalheHabitoScreenState extends State<DetalheHabitoScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late Habito _currentHabito;
  late Future<String> _userNameFuture;
  // CORREÇÃO: Trocamos o Future por dados de estado locais para permitir a atualização.
  Map<String, bool>? _historyData;
  bool _isHistoryLoading = true;

  @override
  void initState() {
    super.initState();
    _currentHabito = widget.habito;
    _userNameFuture = _firestoreService.getUserName();
    // Inicia a busca pelo histórico real do hábito.
    _loadHistory();
  }

  /// CORREÇÃO: Novo método para carregar (e recarregar) o histórico.
  Future<void> _loadHistory() async {
    // Ativa o estado de carregamento.
    if (mounted) setState(() => _isHistoryLoading = true);

    try {
      final history = await _firestoreService.getHabitHistory(
        _currentHabito.id,
      );
      // Quando os dados chegam, atualiza o estado e desativa o carregamento.
      if (mounted) {
        setState(() {
          _historyData = history;
          _isHistoryLoading = false;
        });
      }
    } catch (e) {
      // Em caso de erro, para de carregar e mostra o erro.
      if (mounted) setState(() => _isHistoryLoading = false);
      debugPrint("Erro ao carregar histórico: $e");
    }
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
          backgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Center(
            child: Text(
              'EXCLUIR HÁBITO?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          content: Text(
            'Você tem certeza que deseja excluir o hábito "${_currentHabito.name}"?\nEsta ação não poderá ser desfeita.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.only(
            bottom: 20.0,
            left: 20,
            right: 20,
          ),
          actions: <Widget>[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('CANCELAR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF03A9F4),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(true),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('EXCLUIR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
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

  /// CORREÇÃO: Marca o hábito como concluído e recarrega o histórico.
  Future<void> _markAsComplete() async {
    // 1. Atualiza o dado no Firestore.
    await _firestoreService.updateHabitStatus(_currentHabito.id, true);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Hábito "${_currentHabito.name}" marcado como concluído!',
          ),
          backgroundColor: Colors.green,
        ),
      );
      // 2. Chama o método para buscar os dados novamente e atualizar a tela.
      _loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _userNameFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userName = snapshot.data ?? 'Usuário';

        return Scaffold(
          appBar: CustomAppBar(userName: userName),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFF03A9F4),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _currentHabito.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                const Text(
                  'DETALHE DO HÁBITO',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  color: Colors.grey[200],
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Nome: ${_currentHabito.name}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Frequência: ${_getFrequencyText(_currentHabito)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Horário Preferido: ${_getTurnoText(_currentHabito.preferredTurn)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        if (_currentHabito.description != null &&
                            _currentHabito.description!.isNotEmpty)
                          Text(
                            'Descrição: ${_currentHabito.description}',
                            style: const TextStyle(fontSize: 16),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'HISTÓRICO DE CONCLUSÃO',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Card(
                    color: Colors.grey[200],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    // CORREÇÃO: Usa a nova lógica de estado em vez do FutureBuilder.
                    child: _isHistoryLoading
                        ? const Center(child: CircularProgressIndicator())
                        : (_historyData == null || _historyData!.isEmpty)
                        ? const Center(
                            child: Text(
                              'Nenhum histórico encontrado.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _historyData!.length,
                            itemBuilder: (context, index) {
                              final sortedDates = _historyData!.keys.toList()
                                ..sort((a, b) => b.compareTo(a));
                              final dateStr = sortedDates[index];
                              final isCompleted = _historyData![dateStr]!;

                              final formattedDate = DateFormat(
                                'dd/MM/yyyy',
                              ).format(DateTime.parse(dateStr));

                              final status = isCompleted
                                  ? 'Concluído'
                                  : 'Pendente';
                              final statusColor = isCompleted
                                  ? Colors.green
                                  : Colors.red;

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                    children: [
                                      const TextSpan(text: '• '),
                                      TextSpan(text: '$formattedDate: '),
                                      TextSpan(
                                        text: status,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.bold,
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
                const SizedBox(height: 24),

                ElevatedButton.icon(
                  onPressed: _markAsComplete,
                  icon: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'MARCAR COMO CONCLUÍDA',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _confirmDelete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        icon: const Icon(Icons.delete_outline),
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
                                  builder: (context) => AddEditHabitoScreen(
                                    habito: _currentHabito,
                                  ),
                                ),
                              );
                          if (updatedHabito != null && mounted) {
                            setState(() {
                              _currentHabito = updatedHabito;
                              _loadHistory();
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF03A9F4),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('EDITAR HÁBITO'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
