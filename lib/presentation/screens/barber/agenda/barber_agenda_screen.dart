import 'package:barber_premium/presentation/providers/real_data_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/apple_glass_container.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../data/services/supabase_service.dart';

class BarberAgendaScreen extends ConsumerStatefulWidget {
  const BarberAgendaScreen({super.key});

  @override
  ConsumerState<BarberAgendaScreen> createState() => _BarberAgendaScreenState();
}

class _BarberAgendaScreenState extends ConsumerState<BarberAgendaScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  Future<void> _openWhatsApp(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    const message = "Olá! Aqui é da Barber Premium. Confirmando seu agendamento.";
    final url = Uri.parse("https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}");

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
       // fallback
    }
  }

  void _editBooking(Map<String, dynamic> booking) async {
    DateTime current = DateTime.parse(booking['booking_date']);
    DateTime? newDate;
    TimeOfDay? newTime;

    // Pick Date
    newDate = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(data: ThemeData.dark(), child: child!),
    );

    if (newDate != null) {
      if (mounted) {
         newTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(current),
            builder: (context, child) => Theme(data: ThemeData.dark(), child: child!),
         );
      }
    }

    if (newDate != null && newTime != null) {
       final finalDateTime = DateTime(newDate.year, newDate.month, newDate.day, newTime.hour, newTime.minute);
       
       try {
         await SupabaseService().client.from('bookings').update({
            'booking_date': finalDateTime.toIso8601String()
         }).eq('id', booking['id']);
         
         // Notify Client
         await SupabaseService().client.from('notifications').insert({
            'user_id': booking['client_id'],
            'title': 'Agendamento Alterado',
            'message': 'Seu agendamento foi alterado para ${DateFormat('dd/MM HH:mm').format(finalDateTime)}',
            'read': false,
         });

         if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Agendamento atualizado e cliente notificado!")));
       } catch (e) {
         if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e")));
       }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch bookings for the selected day
    final dayBookings = ref.watch(bookingsForDayProvider(_selectedDay!));

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("Minha Agenda"),
        backgroundColor: AppTheme.background,
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.add),
            onPressed: () {
               // Manual booking logic (TODO)
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Novo agendamento manual (Em Breve)")));
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Calendar
          AppleGlassContainer(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            child: TableCalendar(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              calendarStyle: const CalendarStyle(
                defaultTextStyle: TextStyle(color: Colors.white),
                weekendTextStyle: TextStyle(color: Colors.white70),
                selectedDecoration: BoxDecoration(
                  color: AppTheme.accent,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppTheme.surfaceSecondary,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Bookings List
          Expanded(
            child: dayBookings.isEmpty 
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.calendar_today, size: 48, color: Colors.white.withOpacity(0.2)),
                      const SizedBox(height: 16),
                      Text(
                        "Sem agendamentos",
                        style: TextStyle(color: Colors.white.withOpacity(0.5)),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: dayBookings.length,
                  itemBuilder: (context, index) {
                    final booking = dayBookings[index];
                    final date = DateTime.parse(booking['booking_date']);
                    
                    return GestureDetector(
                      onTap: () => _editBooking(booking),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AppleGlassContainer(
                          child: Row(
                            children: [
                              // Time
                              Column(
                                children: [
                                  Text(
                                    DateFormat('HH:mm').format(date),
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Container(width: 1, height: 40, color: Colors.white10),
                              const SizedBox(width: 16),
                              
                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      booking['client_name'] ?? 'Cliente', // Assuming join or embedded data
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      booking['service_name'] ?? 'Serviço',
                                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // WhatsApp Action
                              IconButton(
                                icon: const Icon(CupertinoIcons.chat_bubble_2_fill, color: Colors.green),
                                onPressed: () => _openWhatsApp("5511999999999"), // Placeholder phone until we fetch it
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}
