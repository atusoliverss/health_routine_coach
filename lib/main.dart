// --- IMPORTAÇÕES ---
// Pacote principal do Flutter para construir a UI.
import 'package:flutter/material.dart';
// Pacote essencial do Firebase para inicializar o app.
import 'package:firebase_core/firebase_core.dart';
// Pacote para configurar a localização (necessária para o intl).
import 'package:flutter_localizations/flutter_localizations.dart';
// Pacote para formatação de datas.
import 'package:intl/date_symbol_data_local.dart';
// Importa a tela de abertura, que é a primeira tela do app.
import 'package:health_routine_coach/screens/splash_screen.dart';
// Importa o arquivo de configuração do Firebase gerado pelo FlutterFire CLI.
import 'firebase_options.dart';

void main() async {
  // Garante que os bindings do Flutter sejam inicializados antes de qualquer código Flutter.
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa o Firebase no projeto. É um passo obrigatório e assíncrono.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Inicializa os dados de localização para o português do Brasil (para formatar datas).
  await initializeDateFormatting('pt_BR', null);

  // Inicia a execução do widget principal do aplicativo.
  runApp(const MyApp());
}

// --- WIDGET RAIZ DO APLICATIVO ---
class MyApp extends StatelessWidget {
  // Construtor do widget.
  const MyApp({super.key});

  // O método build descreve como construir a UI do widget.
  @override
  Widget build(BuildContext context) {
    // MaterialApp é o widget base para aplicativos que seguem o Material Design.
    return MaterialApp(
      // Título do aplicativo, visível na multitarefa do sistema.
      title: 'Health Routine Coach',
      // Remove a faixa de "Debug" no canto superior direito.
      debugShowCheckedModeBanner: false,

      // --- CONFIGURAÇÕES DE LOCALIZAÇÃO ---
      // Define os delegados para a localização do app.
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Define os idiomas suportados pelo app.
      supportedLocales: const [Locale('pt', 'BR')],
      // Define o idioma padrão do app.
      locale: const Locale('pt', 'BR'),

      // --- TEMA VISUAL DO APLICATIVO ---
      theme: ThemeData(
        // Define a paleta de cores principal a partir de uma cor semente.
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF03A9F4)),
        // Habilita o uso do Material 3, o design mais recente do Google.
        useMaterial3: true,
        // Define a cor de fundo padrão para as telas.
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),

      // Define a tela inicial do aplicativo.
      home: const SplashScreen(),
    );
  }
}
