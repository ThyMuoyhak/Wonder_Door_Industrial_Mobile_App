import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

class OurProject2025Widget extends StatelessWidget {
  const OurProject2025Widget({super.key});

  final List<Map<String, String>> _projectImages = const [
    {
      'image': 'https://scontent.fpnh25-1.fna.fbcdn.net/v/t39.30808-6/515437920_122218531820171065_8820080453046290790_n.jpg?_nc_cat=110&ccb=1-7&_nc_sid=833d8c&_nc_eui2=AeF5heRVLUzZaEOTeQ6-2DM7KgwP1qsRNdYqDA_WqxE11gZ9zrAcEoFk_twd6DhbggnNA7K8EQSoTOfYx5Cy1-gk&_nc_ohc=OfdXfHeo8z4Q7kNvwHpd4h9&_nc_oc=AdkpN-4ZlOcdjiqSlfIL0QMQxlFLBiyKJerEv_9bNlK_TLJfaBQDIK9YCOyNxu6q6BQ&_nc_zt=23&_nc_ht=scontent.fpnh25-1.fna&_nc_gid=althEFCpjR7XOIH5q7YVWQ&oh=00_AfQ5DXKKNBC2ASnG-tqkU0raDSmfpSnCEJo0Xl5JU3hZTg&oe=688E3B91',
      'title': 'Project Showcase 1',
    },
    {
      'image': 'https://images.unsplash.com/photo-1497366754035-f8d84f6f6c7e?w=600&h=600&fit=crop&auto=format',
      'title': 'Project Showcase 2',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Our Project 2025',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.0, // Ensures square items
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _projectImages.length,
            itemBuilder: (context, index) {
              return _buildProjectCard(context, _projectImages[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, Map<String, String> project) {
    return GestureDetector(
      onTap: () {
        // Add navigation or action if needed
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: project['image']!,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E3A8A)),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[100],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.image_not_supported_rounded,
                    size: 40,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Image Error',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}