import 'package:barber_premium/presentation/widgets/apple_glass_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../data/services/supabase_service.dart';

final availabilityProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final client = SupabaseService().client;
  final res = await client.from('barber_availability').select().eq('barber_id', client.auth.currentUser!.id).order('day_of_week');
  return List<Map<String, dynamic>>.from(res);
});

class OpeningHoursScreen extends ConsumerStatefulWidget {
  const OpeningHoursScreen({super.key});

  @override
  ConsumerState<OpeningHoursScreen> createState() => _OpeningHoursScreenState();
}

class _OpeningHoursScreenState extends ConsumerState<OpeningHoursScreen> {
  final List<String> days = ["Domingo", "Segunda", "Terça", "Quarta", "Quinta", "Sexta", "Sábado"];
  
  // Local state to track changes before save
  Map<int, Map<String, dynamic>> _schedule = {};

  @override
  void initState() {
    super.initState();
    // Initialize default if needed
  }

  void _save(int day, TimeOfDay start, TimeOfDay end, bool isWorking) async {
     final startStr = "${start.hour.toString().padLeft(2,'0')}:${start.minute.toString().padLeft(2,'0')}";
     final endStr = "${end.hour.toString().padLeft(2,'0')}:${end.minute.toString().padLeft(2,'0')}";
     
     try {
       await SupabaseService().client.from('barber_availability').upsert({
         'barber_id': SupabaseService().client.auth.currentUser!.id,
         'day_of_week': day,
         'start_time': startStr,
         'end_time': endStr,
         'is_working_day': isWorking
       }, onConflict: 'barber_id, day_of_week');
       
       ref.refresh(availabilityProvider);
       if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Horário salvo!")));
     } catch (e) {
       if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e")));
     }
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(availabilityProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text("Horário de Atendimento"), backgroundColor: AppTheme.background),
      body: asyncData.when(
        data: (data) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: 7,
            separatorBuilder: (_,__) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
               // Find existing data for this day
               final existing = data.firstWhere((element) => element['day_of_week'] == index, orElse: () => {});
               bool isWorking = existing['is_working_day'] ?? (index != 0); // Default Sunday off
               String start = existing['start_time'] ?? "09:00";
               String end = existing['end_time'] ?? "18:00";

               return AppleGlassContainer(
                 child: Column(
                   children: [
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Text(days[index], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                         CupertinoSwitch(
                           value: isWorking,
                           onChanged: (val) => _save(index, _parseTime(start), _parseTime(end), val),
                           activeColor: AppTheme.accent,
                         )
                       ],
                     ),
                     if (isWorking) ...[
                       const Divider(color: Colors.white10),
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                         children: [
                            _buildTimePicker(context, "Abre", start, (t) => _save(index, t, _parseTime(end), true)),
                            const Icon(Icons.arrow_right_alt, color: Colors.grey),
                            _buildTimePicker(context, "Fecha", end, (t) => _save(index, _parseTime(start), t, true)),
                         ],
                       )
                     ] else 
                       const Padding(padding: EdgeInsets.only(top: 8), child: Text("Fechado", style: TextStyle(color: Colors.redAccent))),
                   ],
                 ),
               );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e,__) => Center(child: Text("Erro: $e")),
      ),
    );
  }

  TimeOfDay _parseTime(String t) {
     final parts = t.split(':');
     return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Widget _buildTimePicker(BuildContext context, String label, String time, Function(TimeOfDay) onSelect) {
     return GestureDetector(
       onTap: () async {
          final t = await showTimePicker(context: context, initialTime: _parseTime(time), builder: (context, child) => Theme(data: ThemeData.dark(), child: child!));
          if (t != null) onSelect(t);
       },
       child: Container(
         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
         decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
         child: Column(
           children: [
             Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
             Text(time.substring(0, 5), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
           ],
         ),
       ),
     );
  }
}
