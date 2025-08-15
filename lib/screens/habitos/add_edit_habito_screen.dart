import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:health_routine_coach/models/habito.dart';
import 'package:health_routine_coach/services/firestore_service.dart';

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

    final newOrUpdatedHabito = Habito(
      id: widget.habito?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      frequencyType: _selectedFrequencyType,
      weeklyTarget: _selectedFrequencyType == FrequencyType.weeklyTimes
          ? int.tryParse(_weeklyTargetController.text)
          : null,
      specificDays: _selectedFrequencyType == FrequencyType.specificDays
          ? _selectedSpecificDays
          : null,
      preferredTurn: _selectedTurno,
    );

    await _firestoreService.saveHabit(newOrUpdatedHabito);

    if (mounted) {
      Navigator.of(context).pop(newOrUpdatedHabito);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.habito != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar Hábito' : 'Novo Hábito')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          labelText: 'Nome:',
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
                      DropdownButtonFormField<FrequencyType>(
                        value: _selectedFrequencyType,
                        decoration: const InputDecoration(
                          labelText: 'Frequência:',
                          border: OutlineInputBorder(),
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
                            child: Text('Dias específicos da semana'),
                          ),
                        ],
                      ),
                      if (_selectedFrequencyType == FrequencyType.weeklyTimes)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: TextFormField(
                            controller: _weeklyTargetController,
                            decoration: const InputDecoration(
                              labelText: 'Quantas vezes por semana?',
                              border: OutlineInputBorder(),
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
                      if (_selectedFrequencyType == FrequencyType.specificDays)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Quais dias da semana?',
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
                                          _selectedSpecificDays.add(dayNum);
                                        } else {
                                          _selectedSpecificDays.remove(dayNum);
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
                      DropdownButtonFormField<Turno>(
                        value: _selectedTurno,
                        decoration: const InputDecoration(
                          labelText: 'Turno Preferido (opcional):',
                          border: OutlineInputBorder(),
                        ),
                        hint: const Text('Selecione um turno'),
                        onChanged: (Turno? newValue) {
                          setState(() {
                            _selectedTurno = newValue;
                          });
                        },
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Nenhum')),
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
          onPressed: _saveHabito,
          icon: const Icon(Icons.save),
          label: Text(isEditing ? 'SALVAR ALTERAÇÕES' : 'CRIAR HÁBITO'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
          ),
        ),
      ),
    );
  }
}
