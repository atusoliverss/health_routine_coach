// lib/screens/habitos/add_edit_habito_screen.dart

// --- IMPORTAÇÕES ---
import 'package:flutter/material.dart';
// Pacote para gerar IDs únicos para novos hábitos.
import 'package:uuid/uuid.dart';
// Importa os modelos de dados para Hábito e Rotina.
import 'package:health_routine_coach/models/habito.dart';
import 'package:health_routine_coach/models/rotina.dart';
// Importa o serviço que se comunica com o Firestore.
import 'package:health_routine_coach/services/firestore_service.dart';
// Importa a AppBar personalizada para manter a consistência visual.
import 'package:health_routine_coach/widgets/custom_app_bar.dart';

// --- WIDGET DA TELA DE ADICIONAR/EDITAR HÁBITO ---
// StatefulWidget porque o formulário gerencia vários estados (seleções, texto, etc.).
class AddEditHabitoScreen extends StatefulWidget {
  // Hábito opcional. Se não for nulo, a tela entra em modo de edição.
  final Habito? habito;

  const AddEditHabitoScreen({super.key, this.habito});

  @override
  State<AddEditHabitoScreen> createState() => _AddEditHabitoScreenState();
}

// --- CLASSE DE ESTADO ---
class _AddEditHabitoScreenState extends State<AddEditHabitoScreen> {
  // --- ESTADO E CONTROLADORES ---
  // Chave global para identificar e validar o formulário.
  final _formKey = GlobalKey<FormState>();
  // Instância do serviço para acessar o Firestore.
  final FirestoreService _firestoreService = FirestoreService();
  // Controladores para os campos de texto.
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _weeklyTargetController;
  // Variáveis para guardar as seleções do usuário no formulário.
  FrequencyType _selectedFrequencyType = FrequencyType.daily;
  late List<int> _selectedSpecificDays;
  Turno? _selectedTurno;
  Rotina? _selectedRotina;
  // Futures para buscar dados assíncronos (rotinas e nome do usuário).
  late Future<List<Rotina>> _routinesFuture;
  late Future<String> _userNameFuture;

  // Lista de nomes dos dias da semana para a UI.
  final List<String> _weekDaysNames = [
    'Seg',
    'Ter',
    'Qua',
    'Qui',
    'Sex',
    'Sáb',
    'Dom',
  ];

  // --- CICLO DE VIDA DO WIDGET ---
  @override
  void initState() {
    super.initState();
    // Inicializa os controladores com os dados do hábito (se estiver editando) ou vazios.
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

    // Inicia a busca pelos dados necessários para a tela.
    _userNameFuture = _firestoreService.getUserName();
    _routinesFuture = _firestoreService
        .getRoutinesStream()
        .first; // Pega a lista de rotinas uma vez.
  }

  @override
  void dispose() {
    // Libera os recursos dos controladores para evitar vazamentos de memória.
    _nameController.dispose();
    _descriptionController.dispose();
    _weeklyTargetController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE NEGÓCIO ---
  /// Salva o hábito (novo ou editado) no Firestore.
  Future<void> _saveHabito() async {
    // Se o formulário não for válido, interrompe a execução.
    if (!_formKey.currentState!.validate()) return;

    // Validação específica para o tipo de frequência "dias específicos".
    if (_selectedFrequencyType == FrequencyType.specificDays &&
        _selectedSpecificDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione pelo menos um dia da semana.')),
      );
      return;
    }

    // Prepara a lista de dias da semana para salvar no Firestore.
    List<int>? specificDaysToSave;
    if (_selectedFrequencyType == FrequencyType.daily) {
      // Se for diário, salva uma lista com todos os dias para facilitar a consulta na HomeScreen.
      specificDaysToSave = [1, 2, 3, 4, 5, 6, 7];
    } else if (_selectedFrequencyType == FrequencyType.specificDays) {
      specificDaysToSave = _selectedSpecificDays;
    }

    // Cria o objeto do hábito com os dados do formulário.
    final newOrUpdatedHabito = Habito(
      id:
          widget.habito?.id ??
          const Uuid().v4(), // Usa o ID existente ou gera um novo.
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      frequencyType: _selectedFrequencyType,
      weeklyTarget: _selectedFrequencyType == FrequencyType.weeklyTimes
          ? int.tryParse(_weeklyTargetController.text)
          : null,
      specificDays: specificDaysToSave,
      preferredTurn: _selectedTurno,
    );

    // Salva o hábito na sua coleção no Firestore.
    await _firestoreService.saveHabit(newOrUpdatedHabito);

    // Se uma rotina foi selecionada, atualiza a rotina para incluir este hábito.
    if (_selectedRotina != null) {
      final habitIds = _selectedRotina!.habitIds
          .toSet(); // Usa um Set para evitar duplicatas.
      habitIds.add(newOrUpdatedHabito.id);
      _selectedRotina!.habitIds.clear();
      _selectedRotina!.habitIds.addAll(habitIds.toList());
      await _firestoreService.saveRoutine(_selectedRotina!);
    }

    // Volta para a tela anterior após salvar.
    if (mounted) {
      Navigator.of(context).pop(newOrUpdatedHabito);
    }
  }

  // --- CONSTRUÇÃO DA INTERFACE ---
  @override
  Widget build(BuildContext context) {
    // Variável para saber se a tela está em modo de edição ou criação.
    final bool isEditing = widget.habito != null;

    // FutureBuilder para garantir que a UI só seja construída após carregar o nome do usuário.
    return FutureBuilder<String>(
      future: _userNameFuture,
      builder: (context, snapshot) {
        // Enquanto o nome está carregando, exibe um spinner.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userName = snapshot.data ?? 'Usuário';

        // Estrutura principal da tela.
        return Scaffold(
          // Usa a AppBar personalizada para manter a consistência visual.
          appBar: CustomAppBar(userName: userName),
          // Corpo da tela.
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho da página (abaixo da AppBar principal).
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
                            // Campo Frequência
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
                            // Campo condicional para "X vezes por semana"
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
                            // Campo condicional para "Dias específicos"
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
                            // Campo Turno
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
                            // Campo Vincular à Rotina
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
                                    child: const Text('Carregando rotinas...'),
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
          // Botão de salvar na parte inferior da tela.
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
