// --- IMPORTAÇÕES ---
// Pacote principal do Flutter.
import 'package:flutter/material.dart';
// Pacote para controlar o estilo da barra de status do sistema (hora, bateria, etc.).
import 'package:flutter/services.dart';
// Pacote do Firebase para verificar o status de login do usuário.
import 'package:firebase_auth/firebase_auth.dart';
// Pacote para usar funcionalidades assíncronas como o StreamSubscription.
import 'dart:async';

// Importa as telas para as quais a splash screen pode navegar.
import 'package:health_routine_coach/screens/auth/auth_screen.dart';
import 'package:health_routine_coach/screens/home_screen.dart';

// --- WIDGET DA TELA DE ABERTURA ---
// StatefulWidget porque precisa gerenciar um estado (o listener de autenticação).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// --- CLASSE DE ESTADO DA SPLASHSCREEN ---
class _SplashScreenState extends State<SplashScreen> {
  // Variável para manter uma referência ao "ouvinte" de autenticação.
  // Isso permite que a gente cancele o ouvinte para evitar vazamentos de memória.
  StreamSubscription<User?>? _authSubscription;

  // --- CICLO DE VIDA DO WIDGET ---
  @override
  // O método initState é chamado uma única vez quando o widget é criado.
  void initState() {
    super.initState();
    // Inicia a lógica de navegação assim que a tela é construída.
    _navigateToNextScreen();
  }

  @override
  // O método dispose é chamado quando o widget é destruído.
  // É crucial cancelar o listener aqui para liberar recursos.
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  // --- LÓGICA DE NAVEGAÇÃO ---
  /// Espera um tempo e depois verifica o status de login para decidir para qual tela ir.
  void _navigateToNextScreen() async {
    // Espera 3 segundos para que o logo e o nome do app fiquem visíveis.
    await Future.delayed(const Duration(seconds: 3));

    // Garante que o widget ainda está na tela antes de tentar navegar.
    if (!mounted) return;

    // Ouve a primeira mudança no estado de autenticação.
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (!mounted) return;

      // Cancela o ouvinte após o primeiro evento para não navegar múltiplas vezes.
      _authSubscription?.cancel();

      // Verifica se há um usuário logado.
      if (user == null) {
        // Se não houver usuário, navega para a tela de autenticação.
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const AuthScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(seconds: 1),
          ),
        );
      } else {
        // Se houver um usuário, navega para a tela principal.
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 700),
          ),
        );
      }
    });
  }

  // --- CONSTRUÇÃO DA INTERFACE ---
  @override
  Widget build(BuildContext context) {
    // Define o estilo da barra de status do sistema para combinar com a splash screen.
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFF5F5F5), // Cor de fundo da barra.
        statusBarIconBrightness:
            Brightness.dark, // Ícones (hora, bateria) escuros.
      ),
    );

    // Scaffold é a estrutura base da tela.
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      // Center alinha seu filho no centro da tela.
      body: Center(
        // Column organiza os widgets verticalmente.
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Centraliza a coluna na vertical.
          children: [
            // Imagem do logo do aplicativo.
            const Image(
              image: AssetImage('assets/images/logo-hrc.png'),
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 24), // Espaçamento vertical.
            // RichText permite ter texto com estilos diferentes (cores, etc.).
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(
                  fontFamily:
                      'Roboto', // Garanta que esta fonte está no seu pubspec.yaml
                  fontSize: 88,
                  fontWeight: FontWeight.bold,
                  height: 0.8, // Espaçamento entre as linhas.
                ),
                children: [
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
      ),
    );
  }
}
