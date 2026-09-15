import 'package:flutter/material.dart';
import 'dashboard_logic.dart';
import 'dashboard_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {  // 👈 DAGDAG ITO!
  
  late DashboardLogic _logic;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _logic = DashboardLogic(context: context);
    _logic.initState();

    // 👇 GAMITIN ANG `this` HINDI `_logic`
    _bounceController = AnimationController(
      vsync: this,  // 👈 ITO ANG TAMA!
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
    return AnimatedBuilder(
      animation: _logic,
      builder: (context, child) {
        return DashboardWidgets.buildDashboard(
          context: context,
          logic: _logic,
          bounceAnimation: _bounceAnimation,
          onDrawerTap: (index) => _logic.onDrawerTap(index),
        );
      },
    );
  }
}
