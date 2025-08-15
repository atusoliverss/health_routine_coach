// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para controlar o estilo da barra de status
import 'package:firebase_auth/firebase_auth.dart'; // Para verificar o status de login do Firebase
import 'dart:async'; // Para usar o Future.delayed e o listen

import 'package:health_routine_coach/screens/auth_screen.dart';
import 'package:health_routine_coach/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // NOVO: Adicionado um StreamSubscription para poder cancelar o listener.
  // Isso é uma boa prática para evitar vazamentos de memória.
  StreamSubscription<User?>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  // NOVO: Cancela o listener quando o widget é descartado.
  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void _navigateToNextScreen() async {
    // Adiciona um atraso para a splash screen ser visível por um tempo.
    await Future.delayed(const Duration(seconds: 3));

    // Garante que o widget ainda está na "árvore" de widgets antes de navegar.
    if (!mounted) return;

    // A lógica de navegação foi simplificada. O StreamBuilder no main.dart já faz isso de forma mais eficiente.
    // A splash screen agora apenas espera e navega para uma tela de "decisão".
    // Para manter sua lógica original, vamos usar um listener uma única vez.
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (!mounted) return;

      // Cancela o listener após o primeiro evento para não navegar múltiplas vezes.
      _authSubscription?.cancel();

      if (user == null) {
        // Usuário não logado, navega para a tela de autenticação.
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
        // Usuário logado, navega para a Home Screen.
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

  @override
  Widget build(BuildContext context) {
    // Define o estilo da barra de status para combinar com a splash screen.
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFF5F5F5), // Cor de fundo da splash.
        statusBarIconBrightness:
            Brightness.dark, // Ícones (wifi, bateria) escuros.
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Cor de fundo.
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Image(
              image: AssetImage('assets/images/logo-hrc.png'),
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 24), // Espaçamento.
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                // O estilo padrão é herdado pelos filhos.
                style: TextStyle(
                  fontFamily:
                      'Roboto', // Garanta que esta fonte está no seu pubspec.yaml
                  fontSize: 88,
                  fontWeight: FontWeight.bold,
                  height: 0.8,
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
