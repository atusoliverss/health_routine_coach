// lib/screens/rotinas/add_edit_rotina_screen.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:health_routine_coach/models/rotina.dart';
import 'package:health_routine_coach/models/habito.dart';
import 'package:health_routine_coach/services/firestore_service.dart';

class AddEditRotinaScreen extends StatefulWidget {
  final Rotina? rotina;

  const AddEditRotinaScreen({super.key, this.rotina});

  @override
  State<AddEditRotinaScreen> createState() => _AddEditRotinaScreenState();
}

class _AddEditRotinaScreenState extends State<AddEditRotinaScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late List<int> _selectedDays;
  late List<Habito> _selectedHabits;
  late Future<List<Habito>> _allHabitsFuture;

  final List<String> _weekDaysNames = [
    'Seg',
    'Ter',
    'Qua',
    'Qui',
    'Sex',
    'Sáb',
    'Dom',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.rotina?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.rotina?.description ?? '',
    );
    _selectedDays = List.from(widget.rotina?.activeDays ?? []);
    _selectedHabits = [];
    _allHabitsFuture = _firestoreService.getHabitsOnce();

    if (widget.rotina != null) {
      _loadInitialHabits();
    }
  }

  Future<void> _loadInitialHabits() async {
    final allHabits = await _allHabitsFuture;
    if (mounted) {
      setState(() {
        _selectedHabits = allHabits
            .where((h) => widget.rotina!.habitIds.contains(h.id))
            .toList();
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveRotina() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione pelo menos um dia da semana.'),
        ),
      );
      return;
    }

    final newOrUpdatedRotina = Rotina(
      id: widget.rotina?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      activeDays: _selectedDays,
      habitIds: _selectedHabits.map((h) => h.id).toList(),
    );

    await _firestoreService.saveRoutine(newOrUpdatedRotina);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _selectHabits() async {
    final allHabits = await _allHabitsFuture;
    final List<Habito>? result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _HabitSelectionScreen(
          allHabits: allHabits,
          initialSelectedHabits: _selectedHabits,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedHabits = result;
      });
    }
  }

  Future<void> _selectDays() async {
    final List<int> tempSelectedDays = List.from(_selectedDays);
    final List<int>? result = await showDialog<List<int>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            return AlertDialog(
              title: const Text('Selecione os dias da semana'),
              content: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: List.generate(7, (index) {
                  final dayNum = index + 1;
                  final isSelected = tempSelectedDays.contains(dayNum);
                  return FilterChip(
                    label: Text(_weekDaysNames[index]),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setStateInDialog(() {
                        if (selected) {
                          tempSelectedDays.add(dayNum);
                        } else {
                          tempSelectedDays.remove(dayNum);
                        }
                      });
                    },
                    selectedColor: Theme.of(context).primaryColor,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  );
                }),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('CONCLUIR'),
                  onPressed: () => Navigator.of(context).pop(tempSelectedDays),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedDays = result..sort();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.rotina != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar Rotina' : 'Nova Rotina')),
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
                          labelText: 'Nome da rotina:',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Por favor, insira um nome.'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Descrição (opcional):',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Dias da semana:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _selectDays,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _selectedDays.isEmpty
                                ? 'Selecione os dias'
                                : _selectedDays
                                      .map((d) => _weekDaysNames[d - 1])
                                      .join(', '),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'HÁBITOS:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const Divider(height: 10, thickness: 1),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _selectHabits,
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('ADICIONAR/REMOVER HÁBITOS'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          side: BorderSide(color: Colors.grey[400]!),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_selectedHabits.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'Nenhum hábito selecionado para esta rotina.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _selectedHabits.length,
                          itemBuilder: (context, index) {
                            final habit = _selectedHabits[index];
                            return ListTile(
                              leading: Icon(
                                Icons.check_circle,
                                color: Theme.of(context).primaryColor,
                              ),
                              title: Text(habit.name),
                              dense: true,
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 80), // Espaço para o botão flutuante
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ElevatedButton.icon(
          onPressed: _saveRotina,
          icon: const Icon(Icons.save),
          label: Text(isEditing ? 'SALVAR ALTERAÇÕES' : 'CRIAR ROTINA'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
          ),
        ),
      ),
    );
  }
}

class _HabitSelectionScreen extends StatefulWidget {
  final List<Habito> allHabits;
  final List<Habito> initialSelectedHabits;

  const _HabitSelectionScreen({
    required this.allHabits,
    required this.initialSelectedHabits,
  });

  @override
  State<_HabitSelectionScreen> createState() => _HabitSelectionScreenState();
}

class _HabitSelectionScreenState extends State<_HabitSelectionScreen> {
  late List<Habito> _currentSelectedHabits;

  @override
  void initState() {
    super.initState();
    _currentSelectedHabits = List.from(widget.initialSelectedHabits);
  }

  bool _isHabitSelected(Habito habit) =>
      _currentSelectedHabits.any((h) => h.id == habit.id);

  void _toggleHabitSelection(Habito habit) {
    setState(() {
      if (_isHabitSelected(habit)) {
        _currentSelectedHabits.removeWhere((h) => h.id == habit.id);
      } else {
        _currentSelectedHabits.add(habit);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionar Hábitos'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(_currentSelectedHabits),
            child: const Text('CONCLUIR'),
          ),
        ],
      ),
      body: widget.allHabits.isEmpty
          ? const Center(
              child: Text(
                'Nenhum hábito cadastrado. Crie um na aba "Hábitos".',
              ),
            )
          : ListView.builder(
              itemCount: widget.allHabits.length,
              itemBuilder: (context, index) {
                final habit = widget.allHabits[index];
                return CheckboxListTile(
                  title: Text(habit.name),
                  value: _isHabitSelected(habit),
                  onChanged: (bool? value) => _toggleHabitSelection(habit),
                  controlAffinity: ListTileControlAffinity.leading,
                );
              },
            ),
    );
  }
}
