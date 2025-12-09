import 'package:barber_premium/presentation/providers/real_data_provider.dart';
import 'package:barber_premium/presentation/providers/management_provider.dart';
import 'package:barber_premium/presentation/screens/barber/management/services_screen.dart';
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

  // ... WhatsApp logic (keep existing)
  Future<void> _openWhatsApp(String phone) async {
    // ... (Same as before)
  }

  // Manual Booking Sheet
  void _showManualBookingSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _ManualBookingForm(selectedDate: _selectedDay ?? DateTime.now()),
    );
  }

  // Block Specific Time
  void _showBlockTimeSheet() {
    final startController = TextEditingController();
    final endController = TextEditingController();
    TimeOfDay start = TimeOfDay(hour: 12, minute: 0);
    TimeOfDay end = TimeOfDay(hour: 13, minute: 0);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: 350,
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Bloquear Horário", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Isso impedirá agendamentos neste intervalo.", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                       final t = await showTimePicker(context: context, initialTime: start, builder: (context, child) => Theme(data: ThemeData.dark(), child: child!));
                       if (t != null) start = t;
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                      child: const Center(child: Text("Início", style: TextStyle(color: Colors.white))),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                       final t = await showTimePicker(context: context, initialTime: end, builder: (context, child) => Theme(data: ThemeData.dark(), child: child!));
                       if (t != null) end = t;
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                      child: const Center(child: Text("Fim", style: TextStyle(color: Colors.white))),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton.filled(
                child: const Text("Bloquear"),
                onPressed: () async {
                   final date = _selectedDay ?? DateTime.now();
                   final startDt = DateTime(date.year, date.month, date.day, start.hour, start.minute);
                   
                   // Create a 'blocked' booking
                   await SupabaseService().client.from('bookings').insert({
                      'barber_id': SupabaseService().client.auth.currentUser!.id,
                      'booking_date': startDt.toIso8601String(),
                      'status': 'blocked',
                      'service_name': 'Bloqueado',
                      'client_name': 'Indisponível'
                   });
                   
                   Navigator.pop(ctx);
                   ref.refresh(bookingsProvider);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  // Unblock / Delete Booking
  void _deleteBooking(String id) async {
     await SupabaseService().client.from('bookings').delete().eq('id', id);
     ref.refresh(bookingsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final dayBookings = ref.watch(bookingsForDayProvider(_selectedDay!));

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("Minha Agenda"),
        backgroundColor: AppTheme.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.access_time_filled, color: Colors.orange),
            tooltip: "Bloquear Horário",
            onPressed: _showBlockTimeSheet,
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.add),
            tooltip: "Agendar Manualmente",
            onPressed: _showManualBookingSheet,
          )
        ],
      ),
      body: Column(
        children: [
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
              onFormatChanged: (format) => setState(() => _calendarFormat = format),
              calendarStyle: const CalendarStyle(
                defaultTextStyle: TextStyle(color: Colors.white),
                weekendTextStyle: TextStyle(color: Colors.white70),
                selectedDecoration: BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle),
                todayDecoration: BoxDecoration(color: AppTheme.surfaceSecondary, shape: BoxShape.circle),
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
          Expanded(
            child: dayBookings.isEmpty 
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.calendar_today, size: 48, color: Colors.white.withOpacity(0.2)),
                      const SizedBox(height: 16),
                      Text("Livre", style: TextStyle(color: Colors.white.withOpacity(0.5))),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: dayBookings.length,
                  itemBuilder: (context, index) {
                    final booking = dayBookings[index];
                    final date = DateTime.parse(booking['booking_date']);
                    final isBlocked = booking['status'] == 'blocked';
                    
                    return Dismissible(
                      key: Key(booking['id']),
                      direction: DismissDirection.endToStart,
                      background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
                      confirmDismiss: (_) async => await showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppTheme.surface,
                          title: const Text("Excluir?", style: TextStyle(color: Colors.white)),
                          content: Text(isBlocked ? "Desbloquear horário?" : "Cancelar agendamento?", style: const TextStyle(color: Colors.grey)),
                          actions: [
                            TextButton(child: const Text("Não"), onPressed: () => Navigator.pop(ctx, false)),
                            TextButton(child: const Text("Sim", style: TextStyle(color: Colors.red)), onPressed: () => Navigator.pop(ctx, true)),
                          ],
                        )
                      ),
                      onDismissed: (_) => _deleteBooking(booking['id']),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AppleGlassContainer(
                          child: Row(
                            children: [
                              Column(
                                children: [
                                  Text(DateFormat('HH:mm').format(date), style: TextStyle(color: isBlocked ? Colors.red : Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Container(width: 1, height: 40, color: Colors.white10),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(booking['client_name'] ?? 'Cliente', style: TextStyle(color: isBlocked ? Colors.redAccent : Colors.white, fontWeight: FontWeight.w600)),
                                    Text(booking['service_name'] ?? 'Serviço', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                                  ],
                                ),
                              ),
                              if (!isBlocked)
                                IconButton(icon: const Icon(CupertinoIcons.chat_bubble_2_fill, color: Colors.green), onPressed: () {}),
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

// INTERNAL WIDGET FOR MANUAL BOOKING
class _ManualBookingForm extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  const _ManualBookingForm({required this.selectedDate});

  @override
  ConsumerState<_ManualBookingForm> createState() => _ManualBookingFormState();
}

class _ManualBookingFormState extends ConsumerState<_ManualBookingForm> {
  Map<String, dynamic>? _selectedClient;
  Map<String, dynamic>? _selectedService;
  TimeOfDay _time = TimeOfDay.now();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(myClientsProvider);
    final servicesAsync = ref.watch(servicesProvider);
    
    // Watch Subscription if client selected
    final subAsync = _selectedClient == null 
        ? const AsyncValue.data(null) 
        : ref.watch(clientSubscriptionProvider(_selectedClient!['id']));

    double finalPrice = _selectedService?['price'] ?? 0.0;
    bool hasActivePlan = false;

    if (subAsync.asData?.value != null) {
       hasActivePlan = true;
       finalPrice = 0.0; // Plan covers it
    }

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: AppleGlassContainer(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        opacity: 0.95,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Novo Agendamento", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              
              // Client Selector
              const Text("Cliente", style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 8),
              clientsAsync.when(
                data: (clients) => GestureDetector(
                  onTap: () => _showSelectionSheet(context, "Selecione o Cliente", clients, (c) => setState(() => _selectedClient = c)),
                  child: _buildDropdownDisplay(_selectedClient?['full_name'] ?? "Selecionar Cliente"),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_,__) => const Text("Erro ao carregar clientes", style: TextStyle(color: Colors.red)),
              ),
              const SizedBox(height: 16),

              // Service Selector
              const Text("Serviço", style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 8),
              servicesAsync.when(
                data: (services) => GestureDetector(
                  onTap: () => _showSelectionSheet(context, "Selecione o Serviço", services, (s) => setState(() => _selectedService = s)),
                  child: _buildDropdownDisplay(_selectedService?['name'] ?? "Selecionar Serviço"),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_,__) => const Text("Erro ao carregar serviços", style: TextStyle(color: Colors.red)),
              ),
              const SizedBox(height: 16),

              // Time Selector
              const Text("Horário", style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                   final t = await showTimePicker(context: context, initialTime: _time, builder: (context, child) => Theme(data: ThemeData.dark(), child: child!));
                   if (t != null) setState(() => _time = t);
                },
                child: _buildDropdownDisplay("${_time.hour}:${_time.minute.toString().padLeft(2,'0')}"),
              ),
              const SizedBox(height: 24),

              // Price Summary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Valor Final:", style: TextStyle(color: Colors.white, fontSize: 16)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (hasActivePlan)
                        Text("Plano Ativo (${subAsync.asData!.value!['plans']['name']})", style: const TextStyle(color: AppTheme.accent, fontSize: 12)),
                      Text("R\$ ${finalPrice.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  onPressed: _loading ? null : () async {
                     if (_selectedClient != null && _selectedService != null) {
                        setState(() => _loading = true);
                        try {
                           final dt = widget.selectedDate;
                           final fullDate = DateTime(dt.year, dt.month, dt.day, _time.hour, _time.minute);
                           
                           await SupabaseService().client.from('bookings').insert({
                             'barber_id': SupabaseService().client.auth.currentUser!.id,
                             'client_id': _selectedClient!['id'],
                             'client_name': _selectedClient!['full_name'],
                             'service_name': _selectedService!['name'],
                             'price': finalPrice,
                             'booking_date': fullDate.toIso8601String(),
                             'status': 'confirmed'
                           });
                           
                           if (mounted) {
                             Navigator.pop(context);
                             ref.refresh(bookingsProvider);
                           }
                        } catch (e) {
                           if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e")));
                        } finally {
                           if (mounted) setState(() => _loading = false);
                        }
                     } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Selecione cliente e serviço")));
                     }
                  },
                  child: _loading ? const CupertinoActivityIndicator(color: Colors.black) : const Text("Confirmar Agendamento"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownDisplay(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: const TextStyle(color: Colors.white)),
          const Icon(Icons.arrow_drop_down, color: Colors.grey)
        ],
      ),
    );
  }

  void _showSelectionSheet(BuildContext context, String title, List<Map<String, dynamic>> items, Function(Map<String, dynamic>) onSelect) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      builder: (ctx) => Container(
        height: 400,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_,__) => const Divider(color: Colors.white10),
                itemBuilder: (ctx, i) {
                   final item = items[i];
                   final name = item['full_name'] ?? item['name'] ?? 'Sem nome'; // Handle profiles or services
                   return ListTile(
                     title: Text(name, style: const TextStyle(color: Colors.white)),
                     onTap: () {
                       onSelect(item);
                       Navigator.pop(ctx);
                     },
                   );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
