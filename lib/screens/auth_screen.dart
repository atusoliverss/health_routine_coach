// lib/screens/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_routine_coach/screens/home_screen.dart';
// NOVO: Importe a tela de redefinição de senha
import 'package:health_routine_coach/screens/auth/forgot_password_screen.dart'; // Ajuste o caminho se necessário

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoginMode = true;
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
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _nameController.clear();
      _errorMessage = null;
      _isPasswordVisible = false;
    });
  }

  Future<void> _submitAuthForm() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
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

    if (!_isLoginMode && _passwordController.text.trim() != _confirmPasswordController.text.trim()) {
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
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        await userCredential.user?.updateDisplayName(_nameController.text.trim());
      }
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 700),
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
              const Image(
                image: AssetImage('assets/images/logo-hrc.png'), // Certifique-se de que o caminho está correto
                width: 100, // Ajustado para 100 para ser mais compacto
                height: 100, // Ajustado para 100 para ser mais compacto
              ),
              const SizedBox(height: 32),
              Text(
                _isLoginMode ? 'Acesse sua conta' : 'Crie sua conta',
                style: const TextStyle(
                  fontSize: 28, // Ajustado para 28 para ser mais compacto
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _isLoginMode
                    ? 'Bem-vindo ao seu melhor treinador'
                    : 'Crie sua conta para começar sua jornada com o "melhor coach"!!',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (!_isLoginMode) ...[
                TextField(
                  controller: _nameController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'Nome Completo',
                    hintStyle: TextStyle(
                      color: Theme.of(context).hintColor,
                      fontSize: 18, // Ajustado para ser mais compacto
                      fontWeight: FontWeight.w300,
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    border: const UnderlineInputBorder(),
                  ),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 24),
              ],
              TextField(
                controller: _emailController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle: TextStyle(
                    color: Theme.of(context).hintColor,
                    fontSize: 18, // Ajustado para ser mais compacto
                    fontWeight: FontWeight.w300,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  border: const UnderlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _passwordController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Senha',
                  hintStyle: TextStyle(
                    color: Theme.of(context).hintColor,
                    fontSize: 18, // Ajustado para ser mais compacto
                    fontWeight: FontWeight.w300,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  border: const UnderlineInputBorder(),
                  suffixIcon: IconButton(
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
                  contentPadding: const EdgeInsets.fromLTRB(
                    30.0, // Ajustado para ser mais compacto
                    16.0,
                    0.0,
                    16.0,
                  ),
                ),
                obscureText: !_isPasswordVisible,
              ),
              if (!_isLoginMode) ...[
                const SizedBox(height: 24),
                TextField(
                  controller: _confirmPasswordController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'Confirme a sua senha',
                    hintStyle: TextStyle(
                      color: Theme.of(context).hintColor,
                      fontSize: 18, // Ajustado para ser mais compacto
                      fontWeight: FontWeight.w300,
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    border: const UnderlineInputBorder(),
                    suffixIcon: IconButton(
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
                    contentPadding: const EdgeInsets.fromLTRB(
                      30.0, // Ajustado para ser mais compacto
                      16.0,
                      0.0,
                      16.0,
                    ),
                  ),
                  obscureText: !_isPasswordVisible,
                ),
              ],
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
                      ),
                      child: Text(
                        _isLoginMode ? 'Entrar' : 'Criar conta',
                        style: const TextStyle(fontSize: 18), // Ajustado para ser mais compacto
                      ),
                    ),
              const SizedBox(height: 24),
              // NOVO: Link "Esqueceu a senha?"
              if (_isLoginMode) // Apenas no modo de login
                TextButton(
                  onPressed: () {
                    // Lógica de navegação para a tela de redefinição de senha
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Esqueceu sua senha?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54, // Cor mais neutra para este link
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              const SizedBox(height: 16), // Espaçamento adicional se o link de senha estiver presente
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLoginMode ? 'Ainda sem conta?' : 'Já possui uma conta?',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  TextButton(
                    onPressed: _toggleAuthMode,
                    child: Text(
                      _isLoginMode ? 'Criar conta' : 'Entrar',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).primaryColor,
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