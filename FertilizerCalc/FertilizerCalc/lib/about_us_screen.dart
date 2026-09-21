import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ============================================
              // HEADER
              // ============================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                decoration: const BoxDecoration(
                  color: Color(0xFF2E7D32),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "FertilizerCalc",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
              // TEAM MEMBER 1 — JOSHUA D. SABAS
              // ============================================
              _buildTeamCard(
                name: "Joshua D. Sabas",
                role: "Developer",
                roleIcon: Icons.code,
                description:
                    "Handles the development of the FertilizerCalc mobile application.",
                imagePath: "images/joshua.png",
              ),

              const SizedBox(height: 16),

              // ============================================
              // TEAM MEMBER 2 — RENDILLE O. GAGAM
              // ============================================
              _buildTeamCard(
                name: "Rendille O. Gagam",
                role: "UI/UX Designer",
                roleIcon: Icons.palette,
                description:
                    "Designs the interface and user experience of the application.",
                imagePath: "images/rendille.png",
              ),

              const SizedBox(height: 16),

              // ============================================
              // TEAM MEMBER 3 — JEMBOY REQUIS
              // ============================================
              _buildTeamCard(
                name: "Jemboy Requis",
                role: "System Designer",
                roleIcon: Icons.settings,
                description:
                    "Designs the system structure and overall flow of the application.",
                imagePath: "images/jemboy.png",
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
  // TEAM CARD BUILDER
  // ============================================
  static Widget _buildTeamCard({
    required String name,
    required String role,
    required IconData roleIcon,
    required String description,
    required String imagePath,
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PROFILE PICTURE
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

            // INFO
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

                  // ROLE BADGE
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
      ),
    );
  }
}
