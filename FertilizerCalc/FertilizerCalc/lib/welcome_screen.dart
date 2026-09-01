import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onSkip;

  const WelcomeScreen({
    super.key,
    required this.onContinue,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    // WELCOME TITLE
                    const Text(
                      'Welcome to',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),

                    const Text(
                      'FertilizerCalc!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4F8A4F),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // YOUR WELCOME PICTURE
                    Image.asset(
                      'images/1000044859-removebg-preview.png',
                      width: double.infinity,
                      height: 285,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Smart fertilizer recommendations\n'
                      'for your Pechay crop.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // TERMS OF AGREEMENT
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F8F2),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFD5E4D3),
                          width: 1,
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Terms of Agreement',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),

                          SizedBox(height: 10),

                          Text(
                            'By using FertilizerCalc, you agree to use '
                            'the application for its intended purpose. '
                            'The fertilizer recommendations provided by '
                            'the application are based on the soil data '
                            'received by the system and are intended as '
                            'a guide for fertilizer selection.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // AGREE AND CONTINUE BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: onContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F8A4F),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: const Text(
                          'I Agree & Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),

            // X BUTTON
            Positioned(
              top: 4,
              right: 8,
              child: Material(
                color: Colors.white,
                shape: const CircleBorder(),
                child: IconButton(
                  onPressed: onSkip,
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 28,
                    color: Colors.black54,
                  ),
                  tooltip: 'Skip',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
