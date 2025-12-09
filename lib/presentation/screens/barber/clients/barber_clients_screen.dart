import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/apple_glass_container.dart';

class BarberClientsScreen extends StatelessWidget {
  const BarberClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text("Clientes"), backgroundColor: AppTheme.background),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppleGlassContainer(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.surfaceSecondary,
                  child: Text("C${index+1}"),
                ),
                title: Text("Cliente ${index + 1}", style: const TextStyle(color: Colors.white)),
                subtitle: const Text("Último corte: 10/10/2024", style: TextStyle(color: Colors.grey)),
                trailing: IconButton(
                  icon: const Icon(CupertinoIcons.chat_bubble, color: Colors.green),
                  onPressed: () {},
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
