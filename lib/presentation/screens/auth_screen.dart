import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/gold_button.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLogin = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  void _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha todos os campos")),
      );
      return;
    }

    if (!_isLogin && name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha o nome completo")),
      );
      return;
    }

    if (_isLogin) {
      await ref.read(authControllerProvider.notifier).signIn(email, password);
    } else {
      await ref.read(authControllerProvider.notifier).signUp(email, password, name);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error.toString())),
        );
      } else if (next is AsyncData) {
        // Navigation will be handled by listening to authState changes in main app router
        // But for now we can show success
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isLogin ? "Login realizado!" : "Conta criada!")),
        );
      }
    });

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState is AsyncLoading;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://images.unsplash.com/photo-1585747860715-2ba37e788b70?q=80&w=2074&auto=format&fit=crop'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "BARBER PREMIUM",
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 32,
                    color: AppTheme.accent,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 40),
                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          _isLogin ? "Bem-vindo de volta" : "Crie sua conta",
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
                        ),
                        const SizedBox(height: 24),
                        if (!_isLogin) ...[
                          _buildTextField(_nameController, "Nome Completo", Icons.person),
                          const SizedBox(height: 16),
                        ],
                        _buildTextField(_emailController, "Email", Icons.email),
                        const SizedBox(height: 16),
                        _buildTextField(_passwordController, "Senha", Icons.lock, isPassword: true),
                        const SizedBox(height: 24),
                        GoldButton(
                          label: _isLogin ? "ENTRAR" : "CRIAR CONTA",
                          isLoading: isLoading,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => setState(() => _isLogin = !_isLogin),
                          child: Text(
                            _isLogin ? "Não tem conta? Cadastre-se" : "Já tem conta? Entre",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.accent),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        labelStyle: const TextStyle(color: Colors.grey),
      ),
    );
  }
}
