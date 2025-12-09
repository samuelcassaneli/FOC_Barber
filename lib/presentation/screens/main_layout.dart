import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'booking_screen.dart';
import 'dashboard_screen.dart';
import 'home_screen.dart';
import 'client/client_profile_screen.dart'; // Import Client Profile

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  final List<Widget> _screens = const [
    HomeScreen(),
    BookingScreen(),
    ClientProfileScreen(), // Use Client Profile here
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBody: true, // Allows body to go behind the bottom bar
      body: _screens[_currentIndex],
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surface.withOpacity(0.7), // Semi-transparent
              border: const Border(top: BorderSide(color: Colors.white10, width: 0.5)),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              backgroundColor: Colors.transparent, // Important for blur
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppTheme.accent,
              unselectedItemColor: AppTheme.textSecondary,
              selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.house_fill),
                  label: 'Início',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.calendar_today),
                  activeIcon: Icon(CupertinoIcons.calendar_today, weight: 800),
                  label: 'Agendar',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.person_crop_circle),
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
