import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'history.dart';

class HomeScreen extends StatefulWidget {
  final bool hasExistingData;

  const HomeScreen({super.key, this.hasExistingData = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // GLOBAL KEY para ma-access ang HistoryScreen state
  final GlobalKey<HistoryScreenState> _historyKey = GlobalKey<HistoryScreenState>();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _screens = [
      DashboardScreen(
        onHistorySaved: () {
          // I-refresh ang History screen pag clinick ang Save button
          _historyKey.currentState?.refreshHistory();
        },
      ),
      HistoryScreen(key: _historyKey),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
