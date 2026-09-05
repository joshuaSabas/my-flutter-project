import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isChecked = false;
  bool _isLoading = false;

  static const Color darkGreen = Color(0xFF247A35);
  static const Color mainGreen = Color(0xFF4CAF50);
  static const Color lightGreen = Color(0xFFEAF6E9);
  static const Color paleGreen = Color(0xFFF5FBF3);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F2),
      body: Stack(
        children: [
          // ============================================================
          // SOFT GREEN BACKGROUND
          // ============================================================
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF8FCF7),
                  Color(0xFFEAF5E8),
                ],
              ),
            ),
          ),

          // ============================================================
          // DECORATIVE LEAVES
          // ============================================================
          Positioned(
            top: -25,
            left: -20,
            child: _LeafDecoration(
              size: 125,
              opacity: 0.10,
              rotation: -0.35,
            ),
          ),

          Positioned(
            top: 80,
            right: -45,
            child: _LeafDecoration(
              size: 145,
              opacity: 0.08,
              rotation: 0.55,
            ),
          ),

          Positioned(
            bottom: 110,
            left: -45,
            child: _LeafDecoration(
              size: 150,
              opacity: 0.10,
              rotation: 0.40,
            ),
          ),

          Positioned(
            bottom: 25,
            right: -35,
            child: _LeafDecoration(
              size: 125,
              opacity: 0.11,
              rotation: -0.45,
            ),
          ),

          // ============================================================
          // MAIN SCROLLABLE CONTENT
          // ============================================================
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 560,
                  ),
                  child: Stack(
                    children: [
                      // ==================================================
                      // WHITE MAIN CARD
                      // ==================================================
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(
                          22,
                          24,
                          22,
                          28,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.10),
                              blurRadius: 28,
                              spreadRadius: 2,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),

                            // ==================================================
                            // FARMER IMAGE
                            // ==================================================
                            Container(
                              width: size.width < 400 ? 170 : 190,
                              height: size.width < 400 ? 170 : 190,
                              decoration: BoxDecoration(
                                color: lightGreen,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: mainGreen.withOpacity(0.10),
                                    blurRadius: 18,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Padding(
                                  padding: const EdgeInsets.all(7),
                                  child: Image.asset(
                                    // EXISTING IMAGE — HINDI BINAGO
                                    'images/1000044859-removebg-preview.png',
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.agriculture_rounded,
                                        size: 75,
                                        color: mainGreen,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ==================================================
                            // WELCOME
                            // ==================================================
                            const Text(
                              'Welcome to',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 27,
                                fontWeight: FontWeight.w300,
                                color: Color(0xFF666666),
                                letterSpacing: 0.2,
                              ),
                            ),

                            const SizedBox(height: 2),

                            const Text(
                              'FertilizerCalc!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: darkGreen,
                                letterSpacing: -0.8,
                              ),
                            ),

                            const SizedBox(height: 10),

                            const Text(
                              'Smart fertilizer recommendations\n'
                              'for your Pechay crop.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.45,
                                color: Color(0xFF777777),
                              ),
                            ),

                            const SizedBox(height: 26),

                            // ==================================================
                            // TERMS CARD
                            // ==================================================
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(
                                18,
                                18,
                                18,
                                19,
                              ),
                              decoration: BoxDecoration(
                                color: paleGreen,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: const Color(0xFFDCEBD9),
                                  width: 1.2,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 43,
                                        height: 43,
                                        decoration: BoxDecoration(
                                          color: mainGreen.withOpacity(0.13),
                                          borderRadius:
                                              BorderRadius.circular(13),
                                        ),
                                        child: const Icon(
                                          Icons.description_rounded,
                                          color: mainGreen,
                                          size: 24,
                                        ),
                                      ),

                                      const SizedBox(width: 12),

                                      const Expanded(
                                        child: Text(
                                          'Terms of Agreement',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: darkGreen,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 15),

                                  const Text(
                                    'By using FertilizerCalc, you agree to '
                                    'use the application for its intended '
                                    'purpose. The fertilizer recommendations '
                                    'provided by the application are based '
                                    'on the soil data received by the system '
                                    'and are intended as a guide for '
                                    'fertilizer selection.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      height: 1.55,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 19),

                            // ==================================================
                            // CHECKBOX
                            // ==================================================
                            InkWell(
                              borderRadius: BorderRadius.circular(15),
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
                                    Checkbox(
                                      value: _isChecked,
                                      onChanged: (value) {
                                        setState(() {
                                          _isChecked = value ?? false;
                                        });
                                      },
                                      activeColor: mainGreen,
                                      checkColor: Colors.white,
                                      side: BorderSide(
                                        color: Colors.grey.shade400,
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                    ),

                                    const SizedBox(width: 4),

                                    const Expanded(
                                      child: Text(
                                        'I have read and agree to the '
                                        'Terms of Agreement',
                                        style: TextStyle(
                                          fontSize: 14.5,
                                          height: 1.35,
                                          color: Color(0xFF333333),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            // ==================================================
                            // AGREE & CONTINUE BUTTON
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
                                      ? mainGreen
                                      : const Color(0xFFBDBDBD),
                                  disabledBackgroundColor:
                                      const Color(0xFFBDBDBD),
                                  foregroundColor: Colors.white,
                                  elevation: _isChecked ? 4 : 0,
                                  shadowColor:
                                      mainGreen.withOpacity(0.30),
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
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'I Agree & Continue',
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 9),
                                          Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 22,
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ==================================================
                      // X BUTTON
                      // ==================================================
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Material(
                          color: Colors.white,
                          elevation: 3,
                          shadowColor: Colors.black.withOpacity(0.15),
                          shape: const CircleBorder(),
                          child: InkWell(
                            onTap: _skipWelcome,
                            customBorder: const CircleBorder(),
                            child: const SizedBox(
                              width: 48,
                              height: 48,
                              child: Icon(
                                Icons.close_rounded,
                                size: 27,
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

          // ==============================================================
          // BOTTOM LEAF DECORATION
          // ==============================================================
          Positioned(
            left: -20,
            bottom: -35,
            child: _LeafDecoration(
              size: 190,
              opacity: 0.08,
              rotation: -0.25,
            ),
          ),

          Positioned(
            right: -30,
            bottom: -30,
            child: _LeafDecoration(
              size: 170,
              opacity: 0.09,
              rotation: 0.35,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // SKIP
  // ================================================================
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

  // ================================================================
  // AGREE & CONTINUE
  // ================================================================
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

// ==========================================================================
// LEAF DECORATION
// ==========================================================================

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
                left: size * 0.15,
                top: size * 0.30,
                child: Transform.rotate(
                  angle: -0.45,
                  child: Icon(
                    Icons.eco_rounded,
                    size: size * 0.55,
                    color: mainGreen,
                  ),
                ),
              ),
              Positioned(
                left: size * 0.38,
                top: size * 0.10,
                child: Transform.rotate(
                  angle: 0.15,
                  child: Icon(
                    Icons.eco_rounded,
                    size: size * 0.45,
                    color: darkGreen,
                  ),
                ),
              ),
              Positioned(
                left: size * 0.48,
                top: size * 0.48,
                child: Transform.rotate(
                  angle: 0.65,
                  child: Icon(
                    Icons.eco_rounded,
                    size: size * 0.38,
                    color: mainGreen,
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
