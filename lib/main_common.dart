import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/config/app_config.dart';
import 'data/services/supabase_service.dart';
import 'main.dart'; // Import BarberPremiumApp

void mainCommon(AppFlavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  await dotenv.load(fileName: ".env");
  
  await SupabaseService().initialize();
  
  AppConfig.setFlavor(flavor);

  runApp(const ProviderScope(child: BarberPremiumApp()));
}
