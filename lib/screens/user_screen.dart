import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_routine_coach/screens/auth/auth_screen.dart';

// --- WIDGET DA TELA DE PERFIL DO USUÁRIO ---
class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  // --- VARIÁVEIS DE ESTADO ---
  // Guardam as informações do usuário para exibir na tela.
  String _userName = 'Usuário';
  String _userEmail = 'email_nao_disponivel';
  String _appStartDate = '25 de Julho de 2025'; // Valor de exemplo

  @override
  void initState() {
    super.initState();
    // Pega o usuário atualmente logado no Firebase.
    final user = FirebaseAuth.instance.currentUser;
    // Se houver um usuário, atualiza as variáveis de estado com seus dados.
    if (user != null) {
      _userName = user.displayName ?? 'Usuário';
      _userEmail = user.email ?? 'email_nao_disponivel';
      // TODO: A data de início ("Membro desde") deve ser buscada do documento do usuário no Firestore.
    }
  }

  /// Função para fazer logout do usuário.
  Future<void> _logout() async {
    // Desconecta o usuário do Firebase.
    await FirebaseAuth.instance.signOut();
    // Se o widget ainda estiver na tela, navega para a tela de autenticação.
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
        (Route<dynamic> route) =>
            false, // Remove todas as telas anteriores da pilha.
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        // Column organiza os widgets verticalmente.
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.center, // Centraliza os itens horizontalmente.
          children: [
            // Ícone grande de perfil.
            const Icon(Icons.account_circle, size: 100, color: Colors.grey),
            const SizedBox(height: 16),
            // Nome do usuário.
            Text(
              _userName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Email do usuário.
            Text(
              _userEmail,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            // Card com informações adicionais.
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.grey),
                    const SizedBox(width: 16),
                    Text('Membro desde: $_appStartDate'),
                  ],
                ),
              ),
            ),
            // Spacer ocupa todo o espaço vertical disponível, empurrando o botão para baixo.
            const Spacer(),
            // Botão de sair.
            ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('SAIR'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white, // Cor do texto e do ícone.
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
