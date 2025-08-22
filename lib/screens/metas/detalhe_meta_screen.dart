// lib/screens/metas/detalhe_meta_screen.dart

// --- IMPORTAÇÕES ---
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:health_routine_coach/models/meta.dart';
import 'package:health_routine_coach/services/firestore_service.dart';
import 'package:health_routine_coach/screens/metas/add_edit_meta_screen.dart';
import 'package:health_routine_coach/widgets/custom_app_bar.dart';

// --- WIDGET DA TELA DE DETALHES DA META ---
class DetalheMetaScreen extends StatefulWidget {
  // A meta a ser exibida, recebida da tela anterior.
  final Meta meta;

  const DetalheMetaScreen({super.key, required this.meta});

  @override
  State<DetalheMetaScreen> createState() => _DetalheMetaScreenState();
}

class _DetalheMetaScreenState extends State<DetalheMetaScreen> {
  // --- ESTADO E SERVIÇOS ---
  final FirestoreService _firestoreService = FirestoreService();
  late Meta _currentMeta; // Guarda o estado atual da meta na tela.
  late Future<String> _userNameFuture; // Future para buscar o nome do usuário.

  @override
  void initState() {
    super.initState();
    _currentMeta = widget.meta;
    _userNameFuture = _firestoreService.getUserName();
  }

  // --- MÉTODOS DE LÓGICA ---

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
              'EXCLUIR META?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          content: Text(
            'Você tem certeza que deseja excluir a meta "${_currentMeta.name}"?\nEsta ação não poderá ser desfeita.',
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
      await _firestoreService.deleteGoal(_currentMeta.id);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  /// Atualiza o status da meta para "concluído" e salva no Firestore.
  Future<void> _markAsComplete() async {
    setState(() {
      _currentMeta.status = MetaStatus.concluido;
    });
    await _firestoreService.saveGoal(_currentMeta);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Meta "${_currentMeta.name}" marcada como concluída!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // --- CONSTRUÇÃO DA INTERFACE ---
  @override
  Widget build(BuildContext context) {
    // Lógica para definir o texto e a cor do status.
    String statusText;
    Color statusColor;
    switch (_currentMeta.status) {
      case MetaStatus.emProgresso:
        statusText = 'Em progresso';
        statusColor = Colors.orange;
        break;
      case MetaStatus.concluido:
        statusText = 'Concluída';
        statusColor = Colors.green;
        break;
      case MetaStatus.expirado:
        statusText = 'Expirada';
        statusColor = Colors.red;
        break;
    }

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
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        _currentMeta.name,
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

                // Card com os detalhes da meta.
                const Text(
                  'DETALHE DA META',
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nome: ${_currentMeta.name}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        if (_currentMeta.description != null &&
                            _currentMeta.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              'Descrição: ${_currentMeta.description}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        Text(
                          'Prazo: ${DateFormat('dd/MM/yyyy').format(_currentMeta.deadline)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        if (_currentMeta.status == MetaStatus.emProgresso)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              'Faltam: ${_currentMeta.daysLeft} dias',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        Row(
                          children: [
                            const Text(
                              'Status: ',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Spacer ocupa o espaço vazio, empurrando os botões para baixo.
                const Spacer(),

                // Botão para marcar a meta como concluída.
                if (_currentMeta.status != MetaStatus.concluido)
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

                // Botões de Excluir e Editar.
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
                        label: const Text('EXCLUIR META'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final updatedMeta = await Navigator.of(context)
                              .push<Meta>(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddEditMetaScreen(meta: _currentMeta),
                                ),
                              );
                          if (updatedMeta != null && mounted) {
                            setState(() {
                              _currentMeta = updatedMeta;
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
                        label: const Text('EDITAR META'),
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
