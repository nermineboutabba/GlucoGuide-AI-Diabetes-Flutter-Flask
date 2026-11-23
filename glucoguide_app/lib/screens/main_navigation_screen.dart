import 'package:flutter/material.dart';
import 'glucose_history_screen.dart';
import 'glucose_chart_screen.dart';
import 'user_profile_screen.dart';
import 'glucose_entry_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int currentIndex = 0;

  final screens = [
    const GlucoseHistoryScreen(),
    const GlucoseChartScreen(),
    const UserScreen(),
    AddGlucoseEntryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],

      // NAV BAR
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white38,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomAppBar(
          color: Colors.transparent,
          elevation: 0,
          shape: const CircularNotchedRectangle(),
          notchMargin: 10,
          child: SizedBox(
            height: 65,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(Icons.list, 0),
                _navItem(Icons.show_chart, 1),
                _navItem(Icons.add, 3),
                _navItem(Icons.person, 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, int index) {
    final isSelected = currentIndex == index;

    return IconButton(
      icon: Icon(
        icon,
        size: 28,
        color: isSelected ? const Color(0xFF0284C7) : Colors.grey,
      ),
      onPressed: () {
        setState(() => currentIndex = index);
      },
    );
  }
}
