import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';

// Mock classes (replace with actual imports from main.dart)
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
    required this.additionalImages,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Base URL for network images (update with your server URL)
    const String baseUrl = 'http://yourdomain.com';
    String image = json['image'] ?? '';
    List<String> additionalImages =
        (json['additionalImages'] as List<dynamic>?)?.cast<String>() ?? [];

    // Fix relative paths
    if (image.isNotEmpty && !image.startsWith('assets/') && !image.startsWith('http')) {
      image = image.startsWith('/') ? '$baseUrl$image' : '$baseUrl/$image';
    }
    additionalImages = additionalImages.map((img) {
      if (img.isNotEmpty && !img.startsWith('assets/') && !img.startsWith('http')) {
        return img.startsWith('/') ? '$baseUrl$img' : '$baseUrl/$img';
      }
      return img;
    }).toList();

    return Product(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Unknown',
      category: json['category'] ?? 'Other',
      description: (json['description'] as List<dynamic>?)
              ?.map((desc) => ProductDescription.fromJson(desc))
              .toList() ??
          [],
      image: image,
      additionalImages: additionalImages,
    );
  }

  List<String> getAllImages() {
    return [image, ...additionalImages].where((img) => img.isNotEmpty).toList();
  }
}

class ProductDescription {
  final String key;
  final String value;

  ProductDescription({required this.key, required this.value});

  factory ProductDescription.fromJson(Map<String, dynamic> json) {
    return ProductDescription(
      key: json['key'] ?? '',
      value: json['value'] ?? '',
    );
  }
}

class AppUtils {
  static Widget buildImageLoadingWidget() {
    return const Center(
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E3A8A)),
      ),
    );
  }
}

class ProductSearchDelegate extends SearchDelegate<Product> {
  final List<Product> products;
  final void Function(Product) showProductDetails;

