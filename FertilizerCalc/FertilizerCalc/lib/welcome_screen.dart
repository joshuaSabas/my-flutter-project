import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

// ============================================================================
// COLORS
// ============================================================================

const Color _darkGreen = Color(0xFF1B5E20);
const Color _mainGreen = Color(0xFF2E7D32);
const Color _lightGreen = Color(0xFF4CAF50);
const Color _softGreen = Color(0xFFE8F5E9);
const Color _veryLightGreen = Color(0xFFF1F8E9);
const Color _goldAccent = Color(0xFFFFC107);

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
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: _veryLightGreen,
      body: Stack(
        children: [
          // ==================================================================
          // ANIMATED BACKGROUND GRADIENT
          // ==================================================================

          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.5,
                colors: [
                  Color(0xFFE8F5E9),
                  Color(0xFFC8E6C9),
                  Color(0xFFA5D6A7),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // ==================================================================
          // DECORATIVE CIRCLES
          // ==================================================================

          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _lightGreen.withOpacity(0.15),
              ),
            ),
          ),

          Positioned(
            bottom: -40,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _lightGreen.withOpacity(0.10),
              ),
            ),
          ),

          Positioned(
            top: screenHeight * 0.4,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _goldAccent.withOpacity(0.08),
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
              opacity: 0.12,
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
              opacity: 0.10,
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
              opacity: 0.08,
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
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 520,
                  ),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.98),
                          Colors.white.withOpacity(0.95),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: _darkGreen.withOpacity(0.12),
                          blurRadius: 40,
                          spreadRadius: 4,
                          offset: const Offset(0, 15),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            24,
                            32,
                            24,
                            28,
                          ),
                          child: Column(
                            children: [
                              // ==================================================
                              // FARMER IMAGE WITH GLOW
                              // ==================================================

                              Container(
                                width: screenWidth < 380 ? 170 : 190,
                                height: screenWidth < 380 ? 170 : 190,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      _softGreen,
                                      _lightGreen.withOpacity(0.3),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: _lightGreen.withOpacity(0.5),
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _mainGreen.withOpacity(0.15),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                      offset: const Offset(0, 10),
                                    ),
                                    BoxShadow(
                                      color: _lightGreen.withOpacity(0.3),
                                      blurRadius: 50,
                                      spreadRadius: 10,
                                      offset: const Offset(0, 0),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: ClipOval(
                                    child: Image.asset(
                                      'images/1000044859-removebg-preview.png',
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          color: _softGreen,
                                          child: const Icon(
                                            Icons.agriculture_rounded,
                                            size: 80,
                                            color: _mainGreen,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 22),

                              // ==================================================
                              // BADGE
                              // ==================================================

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      _mainGreen,
                                      _lightGreen,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _mainGreen.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Smart Farming',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 14),

                              // ==================================================
                              // WELCOME
                              // ==================================================

                              const Text(
                                'Welcome to',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w300,
                                  color: Color(0xFF888888),
                                  letterSpacing: 1.5,
                                ),
                              ),

                              const SizedBox(height: 2),

                              RichText(
                                textAlign: TextAlign.center,
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Fertilizer',
                                      style: TextStyle(
                                        fontSize: 38,
                                        fontWeight: FontWeight.w800,
                                        color: _darkGreen,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Calc',
                                      style: TextStyle(
                                        fontSize: 38,
                                        fontWeight: FontWeight.w800,
                                        color: _lightGreen,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '!',
                                      style: TextStyle(
                                        fontSize: 38,
                                        fontWeight: FontWeight.w800,
                                        color: _goldAccent,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 10),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: _softGreen.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Text(
                                  '🌱 Smart fertilizer recommendations for your Pechay crop',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    height: 1.5,
                                    color: Color(0xFF555555),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 28),

                              // ==================================================
                              // TERMS CARD - IMPROVED
                              // ==================================================

                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      _veryLightGreen,
                                      _softGreen.withOpacity(0.6),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: _lightGreen.withOpacity(0.2),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _lightGreen.withOpacity(0.1),
                                      blurRadius: 15,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                _mainGreen,
                                                _lightGreen,
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            boxShadow: [
                                              BoxShadow(
                                                color: _mainGreen
                                                    .withOpacity(0.2),
                                                blurRadius: 8,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.description_rounded,
                                            color: Colors.white,
                                            size: 22,
                                          ),
                                        ),

                                        const SizedBox(width: 12),

                                        const Expanded(
                                          child: Text(
                                            'Terms of Agreement',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: _darkGreen,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 14),

                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.6),
                                        borderRadius:
                                            BorderRadius.circular(14),
                                      ),
                                      child: const Text(
                                        'By using FertilizerCalc, you agree to '
                                        'use the application for its intended '
                                        'purpose. The fertilizer recommendations '
                                        'provided are based on the soil data '
                                        'received and are intended as a guide '
                                        'for fertilizer selection.',
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          height: 1.6,
                                          color: Color(0xFF333333),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 18),

                              // ==================================================
                              // AGREEMENT CHECKBOX - IMPROVED
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
                                      vertical: 4,
                                      horizontal: 2,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: _isChecked
                                                ? _mainGreen
                                                : Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: Border.all(
                                              color: _isChecked
                                                  ? _mainGreen
                                                  : Colors.grey.shade400,
                                              width: 2,
                                            ),
                                            boxShadow: _isChecked
                                                ? [
                                                    BoxShadow(
                                                      color: _mainGreen
                                                          .withOpacity(0.3),
                                                      blurRadius: 8,
                                                      offset:
                                                          const Offset(0, 2),
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                          child: _isChecked
                                              ? const Icon(
                                                  Icons.check_rounded,
                                                  color: Colors.white,
                                                  size: 18,
                                                )
                                              : null,
                                        ),

                                        const SizedBox(width: 12),

                                        const Expanded(
                                          child: Text(
                                            'I have read and agree to the '
                                            'Terms of Agreement',
                                            style: TextStyle(
                                              fontSize: 13.5,
                                              height: 1.4,
                                              color: Color(0xFF333333),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 18),

                              // ==================================================
                              // I AGREE & CONTINUE - IMPROVED
                              // ==================================================

                              SizedBox(
                                width: double.infinity,
                                height: 58,
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
                                    elevation: _isChecked ? 6 : 0,
                                    shadowColor: _isChecked
                                        ? _mainGreen.withOpacity(0.35)
                                        : Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child:
                                              CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              _isChecked
                                                  ? 'I Agree & Continue'
                                                  : 'Please Agree to Continue',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: _isChecked
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                                color: _isChecked
                                                    ? Colors.white
                                                    : Colors.white70,
                                              ),
                                            ),
                                            if (_isChecked) ...[
                                              const SizedBox(width: 8),
                                              const Icon(
                                                Icons.arrow_forward_rounded,
                                                size: 22,
                                              ),
                                            ],
                                          ],
                                        ),
                                ),
                              ),

                              const SizedBox(height: 4),
                            ],
                          ),
                        ),

                        // ======================================================
                        // X / SKIP BUTTON - IMPROVED
                        // ======================================================

                        Positioned(
                          top: 12,
                          right: 12,
                          child: Material(
                            color: Colors.white,
                            elevation: 4,
                            shadowColor: Colors.black.withOpacity(0.10),
                            shape: const CircleBorder(),
                            child: InkWell(
                              onTap: _skipWelcome,
                              customBorder: const CircleBorder(),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  size: 24,
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
                    color: _lightGreen,
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
                    color: _mainGreen,
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
                    color: _lightGreen,
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
          color: _lightGreen,
        ),
      ),
    );
  }
}
