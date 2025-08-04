import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ContactScreen.dart'; // Import the ContactScreen.dart
import 'main.dart'; // Import AppConfig if needed

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Wonder Door Industrial',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white, // White text
          ),
        ),
        backgroundColor: const Color(0xFF1E3A8A), // Blue background
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Our Services',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 16),
                _buildServiceCard(
                  context: context,
                  icon: Icons.design_services_rounded,
                  title: 'Consultant Drawing with Proposal Material',
                  description:
                      'Experience the future with stylish and durable door solutions tailored for modern living.',
                ),
                const SizedBox(height: 16),
                _buildServiceCard(
                  context: context,
                  icon: Icons.construction_rounded,
                  title: 'Installation Service',
                  description:
                      'Our doors meet global quality standards, ensuring safety and longevity. Installation available in Phnom Penh city for \$25 and other provinces for \$35.',
                ),
                const SizedBox(height: 16),
                _buildServiceCard(
                  context: context,
                  icon: Icons.verified_rounded,
                  title: '5-Year Warranty',
                  description:
                      'We stand by our products, offering up to 5 years of warranty for peace of mind.',
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ContactScreen()),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'Contact Us for Services',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 48,
              color: const Color(0xFF1E3A8A),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B7280),
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