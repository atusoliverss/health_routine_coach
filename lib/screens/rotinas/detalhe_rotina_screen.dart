// lib/screens/rotinas/detalhe_rotina_screen.dart

// --- IMPORTAÇÕES ---
import 'package:flutter/material.dart';
import 'package:health_routine_coach/models/habito.dart';
import 'package:health_routine_coach/models/rotina.dart';
import 'package:health_routine_coach/services/firestore_service.dart';
import 'package:health_routine_coach/screens/rotinas/add_edit_rotina_screen.dart';
import 'package:health_routine_coach/widgets/custom_app_bar.dart';

// --- WIDGET DA TELA DE DETALHES DA ROTINA ---
class DetalheRotinaScreen extends StatefulWidget {
  // A rotina a ser exibida, recebida da tela anterior.
  final Rotina rotina;

  const DetalheRotinaScreen({super.key, required this.rotina});

  @override
  State<DetalheRotinaScreen> createState() => _DetalheRotinaScreenState();
}

class _DetalheRotinaScreenState extends State<DetalheRotinaScreen> {
  // --- ESTADO E SERVIÇOS ---
  final FirestoreService _firestoreService = FirestoreService();
  late Rotina _currentRotina; // Guarda o estado atual da rotina na tela.
  late Future<List<Habito>>
  _habitsInRoutineFuture; // Future para buscar os detalhes dos hábitos.
  late Future<String>
  _userNameFuture; // Future para buscar o nome do usuário para a AppBar.

  @override
  void initState() {
    super.initState();
    _currentRotina = widget.rotina;
    _loadHabitDetails(); // Inicia a busca pelos detalhes dos hábitos.
    _userNameFuture = _firestoreService
        .getUserName(); // Inicia a busca pelo nome do usuário.
  }

  // --- MÉTODOS DE LÓGICA ---

  /// Busca os detalhes completos dos hábitos cujos IDs estão na rotina.
  void _loadHabitDetails() {
    setState(() {
      _habitsInRoutineFuture = _firestoreService.getHabitsOnce().then(
        (allHabits) => allHabits
            .where((h) => _currentRotina.habitIds.contains(h.id))
            .toList(),
      );
    });
  }

  /// Formata a lista de dias ativos para um texto legível.
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

  /// Exibe a caixa de diálogo de confirmação para exclusão.
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
              'EXCLUIR ROTINA?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          content: Text(
            'Você tem certeza que deseja excluir a rotina "${_currentRotina.name}"?\nEsta ação não poderá ser desfeita.',
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
      await _firestoreService.deleteRoutine(_currentRotina.id);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  // --- CONSTRUÇÃO DA INTERFACE ---
  @override
  Widget build(BuildContext context) {
    // FutureBuilder para garantir que a UI só seja construída após carregar o nome do usuário.
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
                // Cabeçalho personalizado da página.
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
                        _currentRotina.name,
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

                // Card com os detalhes da rotina.
                const Text(
                  'DETALHE DA ROTINA',
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
                const SizedBox(height: 24),

                // Card com a lista de hábitos da rotina.
                const Text(
                  'HÁBITOS DA ROTINA',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: FutureBuilder<List<Habito>>(
                    future: _habitsInRoutineFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text(
                            'Nenhum hábito associado.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        );
                      }

                      final habitsInRoutine = snapshot.data!;
                      return Card(
                        color: Colors.grey[200],
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
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
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Botões de ação na parte inferior.
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
                        label: const Text('EXCLUIR ROTINA'),
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
                          _loadHabitDetails();
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
                        label: const Text('EDITAR ROTINA'),
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
