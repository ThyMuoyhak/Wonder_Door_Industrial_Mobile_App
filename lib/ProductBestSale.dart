import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart'; // Added import for url_launcher
import 'dart:convert';
import 'main.dart'; // Import main.dart for Product, AppUtils, AppConfig, etc.

class ProductBestSale extends StatefulWidget {
  const ProductBestSale({Key? key}) : super(key: key);

  @override
  _ProductBestSaleState createState() => _ProductBestSaleState();
}

class _ProductBestSaleState extends State<ProductBestSale> {
  List<Product> bestSellingProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBestSellingProducts();
  }

  Future<void> _loadBestSellingProducts() async {
    try {
      final String response = await rootBundle.loadString('assets/data.json');
      final dynamic jsonData = json.decode(response);

      if (jsonData is! List) {
        throw Exception('JSON root should be a List');
      }

      final List<Product> allProducts =
          jsonData.map<Product>((json) => Product.fromJson(json)).toList();

      // Filter best-selling products (example: based on category containing "wpc" or "wooden")
      // Adjust this logic based on your data.json structure
      final List<Product> filteredProducts = allProducts
          .where((product) =>
              product.category.toLowerCase().contains('wpc') ||
              product.category.toLowerCase().contains('wooden'))
          .toList();

      setState(() {
        bestSellingProducts = filteredProducts.isNotEmpty
            ? filteredProducts
            : allProducts.take(5).toList(); // Fallback to first 5 products if no best sellers
        isLoading = false;
      });
    } catch (e) {
      print('Error loading best-selling products: $e');
      setState(() {
        isLoading = false;
      });
      _showSnackBar(context, 'Failed to load best-selling products.');
    }
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

  void _showImageDialog(BuildContext context, Product product, int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              product.title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: PageView.builder(
            controller: PageController(initialPage: initialIndex),
            itemCount: product.getAllImages().length,
            itemBuilder: (context, index) {
              String imagePath = product.getAllImages()[index];
              return InteractiveViewer(
                panEnabled: true,
                boundaryMargin: const EdgeInsets.all(16),
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: imagePath,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => AppUtils.buildImageLoadingWidget(),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[900],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported_rounded,
                              size: 48,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Image ${index + 1} not available',
                              style: GoogleFonts.roboto(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _showProductDetails(BuildContext context, Product product) {
    final PageController pageController = PageController();
    int currentImageIndex = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 300,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: product.getAllImages().isNotEmpty
                                  ? Stack(
                                      children: [
                                        StatefulBuilder(
                                          builder: (context, setState) {
                                            return PageView.builder(
                                              controller: pageController,
                                              itemCount: product.getAllImages().length,
                                              onPageChanged: (index) {
                                                setState(() {
                                                  currentImageIndex = index;
                                                });
                                              },
                                              itemBuilder: (context, imageIndex) {
                                                String imagePath = product.getAllImages()[imageIndex];
                                                return Hero(
                                                  tag: 'product-image-${product.id}-$imageIndex',
                                                  child: CachedNetworkImage(
                                                    imageUrl: imagePath,
                                                    fit: BoxFit.cover,
                                                    placeholder: (context, url) => AppUtils.buildImageLoadingWidget(),
                                                    errorWidget: (context, url, error) => Container(
                                                      color: Colors.grey[900],
                                                      child: Center(
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Icon(
                                                              Icons.image_not_supported_rounded,
                                                              size: 48,
                                                              color: Colors.grey[600],
                                                            ),
                                                            const SizedBox(height: 12),
                                                            Text(
                                                              'Image ${imageIndex + 1} not available',
                                                              style: GoogleFonts.roboto(
                                                                color: Colors.grey[400],
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: IconButton(
                                            icon: const Icon(Icons.fullscreen_rounded, color: Colors.white),
                                            onPressed: () => _showImageDialog(context, product, currentImageIndex),
                                          ),
                                        ),
                                        if (product.getAllImages().length > 1)
                                          Positioned(
                                            bottom: 8,
                                            left: 0,
                                            right: 0,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: List.generate(
                                                product.getAllImages().length,
                                                (index) => Container(
                                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                                  width: 8,
                                                  height: 8,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: index == currentImageIndex
                                                        ? Colors.white
                                                        : Colors.white.withOpacity(0.5),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    )
                                  : Container(
                                      color: Colors.grey[900],
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.image_not_supported_rounded,
                                              size: 48,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              'Image not available',
                                              style: GoogleFonts.roboto(
                                                color: Colors.grey[400],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFA500).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Best Seller',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFFFFA500),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  product.title,
                                  style: Theme.of(context).textTheme.displayLarge,
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 32),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Specifications',
                                  style: Theme.of(context).textTheme.displayLarge,
                                ),
                                const SizedBox(height: 16),
                                ...product.description.asMap().entries.map(
                                      (entry) {
                                        int index = entry.key;
                                        ProductDescription desc = entry.value;
                                        return AnimatedContainer(
                                          duration: Duration(milliseconds: 200 + (index * 50)),
                                          margin: const EdgeInsets.only(bottom: 12),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[50],
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  desc.key,
                                                  style: Theme.of(context).textTheme.titleMedium,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  desc.value,
                                                  style: Theme.of(context).textTheme.bodyMedium,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Ready to Order?',
                                      style: Theme.of(context).textTheme.displayLarge,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Contact our team for pricing and availability',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () => _launchEmail(context),
                                            icon: const Icon(Icons.email_rounded, size: 18),
                                            label: Text(
                                              'Email Us',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () => _launchTelegram(context),
                                            icon: const Icon(Icons.telegram_rounded, size: 18),
                                            label: Text(
                                              'Chat Now',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: const Color(0xFF1E3A8A),
                                              side: const BorderSide(color: Color(0xFF1E3A8A)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _launchEmail(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: AppConfig.email,
      queryParameters: {
        'subject': 'Product Inquiry - Wonder Door Industrial (Best Sellers)',
        'body':
            'Hello,\n\nI am interested in your best-selling products and would like to get more information.\n\nBest regards,\n',
      },
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        _showContactDialog(context, 'Email', AppConfig.email);
      }
    } catch (e) {
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
      _showContactDialog(context, 'Telegram', AppConfig.telegramHandle);
    }
  }

  void _showContactDialog(BuildContext context, String platform, String contact) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(
                platform == 'Email' ? Icons.email_rounded : Icons.telegram_rounded,
                color: const Color(0xFF1E3A8A),
                size: 25,
              ),
              const SizedBox(width: 8),
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
                style: GoogleFonts.roboto(
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
                    : 'Message us for quick responses!',
                style: GoogleFonts.roboto(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Best Selling Products',
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
        child: isLoading
            ? Center(child: AppUtils.buildImageLoadingWidget())
            : bestSellingProducts.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: bestSellingProducts.length,
                    itemBuilder: (context, index) {
                      final product = bestSellingProducts[index];
                      return GestureDetector(
                        onTap: () => _showProductDetails(context, product),
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius:
                                    const BorderRadius.vertical(top: Radius.circular(12)),
                                child: CachedNetworkImage(
                                  imageUrl: product.image,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      AppUtils.buildImageLoadingWidget(),
                                  errorWidget: (context, url, error) => Container(
                                    height: 200,
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFA500).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Best Seller',
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFFFFA500),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      product.title,
                                      style: Theme.of(context).textTheme.titleMedium,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton(
                                        onPressed: () => _showProductDetails(context, product),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: const Color(0xFF1E3A8A),
                                          side: const BorderSide(color: Color(0xFF1E3A8A)),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          padding:
                                              const EdgeInsets.symmetric(vertical: 10),
                                        ),
                                        child: Text(
                                          'View Details',
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
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Container(
        height: 240,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 40,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No best-selling products found',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for updates',
              style: GoogleFonts.roboto(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}