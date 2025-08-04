import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'productScreen.dart'; // Assumed to exist
import 'ServicesScreen.dart'; // Assumed to exist
import 'ContactScreen.dart'; // Assumed to exist

// Configuration class for contact information
class AppConfig {
  static const String email = 'contact@wonderdoor.com';
  static const String telegramHandle = '@WonderADF_168';
  static const String telegramUrl = 'https://t.me/WonderADF_168';
  static const String telegramAppUrl = 'tg://resolve?domain=WonderADF_168';
}

// Utility class for shared widgets
class AppUtils {
  static Widget buildImageLoadingWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E3A8A)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading...',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wonder Door Industrial',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A),
          brightness: Brightness.light,
        ).copyWith(
          primary: const Color(0xFF1E3A8A),
          secondary: const Color(0xFFD946EF),
          tertiary: const Color(0xFF10B981),
          surface: Colors.white,
          surfaceContainer: const Color(0xFFF8FAFC),
          onSurface: Colors.grey[900],
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
        ),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
            letterSpacing: 0.2,
          ),
          titleLarge: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
            letterSpacing: 0.1,
          ),
          titleMedium: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
            letterSpacing: 0.1,
          ),
          bodyLarge: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF6B7280),
            letterSpacing: 0.3,
          ),
          bodyMedium: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF6B7280),
            letterSpacing: 0.3,
          ),
          labelLarge: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
            letterSpacing: 0.2,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E3A8A),
            foregroundColor: Colors.white,
            textStyle: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade100, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class Product {
  final int id;
  final String title;
  final String category;
  final List<ProductDescription> description;
  final String image;
  final List<String> additionalImages;

  Product({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.image,
    this.additionalImages = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    try {
      List<String> additionalImages = [];
      for (int i = 1; i <= 10; i++) {
        String imageKey = 'image$i';
        if (json[imageKey] != null && json[imageKey].toString().isNotEmpty) {
          String imagePath = json[imageKey].toString();
          if (!imagePath.startsWith('assets/')) {
            imagePath = 'assets$imagePath';
          }
          additionalImages.add(imagePath);
        }
      }

      String mainImage = json['image']?.toString() ?? '';
      if (!mainImage.startsWith('assets/') && mainImage.isNotEmpty) {
        mainImage = 'assets$mainImage';
      }

      String fallbackImage = 'assets/images/fallback.jpg';

      return Product(
        id: json['id'] ?? 0,
        title: json['title']?.toString() ?? 'Unknown Product',
        category: json['category']?.toString() ?? 'Unknown Category',
        description: (json['description'] as List?)
                ?.map((desc) => ProductDescription.fromJson(desc))
                .toList() ??
            [],
        image: mainImage.isNotEmpty ? mainImage : fallbackImage,
        additionalImages:
            additionalImages.isNotEmpty ? additionalImages : [fallbackImage],
      );
    } catch (e) {
      print('❌ Error parsing product: $e');
      rethrow;
    }
  }

  List<String> getAllImages() {
    List<String> allImages = [];
    if (image.isNotEmpty) allImages.add(image);
    allImages.addAll(additionalImages);
    return allImages;
  }
}

class ProductDescription {
  final String key;
  final String value;

  ProductDescription({required this.key, required this.value});

  factory ProductDescription.fromJson(Map<String, dynamic> json) {
    try {
      return ProductDescription(
        key: json['key']?.toString() ?? 'Unknown',
        value: json['value']?.toString() ?? 'Unknown',
      );
    } catch (e) {
      print('Error parsing product description: $e');
      rethrow;
    }
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ProductsScreen(),
    const ServicesScreen(),
    const ContactScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, 'Home'),
                _buildNavItem(1, Icons.door_front_door_rounded, 'Products'),
                _buildNavItem(2, Icons.build_rounded, 'Services'),
                _buildNavItem(3, Icons.contact_phone_rounded, 'Contact'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1E3A8A).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey[500],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  late Timer _timer;
  int _currentSlide = 0;
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<Product> _displayedProducts = [];
  List<Product> _bestSaleProducts = [];
  List<Product> _qualityProducts = [];
  List<Product> _posterDoorProducts = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String _selectedCategory = 'WPC Door';
  int _currentPage = 0;
  final int _pageSize = 20;

  final List<Map<String, String>> _slideImages = [
    {
      'image': 'assets/image/hero/slideshow.jpg',
      'title': '',
      'subtitle': '',
    },
    {
      'image': 'assets/image/hero/slideshow.jpg',
      'title': '',
      'subtitle': '',
    },
    {
      'image': 'assets/image/hero/slideshow.jpg',
      'title': '',
      'subtitle': '',
    },
  ];

  final List<Map<String, String>> _projectImages = [
    {
      'image': 'assets/image/project/pic1.jpg',
      'title': 'Project Showcase 2025',
    },
    {
      'image': 'assets/image/project/pic2.jpg',
      'title': 'View Products with Website',
    },
  ];

  final List<Map<String, String>> _warrantyImages = [
    {'image': 'assets/image/hardware/pic1.jpg', 'title': ''},
    {'image': 'assets/image/hardware/pic2.jpg', 'title': ''},
    {'image': 'assets/image/hardware/pic3.jpg', 'title': ''},
    {'image': 'assets/image/hardware/pic4.jpg', 'title': ''},
    {'image': 'assets/image/hardware/pic5.jpg', 'title': ''},
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentSlide = (_currentSlide + 1) % _slideImages.length;
        });
        _pageController.animateToPage(
          _currentSlide,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore) {
      _loadMoreProducts();
    }
  }

  Future<void> _loadProducts() async {
    try {
      final String response = await rootBundle.loadString('assets/data.json');
      final dynamic jsonData = json.decode(response);

      if (jsonData is! List) {
        throw Exception('JSON root should be a List');
      }

      final List<Product> loadedProducts =
          jsonData.map<Product>((json) => Product.fromJson(json)).toList();

      setState(() {
        _products = loadedProducts;
        List<Product> filteredInitialProducts = loadedProducts.where((product) {
          String productCategory = product.category.toLowerCase();
          return !productCategory.contains('poster') &&
                 !productCategory.contains('quality door');
        }).toList();
        
        _filteredProducts = _sortProductsByCategory(filteredInitialProducts);
        _filterProductsByCategory('WPC Door');
        _bestSaleProducts = loadedProducts
            .where((product) => product.category.toLowerCase() == 'poster door')
            .take(6)
            .toList();
        _qualityProducts = loadedProducts
            .where((product) => product.category.toLowerCase() == 'quality door')
            .take(6)
            .toList();
        _posterDoorProducts = loadedProducts
            .where((product) => product.category.toLowerCase() == 'poster door')
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading products: $e');
      setState(() {
        _isLoading = false;
      });
      _showSnackBar(context, 'Failed to load products. Please try again.');
    }
  }

  void _loadMoreProducts() {
    if (_isLoadingMore ||
        (_currentPage + 1) * _pageSize >= _filteredProducts.length) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _currentPage++;
        _displayedProducts.addAll(
          _filteredProducts
              .skip(_currentPage * _pageSize)
              .take(_pageSize)
              .toList(),
        );
        _isLoadingMore = false;
      });
    });
  }

  List<Product> _sortProductsByCategory(List<Product> products) {
    final categoryPriority = {
      'wpc': 1,
      'wood': 2,
      'hardware': 3,
      'other': 4,
    };

    return products.toList()
      ..sort((a, b) {
        String aCategory = a.category.toLowerCase();
        String bCategory = b.category.toLowerCase();

        int aPriority = categoryPriority.entries
            .firstWhere(
              (entry) => aCategory.contains(entry.key),
              orElse: () => const MapEntry('other', 4),
            )
            .value;
        int bPriority = categoryPriority.entries
            .firstWhere(
              (entry) => bCategory.contains(entry.key),
              orElse: () => const MapEntry('other', 4),
            )
            .value;

        return aPriority.compareTo(bPriority);
      });
  }

  void _filterProductsByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _currentPage = 0;
      
      List<Product> baseProducts = _products.where((product) {
        String productCategory = product.category.toLowerCase();
        return !productCategory.contains('poster') &&
               !productCategory.contains('quality door');
      }).toList();
      
      _filteredProducts = baseProducts.where((product) {
        String productCategory = product.category.toLowerCase();
        String selectedCategory = category.toLowerCase();
        
        if (selectedCategory == 'wpc door') {
          return productCategory.contains('wpc');
        } else if (selectedCategory == 'wooden door') {
          return productCategory.contains('wood') || productCategory.contains('wooden');
        } else if (selectedCategory == 'hardware') {
          return productCategory.contains('hardware');
        } else if (selectedCategory == 'other product') {
          return !productCategory.contains('wpc') &&
                 !productCategory.contains('wood') &&
                 !productCategory.contains('wooden') &&
                 !productCategory.contains('hardware');
        }
        return productCategory.contains(selectedCategory);
      }).toList();
      
      _displayedProducts = _filteredProducts.take(_pageSize).toList();
    });
  }

  Widget _buildHeroSection() {
    return Container(
      height: 280,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentSlide = index),
              itemCount: _slideImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      _slideImages[index]['image']!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading hero image ${_slideImages[index]['image']}: $error');
                        return Container(
                          color: const Color(0xFF1E3A8A),
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    _slideImages.length,
                    (index) => GestureDetector(
                      onTap: () => _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentSlide == index ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _currentSlide == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBestSaleSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Best Sale Products',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          _bestSaleProducts.isEmpty
              ? const Center(child: Text('No Best Sale Products Available'))
              : SizedBox(
                  height: 150,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _bestSaleProducts.length,
                    itemBuilder: (context, index) =>
                        _buildBestSaleCard(_bestSaleProducts[index], index),
                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildBestSaleCard(Product product, int index) {
    return GestureDetector(
      onTap: () => _showImageModal(context, product.title, product.image),
      child: Container(
        width: 150,
        height: 150,
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
          child: Image.asset(
            product.image,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('Error loading best sale image ${product.image}: $error');
              return Image.asset(
                'assets/images/fallback.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading fallback image: $error');
                  return const Icon(Icons.image_not_supported, size: 50);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProjectsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Our Projects 2025',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(
              _projectImages.length,
              (index) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: GestureDetector(
                    onTap: () => _showImageModal(context, _projectImages[index]['title']!, _projectImages[index]['image']!),
                    child: Container(
                      height: 150,
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
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              _projectImages[index]['image']!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print('Error loading project image ${_projectImages[index]['image']}: $error');
                                return Container(
                                  color: Colors.grey[100],
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_not_supported_rounded,
                                        size: 40,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Project Image',
                                        style: GoogleFonts.poppins(
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.1),
                                    Colors.black.withOpacity(0.4),
                                  ],
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Text(
                                    _projectImages[index]['title']!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityProductsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quality Products',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          _qualityProducts.isEmpty
              ? const Center(child: Text('No Quality Products Available'))
              : SizedBox(
                  height: 150,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _qualityProducts.length,
                    itemBuilder: (context, index) =>
                        _buildQualityProductCard(_qualityProducts[index], index),
                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildQualityProductCard(Product product, int index) {
    return GestureDetector(
      onTap: () => _showImageModal(context, product.title, product.image),
      child: Container(
        width: 150,
        height: 150,
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
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                product.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading quality product image ${product.image}: $error');
                  return Image.asset(
                    'assets/images/fallback.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading fallback image: $error');
                      return const Icon(Icons.image_not_supported, size: 50);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWarrantySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hardware',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _warrantyImages.length,
              itemBuilder: (context, index) =>
                  _buildWarrantyCard(_warrantyImages[index], index),
              separatorBuilder: (context, index) => const SizedBox(width: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarrantyCard(Map<String, String> warranty, int index) {
    return GestureDetector(
      onTap: () => _showImageModal(context, warranty['title']!, warranty['image']!),
      child: Container(
        width: 150,
        height: 150,
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
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                warranty['image']!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading warranty image ${warranty['image']}: $error');
                  return Container(
                    color: Colors.grey[100],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported_rounded,
                          size: 40,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Warranty Image',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }

  Widget _buildPosterDoorSection() {
    final int halfLength = (_posterDoorProducts.length / 2).ceil();
    final List<Product> firstRow = _posterDoorProducts.take(halfLength).toList();
    final List<Product> secondRow = _posterDoorProducts.skip(halfLength).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Door Products',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          _posterDoorProducts.isEmpty
              ? const Center(child: Text('No Door Products Available'))
              : Column(
                  children: [
                    SizedBox(
                      height: 150,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: firstRow.length,
                        itemBuilder: (context, index) =>
                            _buildPosterDoorCard(firstRow[index], index),
                        separatorBuilder: (context, index) => const SizedBox(width: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 150,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: secondRow.length,
                        itemBuilder: (context, index) =>
                            _buildPosterDoorCard(secondRow[index], index),
                        separatorBuilder: (context, index) => const SizedBox(width: 12),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildPosterDoorCard(Product product, int index) {
    return GestureDetector(
      onTap: () => _showImageModal(context, product.title, product.image),
      child: Container(
        width: 150,
        height: 150,
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
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                product.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading poster door image ${product.image}: $error');
                  return Image.asset(
                    'assets/images/fallback.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading fallback image: $error');
                      return const Icon(Icons.image_not_supported, size: 50);
                    },
                  );
                },
              ),
              ],
          ),
        ),
      ),
    );
  }

  void _showImageModal(BuildContext context, String title, String imagePath) {
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
              title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: const EdgeInsets.all(16),
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Center(
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading modal image $imagePath: $error');
                        return Container(
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
                                  'Image Not Available',
                                  style: GoogleFonts.roboto(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Container(
                color: Colors.black,
                padding: const EdgeInsets.all(16),
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Interested in this product?',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Contact our team for more information',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF6B7280),
                          ),
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
            ],
          ),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Color _getCategoryColor(String category) {
    String categoryLower = category.toLowerCase();
    if (categoryLower.contains('wpc')) {
      return const Color(0xFF10B981);
    } else if (categoryLower.contains('wooden') ||
        categoryLower.contains('wood')) {
      return const Color(0xFFF59E0B);
    } else if (categoryLower.contains('security')) {
      return const Color(0xFF1E3A8A);
    } else if (categoryLower.contains('hardware')) {
      return const Color(0xFF64748B);
    } else if (categoryLower.contains('poster')) {
      return const Color(0xFFD946EF);
    } else {
      return const Color(0xFFD946EF);
    }
  }

  IconData _getCategoryIcon(String category) {
    String categoryLower = category.toLowerCase();
    if (categoryLower.contains('wpc')) {
      return Icons.eco_rounded;
    } else if (categoryLower.contains('wooden') ||
        categoryLower.contains('wood')) {
      return Icons.forest_rounded;
    } else if (categoryLower.contains('security')) {
      return Icons.security_rounded;
    } else if (categoryLower.contains('hardware')) {
      return Icons.precision_manufacturing_rounded;
    } else if (categoryLower.contains('poster')) {
      return Icons.image_rounded;
    } else {
      return Icons.door_front_door_rounded;
    }
  }

  void _showProductDetails(Product product) {
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
                                                  child: Image.asset(
                                                    imagePath,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) {
                                                      print('Error loading product image $imagePath: $error');
                                                      return Image.asset(
                                                        'assets/images/fallback.jpg',
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context, error, stackTrace) {
                                                          print('Error loading fallback image: $error');
                                                          return const Icon(Icons.image_not_supported, size: 50);
                                                        },
                                                      );
                                                    },
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
                                            onPressed: () => _showImageModal(context, product.title, product.getAllImages()[currentImageIndex]),
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
                                  : Image.asset(
                                      'assets/images/fallback.jpg',
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        print('Error loading fallback image: $error');
                                        return const Icon(Icons.image_not_supported, size: 50);
                                      },
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
                                    color: _getCategoryColor(product.category).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    product.category,
                                    style: GoogleFonts.poppins(
                                      color: _getCategoryColor(product.category),
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
        'subject': 'Product Inquiry - Wonder Door Industrial',
        'body':
            'Hello,\n\nI am interested in your door products and would like to get more information.\n\nBest regards,\n',
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
    try {
      final Uri telegramAppUri = Uri.parse(AppConfig.telegramAppUrl);
      
      if (await canLaunchUrl(telegramAppUri)) {
        await launchUrl(telegramAppUri, mode: LaunchMode.externalApplication);
        return;
      }
      
      final Uri telegramWebUri = Uri.parse(AppConfig.telegramUrl);
      
      if (await canLaunchUrl(telegramWebUri)) {
        await launchUrl(telegramWebUri, mode: LaunchMode.externalApplication);
        return;
      }
      
      _showSnackBar(context, 'Please open Telegram and search for ${AppConfig.telegramHandle}');
      
    } catch (e) {
      print('Error launching Telegram: $e');
      _showSnackBar(context, 'Please open Telegram and search for ${AppConfig.telegramHandle}');
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
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ProductSearchDelegate(
                  _products,
                  _showProductDetails,
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: AppUtils.buildImageLoadingWidget())
          : SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroSection(),
                  _buildBestSaleSection(),
                  _buildProjectsSection(),
                  _buildQualityProductsSection(),
                  _buildWarrantySection(),
                  _buildPosterDoorSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}

class ProductSearchDelegate extends SearchDelegate<String> {
  final List<Product> products;
  final Function(Product) onProductSelected;

  ProductSearchDelegate(this.products, this.onProductSelected);

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        hintStyle: GoogleFonts.roboto(
          color: Colors.white70,
          fontSize: 16,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear_rounded, color: Colors.white),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = products
        .where(
          (product) =>
              product.title.toLowerCase().contains(query.toLowerCase()) ||
              product.category.toLowerCase().contains(query.toLowerCase()) ||
              product.description.any(
                (desc) =>
                    desc.key.toLowerCase().contains(query.toLowerCase()) ||
                    desc.value.toLowerCase().contains(query.toLowerCase()),
              ),
        )
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final product = results[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 48,
                height: 48,
                child: Image.asset(
                  product.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print('Error loading search result image ${product.image}: $error');
                    return const Icon(Icons.image_not_supported_rounded);
                  },
                ),
              ),
            ),
            title: Text(
              product.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.category,
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            onTap: () {
              close(context, product.title);
              onProductSelected(product);
            },
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = products
        .where(
          (product) =>
              product.title.toLowerCase().contains(query.toLowerCase()) ||
              product.category.toLowerCase().contains(query.toLowerCase()) ||
              product.description.any(
                (desc) =>
                    desc.key.toLowerCase().contains(query.toLowerCase()) ||
                    desc.value.toLowerCase().contains(query.toLowerCase()),
              ),
        )
        .take(5)
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final product = suggestions[index];
        return ListTile(
          leading: Icon(
            Icons.door_front_door_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          title: Text(
            product.title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: Text(
            product.category,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          onTap: () {
            query = product.title;
            showResults(context);
          },
        );
      },
    );
  }
}