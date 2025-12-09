import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_premium/core/config/app_config.dart';
import 'package:barber_premium/core/theme/app_theme.dart';
import '../widgets/gold_button.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLogin = true;
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  void _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError("Preencha todos os campos");
      return;
    }

    if (!_isLogin && name.isEmpty) {
      _showError("Preencha o nome completo");
      return;
    }

    try {
      if (_isLogin) {
        await ref.read(authControllerProvider.notifier).signIn(email, password);
      } else {
        final role = AppConfig.isBarber ? 'barber' : 'client';
        await ref.read(authControllerProvider.notifier).signUp(email, password, name, role);
      }
    } catch (e) {
      String msg = e.toString();
      if (msg.toLowerCase().contains("email not confirmed") || msg.contains("Email not confirmed")) {
         _showError("Por favor, confirme seu email antes de fazer login.");
         return;
      }
      // Listener handles other errors, but we catch here to prevent crash
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent.withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (previous, next) {
      if (next is AsyncError) {
        String msg = next.error.toString();
        if (msg.contains("Email not confirmed")) {
           msg = "Você precisa confirmar seu email antes de entrar.";
        }
        _showError(msg);
      } else if (next is AsyncData) {
         if (!_isLogin) {
            // Sign Up Success
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                backgroundColor: const Color(0xFF1C1C1E),
                title: const Text("Conta Criada!", style: TextStyle(color: AppTheme.accent)),
                content: const Text(
                  "Enviamos um link de confirmação para o seu email. Por favor, confirme para ativar sua conta.",
                  style: TextStyle(color: Colors.white),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      setState(() {
                         _isLogin = true;
                         _passwordController.clear();
                      });
                    },
                    child: const Text("Entendi", style: TextStyle(color: AppTheme.accent)),
                  )
                ],
              )
            );
         } else {
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Bem-vindo de volta"),
                backgroundColor: Colors.green,
              ),
            );
         }
      }
    });

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState is AsyncLoading;

    return Scaffold(
      body: Stack(
        children: [
          // Minimalist Premium Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF000000), // Pure Black
                  Color(0xFF121212), // Deep Gray
                  Color(0xFF1C1C1E), // Apple Dark Gray
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          
          // Subtle Ambient Light Effect (Top Right)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accent.withOpacity(0.15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo / Icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.accent.withOpacity(0.3), width: 1),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.05),
                          Colors.transparent,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(CupertinoIcons.scissors, size: 40, color: AppTheme.accent),
                  ),
                  const SizedBox(height: 24),
                  
                  Text(
                    "BARBER PREMIUM",
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 28,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLogin ? "Acesse sua conta" : "Comece sua jornada",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.5),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Form Container
                  Column(
                    children: [
                      if (!_isLogin) ...[
                        _buildAppleInput(
                          controller: _nameController,
                          placeholder: "Nome Completo",
                          icon: CupertinoIcons.person,
                        ),
                        const SizedBox(height: 16),
                      ],
                      _buildAppleInput(
                        controller: _emailController,
                        placeholder: "Email",
                        icon: CupertinoIcons.mail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _buildAppleInput(
                        controller: _passwordController,
                        placeholder: "Senha",
                        icon: CupertinoIcons.lock,
                        isPassword: true,
                        isObscure: _obscurePassword,
                        onTogglePassword: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      const SizedBox(height: 32),
                      
                      GoldButton(
                        label: _isLogin ? "ENTRAR" : "CRIAR CONTA",
                        isLoading: isLoading,
                        onPressed: _submit,
                      ),
                      
                      const SizedBox(height: 24),
                      CupertinoButton(
                        onPressed: () => setState(() {
                           _isLogin = !_isLogin;
                           _emailController.clear();
                           _passwordController.clear();
                           _nameController.clear();
                        }),
                        child: Text(
                          _isLogin ? "Não tem conta? Cadastre-se" : "Já tem conta? Entre",
                          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppleInput({
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    bool isPassword = false,
    bool isObscure = false,
    TextInputType? keyboardType,
    VoidCallback? onTogglePassword,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? isObscure : false,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        cursorColor: AppTheme.accent,
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
          prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.4), size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isObscure ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                    color: Colors.white.withOpacity(0.4),
                    size: 20,
                  ),
                  onPressed: onTogglePassword,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}