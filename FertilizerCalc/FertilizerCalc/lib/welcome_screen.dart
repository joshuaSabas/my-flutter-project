import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

// ============================================================================
// COLORS
// ============================================================================

const Color _darkGreen = Color(0xFF247A35);
const Color _mainGreen = Color(0xFF4CAF50);
const Color _softGreen = Color(0xFFEAF6E8);
const Color _veryLightGreen = Color(0xFFF5FBF3);

// ============================================================================
// WELCOME SCREEN
// ============================================================================

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isChecked = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: _veryLightGreen,
      body: Stack(
        children: [
          // ==================================================================
          // BACKGROUND
          // ==================================================================

          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF9FCF8),
                  Color(0xFFEAF5E7),
                ],
              ),
            ),
          ),

          // ==================================================================
          // DECORATIVE LEAVES - TOP LEFT
          // ==================================================================

          const Positioned(
            left: -55,
            top: -45,
            child: _LeafDecoration(
              size: 155,
              opacity: 0.10,
              rotation: -0.30,
            ),
          ),

          // ==================================================================
          // DECORATIVE LEAVES - TOP RIGHT
          // ==================================================================

          const Positioned(
            right: -55,
            top: 35,
            child: _LeafDecoration(
              size: 150,
              opacity: 0.08,
              rotation: 0.45,
            ),
          ),

          // ==================================================================
          // DECORATIVE LEAVES - BOTTOM LEFT
          // ==================================================================

          const Positioned(
            left: -60,
            bottom: -25,
            child: _LeafDecoration(
              size: 175,
              opacity: 0.09,
              rotation: 0.25,
            ),
          ),

          // ==================================================================
          // DECORATIVE LEAVES - BOTTOM RIGHT
          // ==================================================================

          const Positioned(
            right: -55,
            bottom: -35,
            child: _LeafDecoration(
              size: 170,
              opacity: 0.10,
              rotation: -0.35,
            ),
          ),

          // ==================================================================
          // MAIN CONTENT
          // ==================================================================

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 520,
                  ),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.97),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: _darkGreen.withOpacity(0.10),
                          blurRadius: 30,
                          spreadRadius: 2,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            22,
                            30,
                            22,
                            26,
                          ),
                          child: Column(
                            children: [
                              // ==================================================
                              // FARMER IMAGE
                              // ==================================================

                              Container(
                                width: screenWidth < 380 ? 165 : 185,
                                height: screenWidth < 380 ? 165 : 185,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _softGreen,
                                  border: Border.all(
                                    color: const Color(0xFFD8ECD5),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _mainGreen.withOpacity(0.12),
                                      blurRadius: 18,
                                      spreadRadius: 3,
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(7),
                                  child: ClipOval(
                                    child: Image.asset(
                                      // =================================================
                                      // EXISTING IMAGE - HINDI BINAGO
                                      // =================================================
                                      'images/1000044859-removebg-preview.png',
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.agriculture_rounded,
                                          size: 70,
                                          color: _mainGreen,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 19),

                              // ==================================================
                              // WELCOME
                              // ==================================================

                              const Text(
                                'Welcome to',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w300,
                                  color: Color(0xFF666666),
                                  letterSpacing: 0.2,
                                ),
                              ),

                              const SizedBox(height: 1),

                              const Text(
                                'FertilizerCalc!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 35,
                                  fontWeight: FontWeight.w800,
                                  color: _darkGreen,
                                  letterSpacing: -0.6,
                                ),
                              ),

                              const SizedBox(height: 9),

                              const Text(
                                'Smart fertilizer recommendations\n'
                                'for your Pechay crop.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15.5,
                                  height: 1.45,
                                  color: Color(0xFF777777),
                                ),
                              ),

                              const SizedBox(height: 25),

                              // ==================================================
                              // TERMS CARD
                              // ==================================================

                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: _veryLightGreen,
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: const Color(0xFFD7E8D4),
                                    width: 1.2,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 42,
                                          height: 42,
                                          decoration: BoxDecoration(
                                            color:
                                                _mainGreen.withOpacity(0.13),
                                            borderRadius:
                                                BorderRadius.circular(13),
                                          ),
                                          child: const Icon(
                                            Icons.description_rounded,
                                            color: _mainGreen,
                                            size: 23,
                                          ),
                                        ),

                                        const SizedBox(width: 11),

                                        const Expanded(
                                          child: Text(
                                            'Terms of Agreement',
                                            style: TextStyle(
                                              fontSize: 19,
                                              fontWeight: FontWeight.bold,
                                              color: _darkGreen,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 14),

                                    const Text(
                                      'By using FertilizerCalc, you agree to '
                                      'use the application for its intended '
                                      'purpose. The fertilizer recommendations '
                                      'provided by the application are based '
                                      'on the soil data received by the system '
                                      'and are intended as a guide for '
                                      'fertilizer selection.',
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        height: 1.55,
                                        color: Color(0xFF333333),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              // ==================================================
                              // AGREEMENT CHECKBOX
                              // ==================================================

                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () {
                                    setState(() {
                                      _isChecked = !_isChecked;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 3,
                                      horizontal: 1,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Checkbox(
                                          value: _isChecked,
                                          onChanged: (value) {
                                            setState(() {
                                              _isChecked = value ?? false;
                                            });
                                          },
                                          activeColor: _mainGreen,
                                          checkColor: Colors.white,
                                          side: BorderSide(
                                            color: Colors.grey.shade400,
                                            width: 1.5,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        ),

                                        const SizedBox(width: 4),

                                        const Expanded(
                                          child: Text(
                                            'I have read and agree to the '
                                            'Terms of Agreement',
                                            style: TextStyle(
                                              fontSize: 13.5,
                                              height: 1.35,
                                              color: Color(0xFF333333),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              // ==================================================
                              // I AGREE & CONTINUE
                              // ==================================================

                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : (_isChecked
                                          ? _proceedToDashboard
                                          : null),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isChecked
                                        ? _mainGreen
                                        : const Color(0xFFBDBDBD),
                                    disabledBackgroundColor:
                                        const Color(0xFFBDBDBD),
                                    foregroundColor: Colors.white,
                                    elevation: _isChecked ? 4 : 0,
                                    shadowColor:
                                        _mainGreen.withOpacity(0.25),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 23,
                                          height: 23,
                                          child:
                                              CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'I Agree & Continue',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 21,
                                            ),
                                          ],
                                        ),
                                ),
                              ),

                              const SizedBox(height: 2),
                            ],
                          ),
                        ),

                        // ======================================================
                        // X / SKIP BUTTON
                        // ======================================================

                        Positioned(
                          top: 10,
                          right: 10,
                          child: Material(
                            color: Colors.white,
                            elevation: 3,
                            shadowColor: Colors.black.withOpacity(0.12),
                            shape: const CircleBorder(),
                            child: InkWell(
                              onTap: _skipWelcome,
                              customBorder: const CircleBorder(),
                              child: const SizedBox(
                                width: 45,
                                height: 45,
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 26,
                                  color: Color(0xFF666666),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ==================================================================
          // SMALL LEAF ACCENTS IN FRONT
          // ==================================================================

          const Positioned(
            left: 5,
            top: 180,
            child: _SmallLeaf(
              rotation: -0.45,
              opacity: 0.12,
            ),
          ),

          const Positioned(
            right: 5,
            top: 310,
            child: _SmallLeaf(
              rotation: 0.50,
              opacity: 0.10,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SKIP
  // ==========================================================================

  void _skipWelcome() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('hasSeenWelcome', true);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  // ==========================================================================
  // AGREE & CONTINUE
  // ==========================================================================

  void _proceedToDashboard() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('hasSeenWelcome', true);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }
}

// ============================================================================
// LARGE LEAF DECORATION
// ============================================================================

class _LeafDecoration extends StatelessWidget {
  final double size;
  final double opacity;
  final double rotation;

  const _LeafDecoration({
    required this.size,
    required this.opacity,
    required this.rotation,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Opacity(
        opacity: opacity,
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              Positioned(
                left: size * 0.05,
                top: size * 0.30,
                child: Transform.rotate(
                  angle: -0.65,
                  child: const Icon(
                    Icons.eco_rounded,
                    size: 75,
                    color: _mainGreen,
                  ),
                ),
              ),

              Positioned(
                left: size * 0.38,
                top: size * 0.08,
                child: Transform.rotate(
                  angle: 0.10,
                  child: const Icon(
                    Icons.eco_rounded,
                    size: 62,
                    color: _darkGreen,
                  ),
                ),
              ),

              Positioned(
                left: size * 0.48,
                top: size * 0.48,
                child: Transform.rotate(
                  angle: 0.55,
                  child: const Icon(
                    Icons.eco_rounded,
                    size: 55,
                    color: _mainGreen,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SMALL LEAF
// ============================================================================

class _SmallLeaf extends StatelessWidget {
  final double rotation;
  final double opacity;

  const _SmallLeaf({
    required this.rotation,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Opacity(
        opacity: opacity,
        child: const Icon(
          Icons.eco_rounded,
          size: 42,
          color: _mainGreen,
        ),
      ),
    );
  }
}
