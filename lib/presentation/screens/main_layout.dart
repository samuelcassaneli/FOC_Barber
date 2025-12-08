import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/glass_card.dart';
import 'booking_screen.dart';
import 'dashboard_screen.dart';
import 'home_screen.dart';

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
    DashboardScreen(), // Acesso Admin/Barbeiro
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          // Desktop Layout
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  backgroundColor: Colors.black,
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) => setState(() => _currentIndex = index),
                  labelType: NavigationRailLabelType.all,
                  selectedLabelTextStyle: const TextStyle(color: AppTheme.accent),
                  unselectedLabelTextStyle: const TextStyle(color: Colors.grey),
                  selectedIconTheme: const IconThemeData(color: AppTheme.accent),
                  unselectedIconTheme: const IconThemeData(color: Colors.grey),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(CupertinoIcons.scissors),
                      label: Text('Início'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(CupertinoIcons.calendar_badge_plus),
                      label: Text('Agendar'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(CupertinoIcons.chart_bar_square),
                      label: Text('Painel'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1, color: Colors.white10),
                Expanded(child: _screens[_currentIndex]),
              ],
            ),
          );
        } else {
          // Mobile Layout
          return Scaffold(
            body: _screens[_currentIndex],
            bottomNavigationBar: GlassCard(
              opacity: 0.1,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(0), 
                topRight: Radius.circular(0)
              ),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) => setState(() => _currentIndex = index),
                backgroundColor: Colors.transparent,
                selectedItemColor: AppTheme.accent,
                unselectedItemColor: Colors.grey,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.scissors),
                    label: 'Início',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.calendar_badge_plus),
                    label: 'Agendar',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.chart_bar_square),
                    label: 'Painel',
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
