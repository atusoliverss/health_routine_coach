import 'package:flutter/material.dart';
import 'package:health_routine_coach/models/meta.dart';
import 'package:health_routine_coach/services/firestore_service.dart';
import 'package:health_routine_coach/screens/metas/add_edit_meta_screen.dart';
import 'package:health_routine_coach/screens/metas/detalhe_meta_screen.dart';

class MetasScreen extends StatefulWidget {
  const MetasScreen({super.key});

  @override
  State<MetasScreen> createState() => _MetasScreenState();
}

class _MetasScreenState extends State<MetasScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Botão para Adicionar Nova Meta
          GestureDetector(
            onTap: () {
              Navigator.of(context).push<Meta>(
                MaterialPageRoute(
                  builder: (context) => const AddEditMetaScreen(),
                ),
              );
            },
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Adicione uma nova meta',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    Icon(Icons.add_circle, color: Color(0xFF03A9F4), size: 28),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Minhas Metas',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<List<Meta>>(
              stream: _firestoreService.getGoalsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erro ao carregar metas: ${snapshot.error}'),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhuma meta cadastrada ainda.\nQue tal adicionar uma nova?',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                final metas = snapshot.data!;
                return ListView.builder(
                  itemCount: metas.length,
                  itemBuilder: (context, index) {
                    final meta = metas[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push<Meta>(
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetalheMetaScreen(meta: meta),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      meta.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.info_outline,
                                    color: Colors.blueAccent,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Prazo: ${meta.deadline.day}/${meta.deadline.month}/${meta.deadline.year}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (meta.status == MetaStatus.emProgresso)
                                Text(
                                  'Faltam: ${meta.daysLeft} dias',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Text(
                                    'Status: ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  _buildStatusText(meta.status),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusText(MetaStatus status) {
    Color color;
    String text;
    switch (status) {
      case MetaStatus.emProgresso:
        color = Colors.orange;
        text = 'em progresso';
        break;
      case MetaStatus.concluido:
        color = Colors.green;
        text = 'concluído';
        break;
      case MetaStatus.expirado:
        color = Colors.red;
        text = 'expirado';
        break;
    }
    return Text(
      text,
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
    );
  }
}
