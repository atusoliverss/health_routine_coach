// lib/screens/metas/metas_screen.dart

// --- IMPORTAÇÕES ---
import 'package:flutter/material.dart';
// Importa o modelo de dados para Meta.
import 'package:health_routine_coach/models/meta.dart';
// Importa o serviço que se comunica com o Firestore.
import 'package:health_routine_coach/services/firestore_service.dart';
// Importa as telas de adicionar/editar e de detalhes da meta.
import 'package:health_routine_coach/screens/metas/add_edit_meta_screen.dart';
import 'package:health_routine_coach/screens/metas/detalhe_meta_screen.dart';
import 'package:intl/intl.dart'; // Importado para formatar a data.

// --- WIDGET DA TELA DE METAS ---
// StatefulWidget porque seu conteúdo (a lista de metas) pode mudar.
class MetasScreen extends StatefulWidget {
  const MetasScreen({super.key});

  @override
  State<MetasScreen> createState() => _MetasScreenState();
}

// --- CLASSE DE ESTADO DA TELA DE METAS ---
class _MetasScreenState extends State<MetasScreen> {
  // Instância do serviço que se comunica com o Firestore.
  final FirestoreService _firestoreService = FirestoreService();

  /// Constrói um widget de Texto com cor e estilo baseados no status da meta.
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

  // --- CONSTRUÇÃO DA INTERFACE ---
  @override
  Widget build(BuildContext context) {
    // Scaffold fornece a estrutura base da tela.
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        // Column organiza os widgets verticalmente.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título grande da página.
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
            // Card que funciona como um botão para adicionar uma nova meta.
            Card(
              color: Colors.grey[200],
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  // Navega para a tela de adicionar/editar meta.
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

            // Lista de metas que se atualiza em tempo real.
            Expanded(
              // StreamBuilder ouve as mudanças na coleção de metas do Firestore.
              child: StreamBuilder<List<Meta>>(
                stream: _firestoreService.getGoalsStream(),
                builder: (context, snapshot) {
                  // Enquanto os dados estão carregando.
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // Se ocorrer um erro.
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Erro ao carregar metas: ${snapshot.error}'),
                    );
                  }
                  // Se não houver dados (lista vazia).
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhuma meta cadastrada.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  // Se os dados foram carregados com sucesso.
                  final metas = snapshot.data!;
                  // ListView.builder constrói a lista de forma eficiente.
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: metas.length,
                    itemBuilder: (context, index) {
                      final meta = metas[index];
                      return Card(
                        color: Colors.grey[200],
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            // Navega para a tela de detalhes da meta selecionada.
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
