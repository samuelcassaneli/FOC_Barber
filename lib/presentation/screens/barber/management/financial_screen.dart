import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import 'package:barber_premium/presentation/widgets/apple_glass_container.dart';

class FinancialScreen extends StatelessWidget {
  const FinancialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text("Financeiro"), backgroundColor: AppTheme.background),
      body: Center(
         child: AppleGlassContainer(
            child: const Text("Relatórios Financeiros em desenvolvimento", style: TextStyle(color: Colors.white)),
         ),
      ),
    );
  }
}
