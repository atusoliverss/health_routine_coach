// lib/screens/metas/add_edit_meta_screen.dart

import 'package:flutter/material.dart';
import 'package:health_routine_coach/models/meta.dart';
import 'package:health_routine_coach/services/firestore_service.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class AddEditMetaScreen extends StatefulWidget {
  final Meta? meta;

  const AddEditMetaScreen({super.key, this.meta});

  @override
  State<AddEditMetaScreen> createState() => _AddEditMetaScreenState();
}

class _AddEditMetaScreenState extends State<AddEditMetaScreen> {
  // A lógica do State permanece inalterada.
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _deadlineController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.meta?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.meta?.description ?? '',
    );
    _selectedDate = widget.meta?.deadline;
    _deadlineController = TextEditingController(
      text: _selectedDate != null
          ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
          : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  // A lógica de selecionar data e salvar a meta permanece inalterada.
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _deadlineController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _saveMeta() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione um prazo final.')),
      );
      return;
    }

    final newOrUpdatedMeta = Meta(
      id: widget.meta?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      deadline: _selectedDate!,
      status: widget.meta?.status ?? MetaStatus.emProgresso,
    );

    await _firestoreService.saveGoal(newOrUpdatedMeta);

    if (mounted) {
      Navigator.of(context).pop(newOrUpdatedMeta);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.meta != null;
    
    // ALTERAÇÃO: A AppBar padrão foi removida e a estrutura da tela foi refeita.
    // Agora usa a mesma estrutura com cabeçalho customizado e SingleChildScrollView.
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ALTERAÇÃO: Adicionado cabeçalho customizado com botão de voltar.
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF03A9F4),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  isEditing ? 'Editar Meta' : 'Adicionar Meta',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Form(
                key: _formKey,
                // ALTERAÇÃO: O formulário agora está dentro de um Card estilizado.
                child: Card(
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
                        // ALTERAÇÃO: Campo de Nome reestilizado.
                        // O label agora é um Text separado, e o TextFormField tem
                        // fundo branco e bordas arredondadas.
                        const Text(
                          'Nome:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) =>
                              (value == null || value.isEmpty)
                                  ? 'Por favor, insira um nome.'
                                  : null,
                        ),
                        const SizedBox(height: 16),

                        // ALTERAÇÃO: Campo de Descrição reestilizado.
                        const Text(
                          'Descrição (opcional):',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),

                        // ALTERAÇÃO: Campo de Prazo Final reestilizado.
                        const Text(
                          'Prazo Final:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _deadlineController,
                          readOnly: true,
                          onTap: () => _selectDate(context),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                          validator: (value) => (_selectedDate == null)
                              ? 'Selecione uma data.'
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      // ALTERAÇÃO: O botão de ação foi movido para o bottomNavigationBar.
      // O estilo do botão foi atualizado para corresponder ao design.
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: _saveMeta,
          icon: const Icon(Icons.save, color: Colors.white),
          label: Text(
            isEditing ? 'SALVAR ALTERAÇÕES' : 'SALVAR META',
            style: const TextStyle(fontSize: 16),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF03A9F4),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }
}