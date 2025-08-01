// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para controlar o estilo da barra de status
import 'package:firebase_auth/firebase_auth.dart'; // Para verificar o status de login do Firebase

import 'package:health_routine_coach/screens/auth_screen.dart';
//import 'package:health_routine_coach/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  _navigateToNextScreen() async {
    // Adiciona um pequeno atraso inicial para garantir que a UI da splash screen seja exibida por um tempo mínimo antes da navegação do Firebase ser acionada.
    await Future.delayed(const Duration(seconds: 5));

    // Escuta as mudanças no estado de autenticação do Firebase para verificar se o usuário já está logado.
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (!mounted) return; // Garante que o widget ainda está montado

      if (user == null) {
        // Usuário não logado, navega para a tela de autenticação com animação
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
        // Usuário logado, navega para a Home Screen com animação
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const SplashScreen(), // Se SplashScreen é sua Home Screen principal
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation, // Anima a opacidade da tela de 0 a 1
                    child: child,
                  );
                },
            transitionDuration: const Duration(milliseconds: 700),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define o estilo da barra de status
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(
          0xFFF5F5F5,
        ), // Cor de fundo da sua splash (f5f5f5)
        statusBarIconBrightness:
            Brightness.dark, // Ícones (wifi, bateria) em cor escura
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Cor de fundo #f5f5f5
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Image(
              image: AssetImage('assets/images/logo-hrc.png'),
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 24), // Espaçamento entre a logo e o texto
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Health\n',
                    style: TextStyle(
                      color: Color(0xFF12855B),
                      fontFamily: 'Roboto',
                      fontSize: 88,
                      fontWeight: FontWeight.bold,
                      height: 0.8,
                    ),
                  ),
                  TextSpan(
                    text: 'Routine\nCoach',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      color: Color(0xFF03A9F4),
                      fontSize: 88,
                      fontWeight: FontWeight.bold,
                      height: 0.8,
                    ),
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
