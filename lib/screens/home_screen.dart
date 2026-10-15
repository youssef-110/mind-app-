import 'package:flutter/material.dart';
import 'journal_screen.dart';
import 'mood_screen.dart';
import 'mood_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    JournalScreen(),     // 0
    MoodScreen(),        // 1  ← mood picker
    MoodHistoryScreen()  // 2  ← charts + timeline
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Journal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_reaction),
            label: 'Mood',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
