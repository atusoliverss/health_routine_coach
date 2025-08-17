// lib/screens/metas/detalhe_meta_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:health_routine_coach/models/meta.dart';
import 'package:health_routine_coach/services/firestore_service.dart';
import 'package:health_routine_coach/screens/metas/add_edit_meta_screen.dart';

class DetalheMetaScreen extends StatefulWidget {
  final Meta meta;

  const DetalheMetaScreen({super.key, required this.meta});

  @override
  State<DetalheMetaScreen> createState() => _DetalheMetaScreenState();
}

class _DetalheMetaScreenState extends State<DetalheMetaScreen> {
  // A lógica do State e do initState permanece a mesma.
  final FirestoreService _firestoreService = FirestoreService();
  late Meta _currentMeta;

  @override
  void initState() {
    super.initState();
    _currentMeta = widget.meta;
  }

  // A lógica para marcar como concluída permanece a mesma.
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

  // ALTERAÇÃO: O AlertDialog de confirmação foi reestilizado
  // para ter um design mais moderno e consistente com o app.
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
          actionsPadding:
              const EdgeInsets.only(bottom: 20.0, left: 20, right: 20),
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

  @override
  Widget build(BuildContext context) {
    // A lógica para definir o texto e a cor do status foi mantida.
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
    
    // ALTERAÇÃO: A AppBar foi removida e a tela foi reestruturada.
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ALTERAÇÃO: Cabeçalho customizado com botão de voltar e nome da meta.
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

            // ALTERAÇÃO: Título da seção "DETALHE DA META"
            const Text(
              'DETALHE DA META',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            // ALTERAÇÃO: As informações da meta agora são exibidas dentro de um Card.
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
                        const Text('Status: ', style: TextStyle(fontSize: 16)),
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
            
            // ALTERAÇÃO: Spacer para empurrar os botões para a parte inferior da tela.
            const Spacer(),

            // ALTERAÇÃO: Botão "MARCAR COMO CONCLUÍDA" foi reestilizado.
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

            // ALTERAÇÃO: Os botões de Excluir e Editar foram reorganizados
            // em uma Row e reestilizados para combinar com a tela de detalhes do hábito.
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
  }
}