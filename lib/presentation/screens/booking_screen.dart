import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../providers/booking_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/gold_button.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  int? _selectedServiceIndex;
  int? _selectedBarberIndex;
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;

  final List<String> _timeSlots = [
    "09:00", "10:00", "11:00", "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00"
  ];

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(servicesProvider);
    final barbersAsync = ref.watch(barbersProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Novo Agendamento"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Seleção de Serviço
          const Text("Selecione o Serviço", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          servicesAsync.when(
            data: (services) => SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  final isSelected = _selectedServiceIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedServiceIndex = index),
                    child: Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.accent : AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected ? null : Border.all(color: Colors.grey.withOpacity(0.2)),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.scissors, color: isSelected ? Colors.black : Colors.white, size: 30),
                          const Spacer(),
                          Text(service.name, 
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white, 
                              fontWeight: FontWeight.bold,
                              fontSize: 14
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 4),
                          Text("R\$ ${service.price}", style: TextStyle(color: isSelected ? Colors.black : Colors.grey)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text('Erro: $err'),
          ),
          
          const SizedBox(height: 30),
          
          // Seleção de Barbeiro
          const Text("Profissional", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          barbersAsync.when(
            data: (barbers) => Row(
              children: barbers.asMap().entries.map((entry) {
                final index = entry.key;
                final barber = entry.value;
                final isSelected = _selectedBarberIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedBarberIndex = index),
                  child: Container(
                    margin: const EdgeInsets.only(right: 15),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: isSelected ? AppTheme.accent : Colors.transparent, width: 2)
                          ),
                          padding: const EdgeInsets.all(3),
                          child: const CircleAvatar(
                            radius: 30,
                            backgroundColor: AppTheme.surface,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text("Barbeiro ${index + 1}", style: TextStyle(color: isSelected ? AppTheme.accent : Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text('Erro: $err'),
          ),

          const SizedBox(height: 30),

          // Seleção de Data (Simplificada)
          const Text("Data e Hora", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 7,
                      itemBuilder: (context, index) {
                        final date = DateTime.now().add(Duration(days: index));
                        final isSelected = date.day == _selectedDate.day;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedDate = date),
                          child: Container(
                            width: 60,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.accent : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(DateFormat.E('pt_BR').format(date).toUpperCase(), 
                                  style: TextStyle(color: isSelected ? Colors.black : Colors.grey, fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(date.day.toString(), 
                                  style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(color: Colors.white24, height: 30),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _timeSlots.map((time) {
                      final isSelected = _selectedTime == time;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedTime = time),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.accent : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isSelected ? AppTheme.accent : Colors.white10),
                          ),
                          child: Text(time, style: TextStyle(color: isSelected ? Colors.black : Colors.white)),
                        ),
                      );
                    }).toList(),
                  )
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),

          GoldButton(
            label: "CONFIRMAR AGENDAMENTO",
            onPressed: () {
              if (_selectedServiceIndex != null && _selectedBarberIndex != null && _selectedTime != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Agendamento realizado com sucesso!'),
                    backgroundColor: AppTheme.accent,
                  )
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor, preencha todos os campos.'))
                );
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
