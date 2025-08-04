// lib/screens/rotinas/add_edit_rotina_screen.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:health_routine_coach/models/rotina.dart';
import 'package:health_routine_coach/models/habito.dart';
import 'package:health_routine_coach/screens/habitos/habitos_screen.dart'; // Import para a lista de dummyHabitos

class AddEditRotinaScreen extends StatefulWidget {
  final Rotina? rotina;

  const AddEditRotinaScreen({super.key, this.rotina});

  @override
  State<AddEditRotinaScreen> createState() => _AddEditRotinaScreenState();
}

class _AddEditRotinaScreenState extends State<AddEditRotinaScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late List<int> _selectedDays;
  late List<Habito> _selectedHabits;

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
    _selectedHabits = dummyHabitos
        .where((h) => widget.rotina?.habitIds.contains(h.id) ?? false)
        .toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDays() async {
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
                  final isSelected = _selectedDays.contains(dayNum);
                  return FilterChip(
                    label: Text(_weekDaysNames[index]),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setStateInDialog(() {
                        if (selected) {
                          _selectedDays.add(dayNum);
                        } else {
                          _selectedDays.remove(dayNum);
                        }
                        _selectedDays.sort();
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
                  onPressed: () => Navigator.of(context).pop(_selectedDays),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedDays = result;
      });
    }
  }

  Future<void> _selectHabits() async {
    final List<Habito>? result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _HabitSelectionScreen(
          allHabits: dummyHabitos,
          initialSelectedHabits: _selectedHabits,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedHabits = result;
      });
    }
  }

  void _saveRotina() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecione pelo menos um dia da semana.'),
          ),
        );
        return;
      }

      final String id = widget.rotina?.id ?? const Uuid().v4();
      final String userId = widget.rotina?.userId ?? 'current_user_id';
      final String name = _nameController.text.trim();
      final String? description = _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim();
      final List<int> activeDays = _selectedDays;
      final List<String> habitIds = _selectedHabits.map((h) => h.id).toList();

      final newOrUpdatedRotina = Rotina(
        id: id,
        userId: userId,
        name: name,
        description: description,
        activeDays: activeDays,
        habitIds: habitIds,
      );

      Navigator.of(context).pop(newOrUpdatedRotina);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.rotina != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Rotina' : 'Adicionar / Editar Rotina'),
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
                          labelText: 'Nome da rotina:',
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
                      const SizedBox(height: 24),
                      const Text(
                        'Dias da semana:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _selectDays(),
                        child: AbsorbPointer(
                          child: TextFormField(
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: 'Selecione os dias da semana',
                              border: const OutlineInputBorder(),
                              suffixIcon: const Icon(Icons.calendar_today),
                              errorText:
                                  _selectedDays.isEmpty &&
                                      _formKey.currentState != null &&
                                      !_formKey.currentState!.validate()
                                  ? 'Selecione pelo menos um dia.'
                                  : null,
                              labelText: _selectedDays.isNotEmpty
                                  ? _selectedDays
                                        .map((e) => _weekDaysNames[e - 1])
                                        .join(', ')
                                  : null,
                            ),
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
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _selectedHabits.length,
                        itemBuilder: (context, index) {
                          final habit = _selectedHabits[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    habit.name,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      if (_selectedHabits.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'Nenhum hábito selecionado para esta rotina.',
                            style: TextStyle(color: Colors.grey),
                          ),
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
        onPressed: _saveRotina,
        icon: const Icon(Icons.add),
        label: Text(isEditing ? 'SALVAR' : 'CRIAR ROTINA'),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
}

// ---- Tela de Seleção de Hábitos (Modal ou Nova Rota) ----
// Este é o widget que faltava para o erro ser resolvido!
class _HabitSelectionScreen extends StatefulWidget {
  final List<Habito> allHabits;
  final List<Habito> initialSelectedHabits;

  const _HabitSelectionScreen({
    Key? key,
    required this.allHabits,
    required this.initialSelectedHabits,
  }) : super(key: key);

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

  bool _isHabitSelected(Habito habit) {
    return _currentSelectedHabits.any((h) => h.id == habit.id);
  }

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
            onPressed: () {
              Navigator.of(context).pop(_currentSelectedHabits);
            },
            child: const Text('CONCLUIR'),
          ),
        ],
      ),
      body: widget.allHabits.isEmpty
          ? const Center(child: Text('Nenhum hábito disponível para seleção.'))
          : ListView.builder(
              itemCount: widget.allHabits.length,
              itemBuilder: (context, index) {
                final habit = widget.allHabits[index];
                final isSelected = _isHabitSelected(habit);
                return CheckboxListTile(
                  title: Text(habit.name),
                  value: isSelected,
                  onChanged: (bool? value) {
                    _toggleHabitSelection(habit);
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                );
              },
            ),
    );
  }
}
