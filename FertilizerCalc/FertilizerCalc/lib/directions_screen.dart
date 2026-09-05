import 'dart:math' as math;
import 'package:flutter/material.dart';

class DirectionsScreen extends StatefulWidget {
  const DirectionsScreen({super.key});

  @override
  State<DirectionsScreen> createState() => _DirectionsScreenState();
}

class _DirectionsScreenState extends State<DirectionsScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  final List<_DirectionData> _directions = const [
    _DirectionData(
      title: 'Turn On Bluetooth',
      description:
          'Open your phone settings and make sure Bluetooth is turned ON.',
      image: 'images/direction_bluetooth.jpg',
      bottomText: 'Bluetooth must be ON before connecting to the soil sensor.',
    ),
    _DirectionData(
      title: 'Open FertilizerCalc',
      description:
          'Find the FertilizerCalc app icon on your phone and tap it to open the application.',
      image: 'images/direction_app_icon.jpg',
      bottomText: 'Tap the FertilizerCalc icon to launch the app.',
    ),
    _DirectionData(
      title: 'Connect to Soil Sensor',
      description:
          'On the Dashboard, tap the Connect button to connect your soil sensor through Bluetooth.',
      image: 'images/direction_connect.jpg',
      bottomText: 'Make sure your soil sensor is powered on before connecting.',
    ),
    _DirectionData(
      title: 'Get Fertilizer Recommendation',
      description:
          'After connecting the soil sensor and receiving the soil data, tap Get Recommendation.',
      image: 'images/direction_recommendation.jpg',
      bottomText:
          'Get your fertilizer recommendation based on the available soil data.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _directions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF6),
      body: SafeArea(
        child: Column(
          children: [
            // ============================================================
            // HEADER
            // ============================================================
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'How to Use FertilizerCalc',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Follow these simple steps to get started.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // X BUTTON
                  Material(
                    color: Colors.white,
                    elevation: 2,
                    shape: const CircleBorder(),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 27,
                        color: Colors.black54,
                      ),
                      tooltip: 'Close',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ============================================================
            // PAGE VIEW
            // ============================================================
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _directions.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _DirectionPage(
                    data: _directions[index],
                  );
                },
              ),
            ),

            // ============================================================
            // PAGE INDICATORS
            // ============================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _directions.length,
                (index) {
                  final bool selected = index == _currentPage;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: selected ? 24 : 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF4CAF50)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // ============================================================
            // LEFT / RIGHT NAVIGATION
            // ============================================================
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // PREVIOUS
                  _NavigationButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    enabled: _currentPage > 0,
                    onPressed: _previousPage,
                  ),

                  Text(
                    '${_currentPage + 1} / ${_directions.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),

                  // NEXT
                  _NavigationButton(
                    icon: Icons.arrow_forward_ios_rounded,
                    enabled: _currentPage < _directions.length - 1,
                    onPressed: _nextPage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================================
// DIRECTION PAGE
// ==========================================================================

class _DirectionPage extends StatelessWidget {
  final _DirectionData data;

  const _DirectionPage({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 5, 18, 10),
          child: Column(
            children: [
              // ============================================================
              // STEP TITLE
              // ============================================================
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _getStepNumber(data.title),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      data.title,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF222222),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ============================================================
              // DESCRIPTION
              // ============================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFFDCE8DA),
                  ),
                ),
                child: Text(
                  data.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ============================================================
              // SCREENSHOT - WALANG ARROW!
              // ============================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFFE1E9DF),
                  ),
                ),
                child: AspectRatio(
                  aspectRatio: 0.48,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      data.image,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade100,
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ============================================================
              // BOTTOM TIP
              // ============================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF6E9),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lightbulb_outline_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        data.bottomText,
                        style: const TextStyle(
                          fontSize: 13.5,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF315B36),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getStepNumber(String title) {
    if (title.contains('Bluetooth')) return '1';
    if (title.contains('Open')) return '2';
    if (title.contains('Connect')) return '3';
    return '4';
  }
}

// ==========================================================================
// NAVIGATION BUTTON
// ==========================================================================

class _NavigationButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  const _NavigationButton({
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? Colors.white : Colors.grey.shade100,
      elevation: enabled ? 2 : 0,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            icon,
            size: 21,
            color: enabled
                ? const Color(0xFF2E7D32)
                : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}

// ==========================================================================
// DATA MODEL - WALANG ARROW!
// ==========================================================================

class _DirectionData {
  final String title;
  final String description;
  final String image;
  final String bottomText;

  const _DirectionData({
    required this.title,
    required this.description,
    required this.image,
    required this.bottomText,
  });
}
