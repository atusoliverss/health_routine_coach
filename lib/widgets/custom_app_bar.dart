// lib/widgets/custom_app_bar.dart

// --- IMPORTAÇÕES ---
import 'package:flutter/material.dart';
// Importa a tela de usuário para a navegação do ícone de perfil.
import '../screens/user_screen.dart';

// --- WIDGET DA APPBAR PERSONALIZADA ---
/// Um widget de AppBar personalizado e reutilizável para o aplicativo.
/// Implementa `PreferredSizeWidget` para que possa ser usado na propriedade `appBar` de um Scaffold.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  // --- PROPRIEDADES ---
  /// O nome do usuário a ser exibido na saudação.
  final String userName;

  /// A altura desejada para a AppBar.
  final double height;

  // --- CONSTRUTOR ---
  const CustomAppBar({
    super.key,
    required this.userName,
    this.height = 120.0, // Altura padrão de 120.
  });

  // --- CONSTRUÇÃO DA INTERFACE ---
  @override
  Widget build(BuildContext context) {
    // Usamos um Container para ter controle total sobre o design.
    return Container(
      color: const Color(0xFFF5F5F5), // Cor de fundo da AppBar.
      margin: const EdgeInsets.fromLTRB(
        8,
        8,
        8,
        12,
      ), // Margem para criar o efeito "flutuante".
      // SafeArea garante que o conteúdo não fique sob entalhes ou a barra de status do sistema.
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          // Row organiza os elementos horizontalmente.
          child: Row(
            mainAxisAlignment: MainAxisAlignment
                .spaceBetween, // Espaça os itens nas extremidades.
            crossAxisAlignment: CrossAxisAlignment
                .center, // Alinha os itens verticalmente ao centro.
            children: [
              // --- Lado Esquerdo: Logo e Nome do App ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Imagem do logo.
                  const Image(
                    image: AssetImage('assets/images/logo-hrc.png'),
                    width: 70,
                    height: 70,
                  ),
                  const SizedBox(width: 12), // Espaçamento.
                  // RichText permite ter texto com estilos diferentes.
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        height: 1.2,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Health\n',
                          style: TextStyle(color: Color(0xFF12855B)),
                        ),
                        TextSpan(
                          text: 'Routine\nCoach',
                          style: TextStyle(color: Color(0xFF03A9F4)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // --- Lado Direito: Saudação e Ícone de Perfil ---
              // GestureDetector torna a área clicável.
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const UserScreen()),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Saudação ao usuário.
                    Text(
                      'Olá, ${userName.split(' ').first}!',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12), // Espaçamento.
                    // Ícone de perfil.
                    const Icon(
                      Icons.account_circle,
                      color: Colors.black54,
                      size: 60,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Define o tamanho preferido do widget, que é necessário para a `AppBar`.
  @override
  Size get preferredSize => Size.fromHeight(height);
}
