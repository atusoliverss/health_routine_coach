// lib/screens/rotinas/add_edit_rotina_screen.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:health_routine_coach/models/rotina.dart';
import 'package:health_routine_coach/models/habito.dart';
import 'package:health_routine_coach/services/firestore_service.dart';
import 'package:health_routine_coach/widgets/custom_app_bar.dart';

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
  late Future<String> _userNameFuture;

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
    _userNameFuture = _firestoreService.getUserName();

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
        fullscreenDialog: true,
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedHabits = result;
      });
    }
  }

  /// CORREÇÃO: Método para abrir o diálogo de seleção de dias.
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
                    selectedColor: Color(0xFF03A9F4),
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  );
                }),
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        maximumSize: const Size.fromWidth(170),
                        backgroundColor: Color.fromARGB(255, 255, 0, 0),
                      ),
                      child: const Text(
                        'CANCELAR',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          Navigator.of(context).pop(tempSelectedDays),
                      style: ElevatedButton.styleFrom(
                        maximumSize: const Size.fromWidth(170),
                        backgroundColor: Color(0xFF12855B),
                      ),
                      child: const Text(
                        'CONFIRMAR',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
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
                      isEditing ? 'Editar Rotina' : 'Adicionar Rotina',
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
                    child: Card(
                      color: Colors.grey[200],
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Nome da rotina:',
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
                            const Text(
                              'Descrição:',
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
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  suffixIcon: const Icon(
                                    Icons.calendar_today_outlined,
                                  ),
                                ),
                                child: Text(
                                  _selectedDays.isEmpty
                                      ? 'Clique para selecionar'
                                      : _selectedDays
                                            .map((d) => _weekDaysNames[d - 1])
                                            .join(', '),
                                  style: TextStyle(
                                    color: _selectedDays.isEmpty
                                        ? Colors.grey[600]
                                        : Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Hábitos:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  if (_selectedHabits.isNotEmpty)
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: _selectedHabits.length,
                                      itemBuilder: (context, index) {
                                        final habit = _selectedHabits[index];
                                        return ListTile(
                                          leading: Checkbox(
                                            value: true,
                                            onChanged: (v) {},
                                            activeColor: const Color(
                                              0xFF03A9F4,
                                            ),
                                          ),
                                          title: Text(habit.name),
                                          dense: true,
                                          contentPadding: EdgeInsets.zero,
                                        );
                                      },
                                    ),
                                  if (_selectedHabits.isNotEmpty)
                                    const Divider(),
                                  InkWell(
                                    onTap: _selectHabits,
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.add_circle_outline,
                                            color: Color(0xFF03A9F4),
                                          ),
                                          SizedBox(width: 12),
                                          Text('Adicionar/Remover Hábitos'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),
                            Center(
                              child: SizedBox(
                                width: 180,
                                child: ElevatedButton.icon(
                                  onPressed: _saveRotina,
                                  icon: const Icon(
                                    size: 30,
                                    Icons.add_box_rounded,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    isEditing ? 'SALVAR' : 'SALVAR',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF03A9F4),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                              ),
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
        );
      },
    );
  }
}

// Tela de Seleção de Hábitos
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
  final FirestoreService _firestoreService = FirestoreService();
  late List<Habito> _currentSelectedHabits;
  late Future<String> _userNameFuture;

  @override
  void initState() {
    super.initState();
    _currentSelectedHabits = List.from(widget.initialSelectedHabits);
    _userNameFuture = _firestoreService.getUserName();
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
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFF03A9F4),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const Text(
                      'Selecionar Hábitos',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          Navigator.of(context).pop(_currentSelectedHabits),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF12855B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('CONCLUIR'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: widget.allHabits.isEmpty
                    ? const Center(child: Text('Nenhum hábito cadastrado.'))
                    : ListView.builder(
                        itemCount: widget.allHabits.length,
                        itemBuilder: (context, index) {
                          final habit = widget.allHabits[index];
                          return CheckboxListTile(
                            title: Text(habit.name),
                            value: _isHabitSelected(habit),
                            onChanged: (bool? value) =>
                                _toggleHabitSelection(habit),
                            controlAffinity: ListTileControlAffinity.leading,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
