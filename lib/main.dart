import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/app_config.dart';
import 'package:barber_premium/core/theme/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/auth_screen.dart';
import 'presentation/screens/main_layout.dart';
import 'presentation/screens/barber/barber_main_layout.dart';
import 'presentation/screens/admin/admin_dashboard_screen.dart';
import 'main_common.dart';

void main() {
  // Default for development if run without -t
  mainCommon(AppFlavor.client);
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
          
          // Admin Check (Hardcoded for now as per previous code)
          if (user.email == 'aiucmt.kiaaivmtq@gmail.com') {
            return const AdminDashboardScreen();
          }

          // Flavor based routing
          if (AppConfig.isBarber) {
             return const BarberMainLayout();
          } else {
             return const MainLayout(); // Client Layout
          }
        },
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (err, stack) => Scaffold(body: Center(child: Text('Erro: $err'))),
      ),
    );
  }
}
