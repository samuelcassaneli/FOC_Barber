import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_premium/core/theme/app_theme.dart';
import 'dashboard/barber_dashboard_screen.dart';
import 'agenda/barber_agenda_screen.dart';
import 'profile/barber_profile_screen.dart';

class BarberMainLayout extends ConsumerStatefulWidget {
  const BarberMainLayout({super.key});

  @override
  ConsumerState<BarberMainLayout> createState() => _BarberMainLayoutState();
}

class _BarberMainLayoutState extends ConsumerState<BarberMainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const BarberDashboardScreen(),
    const BarberAgendaScreen(),
    const BarberProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBody: true,
      body: _screens[_currentIndex],
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
             decoration: BoxDecoration(
              color: AppTheme.surface.withOpacity(0.7),
              border: const Border(top: BorderSide(color: Colors.white10, width: 0.5)),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              backgroundColor: Colors.transparent,
              selectedItemColor: AppTheme.accent,
              unselectedItemColor: AppTheme.textSecondary,
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.graph_square),
                  activeIcon: Icon(CupertinoIcons.graph_square_fill),
                  label: 'Painel',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.calendar),
                  activeIcon: Icon(CupertinoIcons.calendar_today),
                  label: 'Agenda',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.person),
                  activeIcon: Icon(CupertinoIcons.person_solid),
                  label: 'Perfil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
