// lib/screens/metas/add_edit_meta_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:health_routine_coach/models/meta.dart';

class AddEditMetaScreen extends StatefulWidget {
  final Meta? meta;

  const AddEditMetaScreen({super.key, this.meta});

  @override
  State<AddEditMetaScreen> createState() => _AddEditMetaScreenState();
}

class _AddEditMetaScreenState extends State<AddEditMetaScreen> {
  final _formKey = GlobalKey<FormState>();
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

  void _saveMeta() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione um prazo final.')),
        );
        return;
      }

      final String id = widget.meta?.id ?? const Uuid().v4();
      final String userId = widget.meta?.userId ?? 'current_user_id';
      final String name = _nameController.text.trim();
      final String? description = _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim();
      final DateTime deadline = _selectedDate!;

      Meta newOrUpdatedMeta = Meta(
        id: id,
        userId: userId,
        name: name,
        description: description,
        deadline: deadline,
        status: widget.meta?.status ?? MetaStatus.emProgresso,
      );

      Navigator.of(context).pop(newOrUpdatedMeta);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.meta != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Meta' : 'Adicionar / Editar Meta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nome da Meta:',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira um nome.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Descrição:',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _deadlineController,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        decoration: InputDecoration(
                          labelText: 'Prazo Final:',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () => _selectDate(context),
                          ),
                        ),
                        validator: (value) {
                          if (_selectedDate == null) {
                            return 'Selecione uma data.';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ElevatedButton.icon(
        onPressed: _saveMeta,
        icon: const Icon(Icons.add),
        label: Text(isEditing ? 'SALVAR' : 'CRIAR META'),
        style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
      ),
    );
  }
}
