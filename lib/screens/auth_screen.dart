// lib/screens/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importe o Firebase Auth
//import 'package:health_routine_coach/screens/home_screen.dart'; // Importe a Home Screen

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoginMode = true;
  // Use uma variável de estado separada para a visibilidade de cada campo de senha,
  // ou uma única se o comportamento for sempre o mesmo para ambos.
  // Para simplicidade e como o código original usa uma só, manteremos uma só,
  // mas idealmente seriam duas: _isPasswordVisible e _isConfirmPasswordVisible.
  bool _isPasswordVisible = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      // Limpar campos e mensagens de erro ao alternar
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _nameController.clear();
      _errorMessage = null;
      _isPasswordVisible = false; // Resetar visibilidade da senha ao alternar
    });
  }

  Future<void> _submitAuthForm() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, preencha todos os campos obrigatórios.';
      });
      return;
    }

    if (!_isLoginMode && _nameController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, insira seu nome completo.';
      });
      return;
    }

    if (!_isLoginMode &&
        _passwordController.text.trim() !=
            _confirmPasswordController.text.trim()) {
      setState(() {
        _errorMessage = 'As senhas não coincidem.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isLoginMode) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );
        await userCredential.user?.updateDisplayName(
          _nameController.text.trim(),
        );
      }
      if (mounted) {
        // Navega para a tela de destino após login/cadastro com animação
        // Substitua 'AuthScreen()' pela sua Home Screen real, por exemplo 'HomeScreen()'
        // ou 'SplashScreen()' se essa for a próxima tela após a autenticação.
        // O código original tinha AuthScreen(), mas geralmente seria a Home.
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const AuthScreen(), // Troque por sua Home Screen real!
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(
              milliseconds: 700,
            ), // Duração da animação
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Ocorreu um erro. Por favor, tente novamente.';
      if (e.code == 'weak-password') {
        message = 'A senha fornecida é muito fraca.';
      } else if (e.code == 'email-already-in-use') {
        message = 'Este e-mail já está em uso.';
      } else if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        message = 'Credenciais inválidas. Verifique seu e-mail e senha.';
      } else if (e.code == 'invalid-email') {
        message = 'O formato do e-mail é inválido.';
      }
      setState(() {
        _errorMessage = message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ocorreu um erro inesperado: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo do aplicativo
              const Image(
                image: AssetImage('assets/images/logo-hrc.png'),
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 32),

              // Título principal (Acesse sua conta / Crie sua conta)
              Text(
                _isLoginMode ? 'Acesse sua conta' : 'Crie sua conta',
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Subtítulo
              Text(
                _isLoginMode
                    ? 'Bem-vindo ao seu melhor treinador'
                    : 'Crie sua conta para começar sua jornada com o "melhor coach"!!',
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Campo Nome Completo (aparece apenas no modo de cadastro)
              if (!_isLoginMode) ...[
                TextField(
                  controller: _nameController,
                  textAlign: TextAlign.center, // Centraliza o texto digitado
                  decoration: InputDecoration(
                    hintText:
                        'Nome Completo', // Texto que aparece quando o campo está vazio
                    hintStyle: TextStyle(
                      color: Theme.of(context).hintColor,
                      fontFamily: 'Roboto',
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                    ),
                    floatingLabelBehavior:
                        FloatingLabelBehavior.never, // Mantém o hint fixo
                    border: const UnderlineInputBorder(),
                  ),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 24),
              ],

              // Campo Email
              TextField(
                controller: _emailController,
                textAlign: TextAlign.center, // Centraliza o texto digitado
                decoration: InputDecoration(
                  hintText:
                      'Email', // Texto que aparece quando o campo está vazio
                  hintStyle: TextStyle(
                    color: Theme.of(context).hintColor,
                    fontFamily: 'Roboto',
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                  ),
                  floatingLabelBehavior:
                      FloatingLabelBehavior.never, // Mantém o hint fixo
                  border: const UnderlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),

              // Campo Senha
              TextField(
                controller: _passwordController,
                textAlign: TextAlign.center, // Centraliza o texto digitado
                decoration: InputDecoration(
                  hintText:
                      'Senha', // Texto que aparece quando o campo está vazio
                  hintStyle: TextStyle(
                    color: Theme.of(context).hintColor,
                    fontFamily: 'Roboto',
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                  ),
                  floatingLabelBehavior:
                      FloatingLabelBehavior.never, // Mantém o hint fixo
                  border: const UnderlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey, // Cor do ícone
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  // *** Ajuste para centralizar o hint/texto com o suffixIcon ***
                  // O valor de 'left' (50.0) é um palpite inicial e pode precisar de ajuste fino
                  // para compensar visualmente o espaço do suffixIcon.
                  contentPadding: const EdgeInsets.fromLTRB(
                    50.0,
                    16.0,
                    0.0,
                    16.0,
                  ),
                ),
                obscureText:
                    !_isPasswordVisible, // Controlado pela variável de estado
              ),

              // Campo Confirmar Senha (aparece apenas no modo de cadastro)
              if (!_isLoginMode) ...[
                const SizedBox(height: 24),
                TextField(
                  controller: _confirmPasswordController,
                  textAlign: TextAlign.center, // Centraliza o texto digitado
                  decoration: InputDecoration(
                    hintText:
                        'Confirme a sua senha', // Texto que aparece quando o campo está vazio
                    hintStyle: TextStyle(
                      color: Theme.of(context).hintColor,
                      fontFamily: 'Roboto',
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                    ),
                    floatingLabelBehavior:
                        FloatingLabelBehavior.never, // Mantém o hint fixo
                    border: const UnderlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible // Usa a mesma variável para ambos os campos de senha
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    // *** Ajuste para centralizar o hint/texto com o suffixIcon ***
                    contentPadding: const EdgeInsets.fromLTRB(
                      50.0,
                      16.0,
                      0.0,
                      16.0,
                    ),
                  ),
                  obscureText:
                      !_isPasswordVisible, // Controlado pela variável de estado
                ),
              ],

              const SizedBox(height: 32),

              // Exibição de mensagens de erro
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Botão de Entrar/Criar conta
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitAuthForm,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(
                          50,
                        ), // Botão de largura total
                      ),
                      child: Text(
                        _isLoginMode ? 'Entrar' : 'Criar conta',
                        style: const TextStyle(
                          fontSize: 30,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
              const SizedBox(height: 24),

              // Link para alternar entre modos de login/cadastro
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLoginMode ? 'Ainda sem conta?' : 'Já possui uma conta?',
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Roboto',
                      color: Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: _toggleAuthMode,
                    child: Text(
                      _isLoginMode ? 'Criar conta' : 'Entrar',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                        color: Color(0xFF03A9F4),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
