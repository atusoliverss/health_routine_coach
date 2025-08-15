// lib/widgets/custom_app_bar.dart

import 'package:flutter/material.dart';
// Importa a tela de usuário para a navegação do ícone de perfil.
import '../screens/user_screen.dart';

/// Um widget de AppBar personalizado e reutilizável para o aplicativo.
/// Implementa `PreferredSizeWidget` para que possa ser usado na propriedade `appBar` de um Scaffold.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// O nome do usuário a ser exibido na saudação.
  final String userName;

  /// A altura desejada para a AppBar.
  final double height;

  const CustomAppBar({
    super.key,
    required this.userName,
    this.height = 120.0, // Altura padrão de 120.
  });

  @override
  Widget build(BuildContext context) {
    // Usamos um Container para ter controle total sobre o design.
    return Container(
      color: const Color(0xFFF5F5F5), // Cor de fundo da AppBar.
      // SafeArea garante que o conteúdo não fique sob entalhes ou a barra de status do sistema.
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- Lado Esquerdo: Logo e Nome do App ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Image(
                    image: AssetImage('assets/images/logo-hrc.png'),
                    width: 70,
                    height: 70,
                  ),
                  const SizedBox(width: 12),
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
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const UserScreen()),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Olá, ${userName.split(' ').first}!',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
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
