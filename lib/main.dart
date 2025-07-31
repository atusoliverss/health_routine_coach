import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:health_routine_coach/firebase_options.dart';
import 'package:health_routine_coach/screens/splash_screen.dart';

void main() async {
  // Garante que o Flutter esteja inicializado antes de iniciar o Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase usando as opções geradas para a plataforma atual
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Executa o aplicativo
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Routine Coach', // Título do app
      debugShowCheckedModeBanner: false, // Remove a faixa "DEBUG"
      theme: ThemeData(
        // --- Tema Básico do seu App ---
        primarySwatch:
            Colors.blue, // Usaremos o azul padrão do Material Design como base
        scaffoldBackgroundColor: const Color(
          0xFFF5F5F5,
        ), // Cor de fundo padrão das telas
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white, // Cor padrão da barra superior
          elevation: 0, // Sem sombra na barra superior
          iconTheme: IconThemeData(
            color: Color(0xFF424242),
          ), // Cor dos ícones na barra superior
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              12,
            ), // Cantos arredondados para cards
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(
              0xFF03A9F4,
            ), // Azul dos botões principais
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF03A9F4), // Azul para TextButtons
          ),
        ),
        // Você pode adicionar mais estilos de tema aqui (cores de texto, inputs, etc.)
      ),
      home:
          const SplashScreen(), // Define a Splash Screen como a primeira tela a ser exibida
    );
  }
}
