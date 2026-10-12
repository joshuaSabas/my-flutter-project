import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  Future<void> _sendEmail(BuildContext context, String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=FertilizerCalc Inquiry&body=Hello,',
    );

    try {
      if (!await launchUrl(emailUri, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open mail app for $email'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error launching mail: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No mail app found on this device'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ============================================
              // HEADER — maliit na green bar, back button lang
              // ============================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFF2E7D32),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ============================================
              // TITLE
              // ============================================
              const Text(
                "About Us",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Meet the team behind FertilizerCalc.",
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 80,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF43A047),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: 28),

              // ============================================
              // ABOUT THE APP
              // ============================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE8F5E9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.eco,
                              color: Color(0xFF2E7D32),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              "About the App",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B5E20),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        "FertilizerCalc is a smart soil analysis and fertilizer recommendation mobile application designed for pechay farmers. It uses a Random Forest machine learning model to predict the best fertilizer based on real-time soil nutrient readings (Nitrogen, Phosphorus, Potassium, and pH) collected through a Bluetooth-enabled soil sensor.",
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.5,
                          color: Color(0xFF555555),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "The app helps users:",
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildBulletPoint("Analyze soil nutrient levels in real-time."),
                      _buildBulletPoint("Get personalized fertilizer recommendations."),
                      _buildBulletPoint("Convert application rates based on plot size."),
                      _buildBulletPoint("Save and review past recommendations."),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ============================================
              // MEET THE TEAM HEADER
              // ============================================
              const Text(
                "Meet the Team",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "The people behind FertilizerCalc.",
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF666666),
                ),
              ),

              const SizedBox(height: 18),

              // ============================================
              // TEAM MEMBER 1 — JOSHUA D. SABAS
              // ============================================
              _buildTeamCard(
                context: context,
                name: "Joshua D. Sabas",
                role: "Developer",
                roleIcon: Icons.code,
                description:
                    "Handles the development of the FertilizerCalc mobile application.",
                imagePath: "images/joshua.png",
                email: "sabasj46@gmail.com",
              ),

              const SizedBox(height: 16),

              // ============================================
              // TEAM MEMBER 2 — RENDILLE O. GAGAM
              // ============================================
              _buildTeamCard(
                context: context,
                name: "Rendille O. Gagam",
                role: "UI/UX Designer",
                roleIcon: Icons.palette,
                description:
                    "Designs the interface and user experience of the application.",
                imagePath: "images/rendille.png",
                email: "rengagam@gmail.com",
              ),

              const SizedBox(height: 16),

              // ============================================
              // TEAM MEMBER 3 — JEMBOY REQUIS
              // ============================================
              _buildTeamCard(
                context: context,
                name: "Jemboy Requis",
                role: "System Designer",
                roleIcon: Icons.settings,
                description:
                    "Designs the system structure and overall flow of the application.",
                imagePath: "images/jemboy.png",
                email: "jemboyrequis8@gmail.com",
              ),

              const SizedBox(height: 40),

              // ============================================
              // FOOTER
              // ============================================
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 2,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.eco,
                    color: Color(0xFF43A047),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 60,
                    height: 2,
                    color: Colors.grey.shade300,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                "FertilizerCalc Team",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // BULLET POINT HELPER
  // ============================================
  static Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF43A047),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Color(0xFF555555),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // TEAM CARD BUILDER
  // ============================================
  Widget _buildTeamCard({
    required BuildContext context,
    required String name,
    required String role,
    required IconData roleIcon,
    required String description,
    required String imagePath,
    required String email,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          size: 50,
                          color: Color(0xFF43A047),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      const SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              roleIcon,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              role,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF666666),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            GestureDetector(
              onTap: () => _sendEmail(context, email),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFA5D6A7),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEA4335),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.email,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        email,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1B5E20),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Color(0xFF2E7D32),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
