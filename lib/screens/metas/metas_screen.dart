// lib/screens/metas/metas_screen.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:health_routine_coach/models/meta.dart';
import 'package:health_routine_coach/screens/metas/add_edit_meta_screen.dart';
import 'package:health_routine_coach/screens/metas/detalhe_meta_screen.dart';

// Simulação de dados de metas
List<Meta> dummyMetas = [
  Meta(
    id: const Uuid().v4(),
    userId: 'user123',
    name: 'Correr 5km em 30 minutos',
    description: 'Melhorar condicionamento físico e tempo',
    deadline: DateTime(2025, 12, 30),
    status: MetaStatus.emProgresso,
  ),
  Meta(
    id: const Uuid().v4(),
    userId: 'user123',
    name: 'Ler 12 livros no ano',
    deadline: DateTime(2025, 10, 15),
    status: MetaStatus.concluido,
  ),
  Meta(
    id: const Uuid().v4(),
    userId: 'user123',
    name: 'Meditar 30 dias seguidos',
    deadline: DateTime(2025, 3, 15),
    status: MetaStatus.expirado,
  ),
];

class MetasScreen extends StatefulWidget {
  const MetasScreen({super.key});

  @override
  State<MetasScreen> createState() => _MetasScreenState();
}

class _MetasScreenState extends State<MetasScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Botão para Adicionar Nova Meta
          GestureDetector(
            onTap: () async {
              final newMeta = await Navigator.of(context).push<Meta>(
                MaterialPageRoute(
                  builder: (context) => const AddEditMetaScreen(),
                ),
              );
              if (newMeta != null) {
                setState(() {
                  dummyMetas.add(newMeta);
                });
              }
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
            child: dummyMetas.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhuma meta cadastrada ainda. Que tal adicionar uma nova?',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: dummyMetas.length,
                    itemBuilder: (context, index) {
                      final meta = dummyMetas[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        child: InkWell(
                          onTap: () async {
                            final updatedMeta = await Navigator.of(context)
                                .push<Meta>(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetalheMetaScreen(meta: meta),
                                  ),
                                );
                            if (updatedMeta != null) {
                              setState(() {
                                final metaIndex = dummyMetas.indexWhere(
                                  (m) => m.id == updatedMeta.id,
                                );
                                if (metaIndex != -1) {
                                  dummyMetas[metaIndex] = updatedMeta;
                                }
                              });
                            } else {
                              setState(() {
                                dummyMetas.removeWhere((m) => m.id == meta.id);
                              });
                            }
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
