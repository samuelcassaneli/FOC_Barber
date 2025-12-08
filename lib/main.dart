import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'data/services/supabase_service.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/auth_screen.dart';
import 'presentation/screens/main_layout.dart';

import 'presentation/screens/admin/admin_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  
  await SupabaseService().initialize();

  runApp(const ProviderScope(child: BarberPremiumApp()));
}

class BarberPremiumApp extends ConsumerWidget {
  const BarberPremiumApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'BarberPremium',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: authState.when(
        data: (user) {
          if (user == null) return const AuthScreen();
          if (user.email == 'aiucmt.kiaaivmtq@gmail.com') {
            return const AdminDashboardScreen();
          }
          return const MainLayout();
        },
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (err, stack) => Scaffold(body: Center(child: Text('Erro: $err'))),
      ),
    );
  }
}
