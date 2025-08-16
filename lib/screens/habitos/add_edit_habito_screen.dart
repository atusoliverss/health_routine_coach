import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:health_routine_coach/models/habito.dart';
import 'package:health_routine_coach/models/rotina.dart';
import 'package:health_routine_coach/services/firestore_service.dart';
import 'package:health_routine_coach/widgets/custom_app_bar.dart';

class AddEditHabitoScreen extends StatefulWidget {
  final Habito? habito;

  const AddEditHabitoScreen({super.key, this.habito});

  @override
  State<AddEditHabitoScreen> createState() => _AddEditHabitoScreenState();
}

class _AddEditHabitoScreenState extends State<AddEditHabitoScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  FrequencyType _selectedFrequencyType = FrequencyType.daily;
  late TextEditingController _weeklyTargetController;
  late List<int> _selectedSpecificDays;
  Turno? _selectedTurno;
  late Future<List<Rotina>> _routinesFuture;
  Rotina? _selectedRotina;

  final List<String> _weekDaysNames = [
    'Seg',
    'Ter',
    'Qua',
    'Qui',
    'Sex',
    'Sáb',
    'Dom',
  ];
  late Future<String> _userNameFuture;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.habito?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.habito?.description ?? '',
    );
    _selectedFrequencyType =
        widget.habito?.frequencyType ?? FrequencyType.daily;
    _weeklyTargetController = TextEditingController(
      text: widget.habito?.weeklyTarget?.toString() ?? '3',
    );
    _selectedSpecificDays = List.from(widget.habito?.specificDays ?? []);
    _selectedTurno = widget.habito?.preferredTurn;
    _userNameFuture = _firestoreService.getUserName();
    _routinesFuture = _firestoreService.getRoutinesStream().first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _weeklyTargetController.dispose();
    super.dispose();
  }

  Future<void> _saveHabito() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFrequencyType == FrequencyType.specificDays &&
        _selectedSpecificDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione pelo menos um dia da semana.')),
      );
      return;
    }

    // CORREÇÃO: Garante que hábitos diários tenham todos os dias da semana.
    List<int>? specificDaysToSave;
    if (_selectedFrequencyType == FrequencyType.daily) {
      // Se for diário, salvamos uma lista com todos os dias para facilitar a consulta.
      specificDaysToSave = [1, 2, 3, 4, 5, 6, 7];
    } else if (_selectedFrequencyType == FrequencyType.specificDays) {
      specificDaysToSave = _selectedSpecificDays;
    }

    final newOrUpdatedHabito = Habito(
      id: widget.habito?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      frequencyType: _selectedFrequencyType,
      weeklyTarget: _selectedFrequencyType == FrequencyType.weeklyTimes
          ? int.tryParse(_weeklyTargetController.text)
          : null,
      specificDays: specificDaysToSave,
      preferredTurn: _selectedTurno,
    );

    await _firestoreService.saveHabit(newOrUpdatedHabito);

    if (_selectedRotina != null) {
      final habitIds = _selectedRotina!.habitIds.toSet();
      habitIds.add(newOrUpdatedHabito.id);
      _selectedRotina!.habitIds.clear();
      _selectedRotina!.habitIds.addAll(habitIds.toList());
      await _firestoreService.saveRoutine(_selectedRotina!);
    }

    if (mounted) {
      Navigator.of(context).pop(newOrUpdatedHabito);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.habito != null;
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
                      isEditing ? 'Editar Hábito' : 'Adicionar Hábito',
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
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                            const SizedBox(height: 24),
                            const Text(
                              'Frequência:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<FrequencyType>(
                              value: _selectedFrequencyType,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: (FrequencyType? newValue) {
                                setState(() {
                                  _selectedFrequencyType = newValue!;
                                });
                              },
                              items: const [
                                DropdownMenuItem(
                                  value: FrequencyType.daily,
                                  child: Text('Diário'),
                                ),
                                DropdownMenuItem(
                                  value: FrequencyType.weeklyTimes,
                                  child: Text('X vezes por semana'),
                                ),
                                DropdownMenuItem(
                                  value: FrequencyType.specificDays,
                                  child: Text('Dias específicos'),
                                ),
                              ],
                            ),
                            if (_selectedFrequencyType ==
                                FrequencyType.weeklyTimes)
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: TextFormField(
                                  controller: _weeklyTargetController,
                                  decoration: InputDecoration(
                                    labelText: 'Quantas vezes?',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null ||
                                        int.tryParse(value) == null ||
                                        int.parse(value) <= 0) {
                                      return 'Insira um número válido.';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            if (_selectedFrequencyType ==
                                FrequencyType.specificDays)
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Quais dias?',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8.0,
                                      runSpacing: 8.0,
                                      children: List.generate(7, (index) {
                                        final dayNum = index + 1;
                                        final isSelected = _selectedSpecificDays
                                            .contains(dayNum);
                                        return FilterChip(
                                          label: Text(_weekDaysNames[index]),
                                          selected: isSelected,
                                          onSelected: (bool selected) {
                                            setState(() {
                                              if (selected) {
                                                _selectedSpecificDays.add(
                                                  dayNum,
                                                );
                                              } else {
                                                _selectedSpecificDays.remove(
                                                  dayNum,
                                                );
                                              }
                                              _selectedSpecificDays.sort();
                                            });
                                          },
                                          selectedColor: Theme.of(
                                            context,
                                          ).primaryColor,
                                          checkmarkColor: Colors.white,
                                          labelStyle: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 24),
                            const Text(
                              'Turno Preferido:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<Turno>(
                              value: _selectedTurno,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              hint: const Text('Nenhum'),
                              onChanged: (Turno? newValue) {
                                setState(() {
                                  _selectedTurno = newValue;
                                });
                              },
                              items: const [
                                DropdownMenuItem(
                                  value: null,
                                  child: Text('Nenhum'),
                                ),
                                DropdownMenuItem(
                                  value: Turno.manha,
                                  child: Text('Manhã'),
                                ),
                                DropdownMenuItem(
                                  value: Turno.tarde,
                                  child: Text('Tarde'),
                                ),
                                DropdownMenuItem(
                                  value: Turno.noite,
                                  child: Text('Noite'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Vincular à Rotina:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            FutureBuilder<List<Rotina>>(
                              future: _routinesFuture,
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return InputDecorator(
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    child: Text('Carregando rotinas...'),
                                  );
                                }
                                final rotinas = snapshot.data!;
                                return DropdownButtonFormField<Rotina>(
                                  value: _selectedRotina,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  hint: const Text('Nenhuma'),
                                  onChanged: (Rotina? newValue) {
                                    setState(() {
                                      _selectedRotina = newValue;
                                    });
                                  },
                                  items: [
                                    const DropdownMenuItem<Rotina>(
                                      value: null,
                                      child: Text('Nenhuma'),
                                    ),
                                    ...rotinas.map(
                                      (rotina) => DropdownMenuItem(
                                        value: rotina,
                                        child: Text(rotina.name),
                                      ),
                                    ),
                                  ],
                                );
                              },
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
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _saveHabito,
              icon: const Icon(Icons.add, color: Colors.white),
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
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        );
      },
    );
  }
}
