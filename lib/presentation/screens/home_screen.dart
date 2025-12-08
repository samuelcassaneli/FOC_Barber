import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/glass_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            backgroundColor: AppTheme.background,
            title: Text("Olá, Cliente", style: AppTheme.darkTheme.textTheme.displayLarge?.copyWith(fontSize: 28)),
            actions: [
              IconButton(
                icon: const Icon(CupertinoIcons.bell, color: Colors.white),
                onPressed: () {},
              ),
              const CircleAvatar(
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
                radius: 18,
              ),
              const SizedBox(width: 16),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cartão de Fidelidade
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1C1C1E), Color(0xFF2C2C2E)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("LOYALTY CARD", style: TextStyle(color: AppTheme.accent, letterSpacing: 2, fontWeight: FontWeight.bold)),
                            Icon(Icons.stars, color: AppTheme.accent),
                          ],
                        ),
                        const Text("7 / 10 Cortes", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                        LinearProgressIndicator(
                          value: 0.7,
                          backgroundColor: Colors.black,
                          color: AppTheme.accent,
                          borderRadius: BorderRadius.circular(10),
                          minHeight: 8,
                        ),
                        Text("Faltam 3 cortes para o próximo grátis!", style: AppTheme.darkTheme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Próximo Agendamento
                  const Text("Próximo Agendamento", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  GlassCard(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withOpacity(0.2),
                          shape: BoxShape.circle
                        ),
                        child: const Icon(CupertinoIcons.time, color: AppTheme.accent),
                      ),
                      title: const Text("Hoje, 19:00", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: const Text("Corte Premium com Rafael", style: TextStyle(color: Colors.grey)),
                      trailing: const Icon(CupertinoIcons.chevron_right, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
