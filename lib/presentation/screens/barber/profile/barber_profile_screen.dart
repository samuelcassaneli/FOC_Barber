import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/apple_glass_container.dart';
import '../management/services_screen.dart';
import '../management/products_screen.dart';
import '../management/financial_screen.dart';
import '../../../../../data/services/supabase_service.dart';

class BarberProfileScreen extends ConsumerStatefulWidget {
  const BarberProfileScreen({super.key});

  @override
  ConsumerState<BarberProfileScreen> createState() => _BarberProfileScreenState();
}

class _BarberProfileScreenState extends ConsumerState<BarberProfileScreen> {
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
     final user = SupabaseService().client.auth.currentUser;
     if (user != null) {
        final data = await SupabaseService().client.from('profiles').select().eq('id', user.id).single();
        setState(() {
           _avatarUrl = data['avatar_url'];
        });
     }
  }

  Future<void> _updateProfilePicture() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      final file = File(image.path);
      final user = SupabaseService().client.auth.currentUser;
      
      try {
         final fileName = '${user!.id}/${DateTime.now().toIso8601String()}.jpg';
         // Note: Assuming 'avatars' bucket exists. If not, catching error.
         await SupabaseService().client.storage.from('avatars').upload(fileName, file);
         
         final publicUrl = SupabaseService().client.storage.from('avatars').getPublicUrl(fileName);
         
         await SupabaseService().client.from('profiles').update({'avatar_url': publicUrl}).eq('id', user.id);
         
         setState(() => _avatarUrl = publicUrl);
         
         if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Foto atualizada!")));
      } catch (e) {
         if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao upload: $e")));
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
            title: const Text("Gestão"),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Header
                  GestureDetector(
                    onTap: _updateProfilePicture,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: _avatarUrl != null 
                              ? NetworkImage(_avatarUrl!) 
                              : const NetworkImage("https://i.pravatar.cc/300?img=11"),
                        ),
                        const Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                             radius: 14,
                             backgroundColor: AppTheme.accent,
                             child: Icon(Icons.camera_alt, size: 14, color: Colors.black),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text("Rick Barber", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const Text("Barbearia Premium", style: TextStyle(color: AppTheme.textSecondary)),
                  const SizedBox(height: 32),
                  
                  // Management Menu
                  _buildSectionTitle(context, "MEU NEGÓCIO"),
                  _buildMenuContainer([
                    _buildMenuItem(context, "Serviços & Preços", CupertinoIcons.scissors, Colors.orange, () => _navTo(const ServicesScreen())),
                    _buildMenuItem(context, "Produtos", CupertinoIcons.bag, Colors.blue, () => _navTo(const ProductsScreen())),
                    _buildMenuItem(context, "Financeiro", CupertinoIcons.money_dollar_circle, Colors.green, () => _navTo(const FinancialScreen())),
                    _buildMenuItem(context, "Relatórios", CupertinoIcons.graph_circle, Colors.purple, () {}),
                  ]),
                  
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, "CONFIGURAÇÕES"),
                  _buildMenuContainer([
                    _buildMenuItem(context, "Horário de Atendimento", CupertinoIcons.time, Colors.white, () {}),
                    _buildMenuItem(context, "Notificações", CupertinoIcons.bell, Colors.red, () {}),
                  ]),
                  
                  const SizedBox(height: 24),
                   AppleGlassContainer(
                    child: ListTile(
                      leading: const Icon(CupertinoIcons.square_arrow_left, color: Colors.red),
                      title: const Text("Sair da conta", style: TextStyle(color: Colors.red)),
                      onTap: () {
                        ref.read(authControllerProvider.notifier).signOut();
                      },
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
  
  void _navTo(Widget screen) {
     Navigator.push(context, CupertinoPageRoute(builder: (_) => screen));
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 8, left: 16),
      child: Text(
        title,
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildMenuContainer(List<Widget> children) {
    return AppleGlassContainer(
      padding: EdgeInsets.zero,
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10, width: 0.5)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(CupertinoIcons.chevron_right, color: Colors.white24, size: 16),
        onTap: onTap,
      ),
    );
  }
}
