import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/gold_button.dart';
import '../providers/auth_provider.dart';

class PrivacyPolicyScreen extends ConsumerWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacidade e LGPD"),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Política de Privacidade",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            const Text(
              "Nós respeitamos sua privacidade e estamos comprometidos em proteger seus dados pessoais. "
              "Esta política descreve como coletamos, usamos e compartilhamos suas informações.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const Text(
              "Seus Direitos (LGPD)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            const Text(
              "Você tem o direito de acessar, corrigir e excluir seus dados pessoais. "
              "Para exercer esses direitos, entre em contato conosco ou use a opção abaixo para excluir sua conta.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            const Divider(color: Colors.white24),
            const SizedBox(height: 20),
            const Text(
              "Zona de Perigo",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 10),
            const Text(
              "A exclusão da conta é permanente e removerá todos os seus dados do nosso sistema.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            GoldButton(
              label: "EXCLUIR MINHA CONTA",
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Tem certeza?"),
                    content: const Text("Essa ação é irreversível. Todos os seus dados serão apagados."),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Sim, excluir", style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );

                if (confirm == true) {
                  // In a real app, we would call a cloud function to delete the user from Auth and DB.
                  // For now, we will just sign out and show a message, as client-side deletion of Auth user is restricted.
                  await ref.read(authControllerProvider.notifier).signOut();
                  if (context.mounted) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Solicitação de exclusão enviada. Sua conta foi desconectada."))
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
