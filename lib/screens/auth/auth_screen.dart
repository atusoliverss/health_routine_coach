// lib/screens/auth/auth_screen.dart

// --- IMPORTAÇÕES ---
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_routine_coach/screens/home_screen.dart';
import 'package:health_routine_coach/screens/auth/forgot_password_screen.dart';

// --- WIDGET DA TELA DE AUTENTICAÇÃO ---
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

// --- CLASSE DE ESTADO DA AUTHSCREEN ---
class _AuthScreenState extends State<AuthScreen> {
  // --- ESTADO DO WIDGET ---
  bool _isLoginMode =
      true; // Controla se a tela está em modo Login ou Cadastro.
  bool _isPasswordVisible = false; // Controla a visibilidade da senha.
  bool _isLoading = false; // Controla a exibição do spinner de carregamento.
  String? _errorMessage; // Armazena mensagens de erro para o usuário.

  // --- CONTROLADORES DE TEXTO ---
  // Gerenciam o conteúdo dos campos de texto.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  // Libera os recursos dos controladores quando a tela é destruída.
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE NEGÓCIO ---

  /// Alterna a UI entre os modos de login e cadastro.
  void _toggleAuthMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      // Limpa os campos para uma nova entrada.
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _nameController.clear();
      _errorMessage = null;
      _isPasswordVisible = false;
    });
  }

  /// Processa o envio do formulário, valida e chama o Firebase.
  Future<void> _submitAuthForm() async {
    // 1. Validações dos campos.
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      setState(
        () =>
            _errorMessage = 'Por favor, preencha todos os campos obrigatórios.',
      );
      return;
    }
    if (!_isLoginMode && _nameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Por favor, insira seu nome completo.');
      return;
    }
    if (!_isLoginMode &&
        _passwordController.text.trim() !=
            _confirmPasswordController.text.trim()) {
      setState(() => _errorMessage = 'As senhas não coincidem.');
      return;
    }

    // 2. Prepara a UI para a operação de rede.
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isLoginMode) {
        // Lógica de Login
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        // Lógica de Cadastro
        // 1. Cria o usuário no Firebase Authentication.
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );
        // 2. Atualiza o nome de exibição na autenticação.
        await userCredential.user?.updateDisplayName(
          _nameController.text.trim(),
        );
        // 3. Cria o documento do usuário no Firestore.
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
              'name': _nameController.text.trim(),
              'email': _emailController.text.trim(),
              'createdAt': Timestamp.now(),
              'currentStreak': 0,
            });
      }

      // 4. Navega para a HomeScreen com uma transição de Fade.
      if (mounted) {
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
    } on FirebaseAuthException catch (e) {
      // 5. Trata erros específicos do Firebase.
      String message = 'Ocorreu um erro. Por favor, tente novamente.';
      if (e.code == 'weak-password')
        message = 'A senha fornecida é muito fraca.';
      else if (e.code == 'email-already-in-use')
        message = 'Este e-mail já está em uso.';
      else if (e.code == 'user-not-found' || e.code == 'wrong-password')
        message = 'Credenciais inválidas.';
      else if (e.code == 'invalid-email')
        message = 'O formato do e-mail é inválido.';
      setState(() => _errorMessage = message);
    } catch (e) {
      setState(() => _errorMessage = 'Ocorreu um erro inesperado: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- MÉTODOS DE CONSTRUÇÃO DE WIDGETS (REUTILIZÁVEIS) ---

  /// Constrói um campo de texto padrão.
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.center,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        border: const UnderlineInputBorder(),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
      ),
      keyboardType: keyboardType,
    );
  }

  /// Constrói um campo de senha com ícone de visibilidade.
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return Stack(
      alignment: Alignment.centerRight,
      children: <Widget>[
        TextField(
          controller: controller,
          textAlign: TextAlign.center,
          cursorColor: Colors.black,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.grey),
            border: const UnderlineInputBorder(),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
          ),
          obscureText: !_isPasswordVisible,
        ),
        IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ],
    );
  }

  // --- MÉTODO PRINCIPAL DE CONSTRUÇÃO DA UI ---
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
              const Image(
                image: AssetImage('assets/images/logo-hrc.png'),
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 32),
              Text(
                _isLoginMode ? 'Acesse sua conta' : 'Crie sua conta',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _isLoginMode
                    ? 'Bem-vindo ao seu melhor treinador'
                    : 'Crie sua conta para começar sua jornada!',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Animação para os campos de cadastro.
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: !_isLoginMode
                    ? Column(
                        key: const ValueKey('name_field'),
                        children: [
                          _buildTextField(
                            controller: _nameController,
                            hintText: 'Nome Completo',
                          ),
                          const SizedBox(height: 24),
                        ],
                      )
                    : const SizedBox(key: ValueKey('empty_name')),
              ),

              _buildTextField(
                controller: _emailController,
                hintText: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              _buildPasswordField(
                controller: _passwordController,
                hintText: 'Senha',
              ),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: !_isLoginMode
                    ? Column(
                        key: const ValueKey('confirm_password_field'),
                        children: [
                          const SizedBox(height: 24),
                          _buildPasswordField(
                            controller: _confirmPasswordController,
                            hintText: 'Confirme a sua senha',
                          ),
                        ],
                      )
                    : const SizedBox(key: ValueKey('empty_confirm_password')),
              ),

              const SizedBox(height: 32),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitAuthForm,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: const Color(0xFF03A9F4),
                      ),
                      child: Text(
                        _isLoginMode ? 'Entrar' : 'Criar conta',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
              const SizedBox(height: 16),

              if (_isLoginMode)
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ForgotPasswordScreen(),
                    ),
                  ),
                  child: const Text(
                    'Esquecer a senha?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLoginMode
                        ? 'Ainda não tem conta?'
                        : 'Já possui uma conta?',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  TextButton(
                    onPressed: _toggleAuthMode,
                    child: Text(
                      _isLoginMode ? 'Criar conta' : 'Entrar',
                      style: TextStyle(
                        fontSize: 16,
                        color: const Color(0xFF03A9F4),
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
