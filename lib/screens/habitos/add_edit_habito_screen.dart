// lib/screens/habitos/add_edit_habito_screen.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:health_routine_coach/models/habito.dart';
import 'package:health_routine_coach/models/rotina.dart';
import 'package:health_routine_coach/screens/rotinas/rotinas_screen.dart'; // Import para dummyRotinas

class AddEditHabitoScreen extends StatefulWidget {
  final Habito? habito;

  const AddEditHabitoScreen({super.key, this.habito});

  @override
  State<AddEditHabitoScreen> createState() => _AddEditHabitoScreenState();
}

class _AddEditHabitoScreenState extends State<AddEditHabitoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  FrequencyType _selectedFrequencyType = FrequencyType.daily;
  late TextEditingController _weeklyTargetController;
  late List<int> _selectedSpecificDays;
  Turno? _selectedTurno;
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
      text: widget.habito?.weeklyTarget?.toString() ?? '1',
    );
    _selectedSpecificDays = List.from(widget.habito?.specificDays ?? []);
    _selectedTurno = widget.habito?.preferredTurn;
    if (widget.habito != null) {
      _selectedRotina = dummyRotinas.firstWhere(
        (rotina) => rotina.habitIds.contains(widget.habito!.id),
        orElse: () => dummyRotinas.first,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _weeklyTargetController.dispose();
    super.dispose();
  }

  void _saveHabito() {
    if (_formKey.currentState!.validate()) {
      if (_selectedFrequencyType == FrequencyType.specificDays &&
          _selectedSpecificDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecione pelo menos um dia da semana.'),
          ),
        );
        return;
      }

      final String id = widget.habito?.id ?? const Uuid().v4();
      final String userId = widget.habito?.userId ?? 'current_user_id';
      final String name = _nameController.text.trim();
      final String? description = _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim();

      Habito newOrUpdatedHabito = Habito(
        id: id,
        userId: userId,
        name: name,
        description: description,
        frequencyType: _selectedFrequencyType,
        weeklyTarget: _selectedFrequencyType == FrequencyType.weeklyTimes
            ? int.tryParse(_weeklyTargetController.text) ?? 1
            : null,
        specificDays: _selectedFrequencyType == FrequencyType.specificDays
            ? _selectedSpecificDays
            : null,
        preferredTurn: _selectedTurno,
      );

      Navigator.of(context).pop(newOrUpdatedHabito);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.habito != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Hábito' : 'Adicionar / Editar Hábito'),
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
                          labelText: 'Nome:',
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
                              if (_selectedFrequencyType ==
                                      FrequencyType.weeklyTimes &&
                                  (value == null ||
                                      int.tryParse(value) == null ||
                                      int.parse(value) <= 0)) {
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
                          labelText: 'Turno Preferido:',
                          border: OutlineInputBorder(),
                        ),
                        hint: const Text('Selecione um turno'),
                        onChanged: (Turno? newValue) {
                          setState(() {
                            _selectedTurno = newValue;
                          });
                        },
                        items: const [
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
                      DropdownButtonFormField<Rotina>(
                        value: _selectedRotina,
                        decoration: const InputDecoration(
                          labelText: 'Vincular à Rotina:',
                          border: OutlineInputBorder(),
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
                          ...dummyRotinas.map(
                            (rotina) => DropdownMenuItem(
                              value: rotina,
                              child: Text(rotina.name),
                            ),
                          ),
                        ],
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
        onPressed: _saveHabito,
        icon: const Icon(Icons.add),
        label: Text(isEditing ? 'SALVAR' : 'CRIAR HÁBITO'),
        style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
      ),
    );
  }
}