  ProductSearchDelegate(this.products, this.showProductDetails);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null as Product);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = products
        .where((product) =>
            product.title.toLowerCase().contains(query.toLowerCase()) ||
            product.category.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return _buildSearchResults(context, results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = products
        .where((product) =>
            product.title.toLowerCase().contains(query.toLowerCase()) ||
            product.category.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return _buildSearchResults(context, suggestions);
  }

  Widget _buildSearchResults(BuildContext context, List<Product> results) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final product = results[index];
        return ListTile(
          title: Text(
            product.title,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            product.category,
            style: GoogleFonts.poppins(color: Colors.grey[600]),
          ),
          leading: product.image.isNotEmpty
              ? product.image.startsWith('assets/')
                  ? Image.asset(product.image, width: 50, height: 50, fit: BoxFit.contain)
                  : CachedNetworkImage(
                      imageUrl: product.image,
                      width: 50,
                      height: 50,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => AppUtils.buildImageLoadingWidget(),
                      errorWidget: (context, url, error) {
                        print('Search image error for $url: $error');
                        return const Icon(Icons.error);
                      },
                    )
              : const Icon(Icons.image_not_supported),
          onTap: () {
            showProductDetails(product);
          },
        );
      },
    );
  }
}

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Product> _products = [];
  List<Product> _displayedProducts = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 0;
  final int _pageSize = 20;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
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
      print('Raw JSON: $response');
      final dynamic jsonData = json.decode(response);
      print('Parsed JSON: $jsonData');

      if (jsonData is! List) {
        throw Exception('JSON root should be a List');
      }

      final List<Product> loadedProducts =
          jsonData.map<Product>((json) => Product.fromJson(json)).toList();
      print('Loaded Products: ${loadedProducts.length}');

      setState(() {
        _products = _sortProductsByCategory(loadedProducts);
        _displayedProducts = _applyCategoryFilter(_products, _selectedCategory);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading products: $e');
      setState(() {
        _products = [
          Product(
            id: 124,
            title: "WPC Door Test",
            category: "WPC_Door",
            description: [
              ProductDescription(key: "Main Lock", value: "A28-20"),
              ProductDescription(
                key: "Handle",
                value: "BL902 fingerprint password handle",
              ),
            ],
            image:
                "http://img202.yun300.cn/repository/image/58f54933-fc1b-4e65-98c5-1814200c2b54.jpg?tenantId=237541&viewType=1",
            additionalImages: [],
          ),
        ];
        _displayedProducts = _applyCategoryFilter(_products, _selectedCategory);
        _isLoading = false;
      });
    }
  }

  void _loadMoreProducts() {
    if (_isLoadingMore ||
        (_currentPage + 1) * _pageSize >= _filteredProducts().length) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _currentPage++;
        _displayedProducts.addAll(
          _filteredProducts().skip(_currentPage * _pageSize).take(_pageSize).toList(),
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

  List<Product> _filteredProducts() {
    return _applyCategoryFilter(_products, _selectedCategory);
  }

  List<Product> _applyCategoryFilter(List<Product> products, String? category) {
    if (category == null || category == 'All Products') {
      return products
          .where((product) {
            String categoryLower = product.category.toLowerCase();
            return !categoryLower.contains('poster') &&
                !categoryLower.contains('quality door');
          })
          .toList();
    }

    return products
        .where((product) {
          String categoryLower = product.category.toLowerCase();
          if (category == 'WPC Door') {
            return categoryLower.contains('wpc');
          } else if (category == 'Wooden Door') {
            return categoryLower.contains('wood') || categoryLower.contains('wooden');
          } else if (category == 'Hardware') {
            return categoryLower.contains('hardware');
          } else if (category == 'Other') {
            return !categoryLower.contains('wpc') &&
                !categoryLower.contains('wood') &&
                !categoryLower.contains('wooden') &&
                !categoryLower.contains('hardware') &&
                !categoryLower.contains('poster') &&
                !categoryLower.contains('quality door');
          }
          return false;
        })
        .toList();
  }

  void _selectCategory(String? category) {
    setState(() {
      _selectedCategory = category;
      _currentPage = 0;
      _displayedProducts =
          _applyCategoryFilter(_products, _selectedCategory).take(_pageSize).toList();
    });
  }

  Color _getCategoryColor(String category) {
    String categoryLower = category.toLowerCase();
    if (categoryLower.contains('wpc')) {
      return const Color(0xFF10B981);
    } else if (categoryLower.contains('wooden') || categoryLower.contains('wood')) {
      return const Color(0xFFF59E0B);
    } else if (categoryLower.contains('security')) {
      return const Color(0xFF1E3A8A);
    } else if (categoryLower.contains('hardware')) {
      return const Color(0xFF64748B);
    } else {
      return const Color(0xFFD946EF);
    }
  }

  IconData _getCategoryIcon(String category) {
    String categoryLower = category.toLowerCase();
    if (categoryLower.contains('wpc')) {
      return Icons.eco_rounded;
    } else if (categoryLower.contains('wooden') || categoryLower.contains('wood')) {
      return Icons.forest_rounded;
    } else if (categoryLower.contains('security')) {
      return Icons.security_rounded;
    } else if (categoryLower.contains('hardware')) {
      return Icons.precision_manufacturing_rounded;
    } else {
      return Icons.door_front_door_rounded;
    }
  }

  Widget _buildCategoryFilter() {
    final categories = ['All', 'WPC Door', 'Wooden Door', 'Hardware', 'Other'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: categories.map((category) {
          final isSelected =
              _selectedCategory == category || (category == 'All' && _selectedCategory == null);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                category,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey[600],
                ),
              ),
              selected: isSelected,
              selectedColor: const Color(0xFF1E3A8A).withOpacity(0.2),
              backgroundColor: Colors.grey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey[300]!,
                  width: 1,
                ),
              ),
              onSelected: (selected) {
                if (selected) {
                  _selectCategory(category == 'All' ? null : category);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductGrid() {
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _displayedProducts.length,
          itemBuilder: (context, index) {
            return _buildProductCard(_displayedProducts[index], index);
          },
        ),
        if (_isLoadingMore)
          const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E3A8A)),
            ),
          ),
      ],
    );
  }

  Widget _buildProductCard(Product product, int index) {
    return GestureDetector(
      onTap: () => _showProductDetails(product),
      child: Card(
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: Colors.grey,
            width: 0.5,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey[50]!.withOpacity(0.8),
              ],
              stops: const [0.0, 1.0],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: Hero(
                        tag: 'product-${product.id}',
                        child: product.image.startsWith('assets/')
                            ? Image.asset(
                                product.image,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  print('Asset image error for ${product.image}: $error');
                                  return _buildErrorImage(product);
                                },
                              )
                            : CachedNetworkImage(
                                imageUrl: product.image,
                                fit: BoxFit.contain,
                                placeholder: (context, url) => AppUtils.buildImageLoadingWidget(),
                                errorWidget: (context, url, error) {
                                  print('Network image error for $url: $error');
                                  return _buildErrorImage(product);
                                },
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.title,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F2937),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _showProductDetails(product),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            textStyle: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.4,
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.visibility_rounded, size: 18),
                              SizedBox(width: 6),
                              Text('View Details'),
                            ],
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
    );
  }

  Widget _buildErrorImage(Product product) {
    return Container(
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getCategoryIcon(product.category),
            size: 40,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 8),
          Text(
            product.category,
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImageGallery(BuildContext context, Product product, int initialIndex) {
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
                  child: imagePath.startsWith('assets/')
                      ? Image.asset(
                          imagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            print('Asset image error for $imagePath: $error');
                            return _buildErrorImagePlaceholder(index);
                          },
                        )
                      : CachedNetworkImage(
                          imageUrl: imagePath,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => AppUtils.buildImageLoadingWidget(),
                          errorWidget: (context, url, error) {
                            print('Network image error for $url: $error');
                            return _buildErrorImagePlaceholder(index);
                          },
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

  Widget _buildErrorImagePlaceholder(int index) {
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
              'Image ${index + 1} not available',
              style: GoogleFonts.poppins(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
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
                                                  child: imagePath.startsWith('assets/')
                                                      ? Image.asset(
                                                          imagePath,
                                                          fit: BoxFit.contain,
                                                          errorBuilder: (context, error, stackTrace) {
                                                            print('Asset image error for $imagePath: $error');
                                                            return _buildErrorImagePlaceholder(imageIndex);
                                                          },
                                                        )
                                                      : CachedNetworkImage(
                                                          imageUrl: imagePath,
                                                          fit: BoxFit.contain,
                                                          placeholder: (context, url) =>
                                                              AppUtils.buildImageLoadingWidget(),
                                                          errorWidget: (context, url, error) {
                                                            print('Network image error for $url: $error');
                                                            return _buildErrorImagePlaceholder(imageIndex);
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
                                            onPressed: () =>
                                                _showFullScreenImageGallery(context, product, currentImageIndex),
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
                                  : _buildErrorImagePlaceholder(0),
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
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1F2937),
                                  ),
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
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1F2937),
                                  ),
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
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: const Color(0xFF1F2937),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  desc.value,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: const Color(0xFF6B7280),
                                                  ),
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
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Ready to Order?',
                                      style: GoogleFonts.poppins(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF1F2937),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Contact our team for pricing and availability',
                                      style: GoogleFonts.poppins(
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
                                            onPressed: _launchEmail,
                                            icon: const Icon(Icons.email_rounded, size: 18),
                                            label: Text(
                                              'Email Us',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF1E3A8A),
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: _launchTelegram,
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
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
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

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'contact@wonderdoor.com',
      queryParameters: {
        'subject': 'Product Inquiry - Wonder Door Industrial',
        'body': 'Hello,\n\nI am interested in your door products and would like to get more information.\n\nBest regards,',
      },
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        _showContactDialog('Email', 'contact@wonderdoor.com');
      }
    } catch (e) {
      print('Error launching email: $e');
      _showContactDialog('Email', 'contact@wonderdoor.com');
    }
  }

  Future<void> _launchTelegram() async {
    final Uri telegramUri = Uri.parse('https://t.me/WonderADF_168');

    try {
      if (await canLaunchUrl(telegramUri)) {
        await launchUrl(telegramUri, mode: LaunchMode.externalApplication);
      } else {
        _showContactDialog('Telegram', '@WonderADF_168');
      }
    } catch (e) {
      print('Error launching Telegram: $e');
      _showContactDialog('Telegram', '@WonderADF_168');
    }
  }

  void _showContactDialog(String platform, String contact) {
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
                size: 20,
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
                    : 'Message us for quick responses!',
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
                _showSnackBar('$platform contact copied!');
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
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

  Widget _buildEmptyState() {
    return Center(
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
            'No products found',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check back later',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.grey[500],
            ),
          ),
        ],
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
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ProductSearchDelegate(_products, _showProductDetails),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: AppUtils.buildImageLoadingWidget())
          : _products.isEmpty
              ? _buildEmptyState()
              : SingleChildScrollView(
                  controller: _scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'All Products',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Browse our entire collection',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildCategoryFilter(),
                        const SizedBox(height: 16),
                        _buildProductGrid(),
                      ],
                    ),
                  ),
                ),
    );
  }
}