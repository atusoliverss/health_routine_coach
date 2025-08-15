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
  final FirestoreService _firestoreService = FirestoreService();
  late Meta _currentMeta;

  @override
  void initState() {
    super.initState();
    _currentMeta = widget.meta;
  }

  Future<void> _confirmDelete() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text('EXCLUIR META?')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Você tem certeza que deseja excluir a meta "${_currentMeta.name}"?',
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
          actionsAlignment: MainAxisAlignment.center,
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
      await _firestoreService.deleteGoal(_currentMeta.id);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

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

  @override
  Widget build(BuildContext context) {
    String statusText;
    Color statusColor;
    switch (_currentMeta.status) {
      case MetaStatus.emProgresso:
        statusText = 'em progresso';
        statusColor = Colors.orange;
        break;
      case MetaStatus.concluido:
        statusText = 'concluído';
        statusColor = Colors.green;
        break;
      case MetaStatus.expirado:
        statusText = 'expirado';
        statusColor = Colors.red;
        break;
    }

    return Scaffold(
      appBar: AppBar(title: Text(_currentMeta.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'DETALHE DA META',
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
                      'Nome: ${_currentMeta.name}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    if (_currentMeta.description != null &&
                        _currentMeta.description!.isNotEmpty)
                      Text(
                        'Descrição: ${_currentMeta.description}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    if (_currentMeta.description != null &&
                        _currentMeta.description!.isNotEmpty)
                      const SizedBox(height: 8),
                    Text(
                      'Prazo: ${DateFormat('dd/MM/yyyy').format(_currentMeta.deadline)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    if (_currentMeta.status == MetaStatus.emProgresso)
                      Text(
                        'Faltam: ${_currentMeta.daysLeft} dias',
                        style: const TextStyle(fontSize: 16),
                      ),
                    if (_currentMeta.status == MetaStatus.emProgresso)
                      const SizedBox(height: 8),
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
            const Spacer(), // Empurra os botões para baixo
            if (_currentMeta.status != MetaStatus.concluido)
              ElevatedButton.icon(
                onPressed: _markAsComplete,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('MARCAR COMO CONCLUÍDA'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            const SizedBox(height: 16),
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
