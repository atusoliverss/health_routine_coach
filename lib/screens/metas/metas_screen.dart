// lib/screens/metas/metas_screen.dart

import 'package:flutter/material.dart';
import 'package:health_routine_coach/models/meta.dart';
import 'package:health_routine_coach/services/firestore_service.dart';
import 'package:health_routine_coach/screens/metas/add_edit_meta_screen.dart';
import 'package:health_routine_coach/screens/metas/detalhe_meta_screen.dart';
import 'package:intl/intl.dart'; // Importado para formatar a data

class MetasScreen extends StatefulWidget {
  const MetasScreen({super.key});

  @override
  State<MetasScreen> createState() => _MetasScreenState();
}

class _MetasScreenState extends State<MetasScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  // Função para construir o texto de status com a cor correspondente
  Widget _buildStatusText(MetaStatus status) {
    Color color;
    String text;
    switch (status) {
      case MetaStatus.emProgresso:
        color = Colors.orange;
        text = 'Em progresso';
        break;
      case MetaStatus.concluido:
        color = Colors.green;
        text = 'Concluída';
        break;
      case MetaStatus.expirado:
        color = Colors.red;
        text = 'Expirada';
        break;
    }
    return Text(
      text,
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ALTERAÇÃO: A tela agora usa um Scaffold para ter uma estrutura consistente.
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ALTERAÇÃO: Adicionado um título grande no topo, igual à tela de hábitos.
            const Padding(
              padding: EdgeInsets.only(top: 24.0, bottom: 16.0),
              child: Text(
                'Minhas Metas',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            // ALTERAÇÃO: O Card de "Adicionar nova meta" foi reestilizado.
            // Agora tem elevação, cor de fundo e espaçamento interno para combinar
            // com o design da tela de hábitos.
            Card(
              color: Colors.grey[200],
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push<Meta>(
                    MaterialPageRoute(
                      builder: (context) => const AddEditMetaScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 20.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Adicione uma nova meta',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      const Icon(
                        Icons.add_circle,
                        color: Color(0xFF03A9F4),
                        size: 28,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // A lógica do StreamBuilder permanece a mesma.
            Expanded(
              child: StreamBuilder<List<Meta>>(
                stream: _firestoreService.getGoalsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Erro ao carregar metas: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhuma meta cadastrada.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  final metas = snapshot.data!;
                  return ListView.builder(
                    padding: EdgeInsets.zero, // Remove o padding padrão do ListView
                    itemCount: metas.length,
                    itemBuilder: (context, index) {
                      final meta = metas[index];
                      // ALTERAÇÃO: Card da meta foi completamente reestilizado.
                      // Agora usa o mesmo padrão de cor, elevação e bordas
                      // dos cards de hábito. O conteúdo interno foi reorganizado.
                      return Card(
                        color: Colors.grey[200],
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
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
                                  // Usando DateFormat para um visual mais limpo.
                                  'Prazo: ${DateFormat('dd/MM/yyyy').format(meta.deadline)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Mostra os dias restantes apenas se a meta estiver em progresso.
                                if (meta.status == MetaStatus.emProgresso)
                                  Text(
                                    'Faltam: ${meta.daysLeft} dias',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      'Status: ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    // A lógica do status foi mantida.
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
      ),
    );
  }
}