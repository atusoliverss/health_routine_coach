// lib/screens/metas/add_edit_meta_screen.dart

// --- IMPORTAÇÕES ---
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:health_routine_coach/models/meta.dart';
import 'package:health_routine_coach/services/firestore_service.dart';
import 'package:health_routine_coach/widgets/custom_app_bar.dart';

// --- WIDGET DA TELA DE ADICIONAR/EDITAR META ---
class AddEditMetaScreen extends StatefulWidget {
  final Meta? meta; // Meta opcional para o modo de edição.

  const AddEditMetaScreen({super.key, this.meta});

  @override
  State<AddEditMetaScreen> createState() => _AddEditMetaScreenState();
}

class _AddEditMetaScreenState extends State<AddEditMetaScreen> {
  // --- ESTADO E CONTROLADORES ---
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _deadlineController;
  DateTime? _selectedDate;
  late Future<String> _userNameFuture;

  @override
  void initState() {
    super.initState();
    // Inicializa os controladores com os dados da meta (se houver).
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
    _userNameFuture = _firestoreService.getUserName();
  }

  @override
  void dispose() {
    // Libera os recursos dos controladores.
    _nameController.dispose();
    _descriptionController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  // --- MÉTODOS DE LÓGICA ---

  /// Abre o seletor de data para escolher o prazo final.
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

  /// Salva a meta (nova ou editada) no Firestore.
  Future<void> _saveMeta() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione um prazo final.')),
      );
      return;
    }

    // Cria o objeto da meta com os dados do formulário.
    final newOrUpdatedMeta = Meta(
      id: widget.meta?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      deadline: _selectedDate!,
      status: widget.meta?.status ?? MetaStatus.emProgresso,
    );

    // Salva a meta no Firestore.
    await _firestoreService.saveGoal(newOrUpdatedMeta);

    if (mounted) {
      // Retorna a meta salva para a tela de detalhes, para que ela possa se atualizar.
      Navigator.of(context).pop(newOrUpdatedMeta);
    }
  }

  // --- CONSTRUÇÃO DA INTERFACE ---
  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.meta != null;

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
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho personalizado da página.
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
              // Formulário de preenchimento.
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Form(
                    key: _formKey,
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
                            // Campo Nome
                            const Text(
                              'Nome:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
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
                            // Campo Descrição
                            const Text(
                              'Descrição (opcional):',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
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
                            // Campo Prazo Final
                            const Text(
                              'Prazo Final:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
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
          // Botão de salvar na parte inferior da tela.
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
      },
    );
  }
}
