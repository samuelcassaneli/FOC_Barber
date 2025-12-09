import 'package:barber_premium/presentation/widgets/apple_glass_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../../data/services/supabase_service.dart';

class BarberDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> barber;
  const BarberDetailScreen({super.key, required this.barber});

  @override
  ConsumerState<BarberDetailScreen> createState() => _BarberDetailScreenState();
}

class _BarberDetailScreenState extends ConsumerState<BarberDetailScreen> {
  bool _isMember = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkMembership();
  }

  Future<void> _checkMembership() async {
    final client = SupabaseService().client;
    try {
      final res = await client
          .from('barber_clients')
          .select()
          .eq('barber_id', widget.barber['id'])
          .eq('client_id', client.auth.currentUser!.id)
          .maybeSingle();
      
      if (mounted) {
        setState(() {
          _isMember = res != null;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleMembership() async {
    setState(() => _loading = true);
    final client = SupabaseService().client;
    try {
      if (_isMember) {
        // Leave
        await client
            .from('barber_clients')
            .delete()
            .eq('barber_id', widget.barber['id'])
            .eq('client_id', client.auth.currentUser!.id);
      } else {
        // Join
        await client.from('barber_clients').insert({
          'barber_id': widget.barber['id'],
          'client_id': client.auth.currentUser!.id,
        });
      }
      
      if (mounted) {
        setState(() {
          _isMember = !_isMember;
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isMember ? "Você agora é cliente!" : "Você saiu da barbearia.")),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            backgroundColor: AppTheme.background,
            title: Text(widget.barber['full_name'] ?? 'Barbearia'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(widget.barber['avatar_url'] ?? 'https://i.pravatar.cc/300'),
                  ),
                  const SizedBox(height: 24),
                  
                  _loading 
                    ? const CupertinoActivityIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: CupertinoButton(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          onPressed: _toggleMembership,
                          color: _isMember ? Colors.redAccent.withOpacity(0.8) : AppTheme.accent,
                          child: Text(
                            _isMember ? "Deixar de ser Cliente" : "Tornar-se Cliente",
                            style: TextStyle(
                              color: _isMember ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  
                  const SizedBox(height: 32),
                  
                  if (_isMember) 
                    AppleGlassContainer(
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(CupertinoIcons.check_mark_circled_solid, color: Colors.green, size: 32),
                            SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                "Você está na lista de clientes desta barbearia. O barbeiro poderá agendar horários para você.",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
