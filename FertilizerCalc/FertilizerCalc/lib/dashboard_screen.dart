import 'package:flutter/material.dart';
import 'dashboard_logic.dart';
import 'dashboard_widgets.dart';
import 'history.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  late DashboardLogic _logic;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _logic = DashboardLogic(context: context);
    _logic.initState();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _bounceAnimation = Tween<double>(begin: 0, end: 0.10).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
    _bounceController.repeat(reverse: true);

    _logic.setBounceController(_bounceController, _bounceAnimation);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _logic.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return AnimatedBuilder(
      animation: _logic,
      builder: (context, child) {
        return Scaffold(
          drawer: DashboardWidgets.buildDrawer(
            context,
            _logic,
            (index) => _logic.onDrawerTap(index),
          ),
          body: IndexedStack(
            index: _currentIndex,
            children: [
              DashboardWidgets.buildDashboardBody(
                context: context,
                logic: _logic,
                bounceAnimation: _bounceAnimation,
                onDrawerTap: (index) => _logic.onDrawerTap(index),
              ),
              const HistoryScreen(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            selectedItemColor: const Color(0xFF2E7D32),
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'History',
              ),
            ],
          ),
        );
      },
    );
  }
}
