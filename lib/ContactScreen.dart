import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main.dart'; // Import AppConfig from main.dart

class ContactScreen extends StatelessWidget {
  const ContactScreen({Key? key}) : super(key: key);

  Future<void> _launchEmail(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: AppConfig.email,
      queryParameters: {
        'subject': 'Contact Us - Wonder Door Industrial',
        'body':
            'Hello,\n\nI have a question about your products or services.\n\nBest regards,\n',
      },
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        _showContactDialog(context, 'Email', AppConfig.email);
      }
    } catch (e) {
      print('Error launching email: $e');
      _showContactDialog(context, 'Email', AppConfig.email);
    }
  }

  Future<void> _launchTelegram(BuildContext context) async {
    final Uri telegramUri = Uri.parse(AppConfig.telegramUrl);

    try {
      if (await canLaunchUrl(telegramUri)) {
        await launchUrl(telegramUri, mode: LaunchMode.externalApplication);
      } else {
        _showContactDialog(context, 'Telegram', AppConfig.telegramHandle);
      }
    } catch (e) {
      print('Error launching Telegram: $e');
      _showContactDialog(context, 'Telegram', AppConfig.telegramHandle);
    }
  }

  Future<void> _launchFacebook(BuildContext context) async {
    final Uri facebookUri = Uri.parse('https://www.facebook.com/WonderDoorIndustrial');

    try {
      if (await canLaunchUrl(facebookUri)) {
        await launchUrl(facebookUri, mode: LaunchMode.externalApplication);
      } else {
        _showContactDialog(context, 'Facebook', 'WonderDoorIndustrial');
      }
    } catch (e) {
      print('Error launching Facebook: $e');
      _showContactDialog(context, 'Facebook', 'WonderDoorIndustrial');
    }
  }

  Future<void> _launchTikTok(BuildContext context) async {
    final Uri tiktokUri = Uri.parse('https://www.tiktok.com/@wonderdoorindustrial');

    try {
      if (await canLaunchUrl(tiktokUri)) {
        await launchUrl(tiktokUri, mode: LaunchMode.externalApplication);
      } else {
        _showContactDialog(context, 'TikTok', '@wonderdoorindustrial');
      }
    } catch (e) {
      print('Error launching TikTok: $e');
      _showContactDialog(context, 'TikTok', '@wonderdoorindustrial');
    }
  }

  Future<void> _launchMap(BuildContext context) async {
    final Uri mapUri = Uri.parse('https://maps.app.goo.gl/T4L1uuBEviXsqyws5');

    try {
      if (await canLaunchUrl(mapUri)) {
        await launchUrl(mapUri, mode: LaunchMode.externalApplication);
      } else {
        _showContactDialog(context, 'Map', 'Phnom Penh, Cambodia');
      }
    } catch (e) {
      print('Error launching Map: $e');
      _showContactDialog(context, 'Map', 'Phnom Penh, Cambodia');
    }
  }

  void _showContactDialog(BuildContext context, String platform, String contact) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(
                platform == 'Email'
                    ? Icons.email_rounded
                    : platform == 'Telegram'
                        ? Icons.telegram_rounded
                        : platform == 'Facebook'
                            ? Icons.facebook_rounded
                            : platform == 'TikTok'
                                ? Icons.videocam_rounded
                                : Icons.map_rounded,
                color: const Color(0xFF1E3A8A),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Contact via $platform',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reach out to us on $platform:',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 12),
              SelectableText(
                contact,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                platform == 'Email'
                    ? 'We\'ll respond within 24 hours!'
                    : platform == 'Telegram'
                        ? 'Message us for quick responses!'
                        : platform == 'Facebook'
                            ? 'Follow us for updates!'
                            : platform == 'TikTok'
                                ? 'Check our latest videos!'
                                : 'View our location on Google Maps!',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: contact));
                Navigator.of(context).pop();
                _showSnackBar(context, '$platform contact copied!');
              },
              child: Text(
                'Copy',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E3A8A),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Close',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Wonder Door Industrial',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
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
                  'Get in Touch',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Connect with us through your preferred platform',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 3,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contact Us',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 3,
                          children: [
                            _buildContactButton(
                              context,
                              icon: Icons.email_rounded,
                              label: 'Email',
                              onPressed: () => _launchEmail(context),
                            ),
                            _buildContactButton(
                              context,
                              icon: Icons.telegram_rounded,
                              label: 'Telegram',
                              onPressed: () => _launchTelegram(context),
                            ),
                            _buildContactButton(
                              context,
                              icon: Icons.facebook_rounded,
                              label: 'Facebook',
                              onPressed: () => _launchFacebook(context),
                            ),
                            _buildContactButton(
                              context,
                              icon: Icons.videocam_rounded,
                              label: 'TikTok',
                              onPressed: () => _launchTikTok(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 3,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Our Location',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildContactButton(
                          context,
                          icon: Icons.map_rounded,
                          label: 'Phnom Penh, Cambodia',
                          onPressed: () => _launchMap(context),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _launchMap(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3A8A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              'View on Google Maps',
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 20,
        color: Colors.white,
      ),
      label: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
    );
  }
}