import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
          if (imagePath.startsWith('/image/WPC_Door/') ||
              imagePath.startsWith('/image/Detail_WPC/')) {
            imagePath = 'assets$imagePath';
          } else if (imagePath.startsWith('/')) {
            imagePath = 'https://www.hz-qide.com$imagePath';
          }
          additionalImages.add(imagePath);
        }
      }

      String mainImage = json['image']?.toString() ?? '';
      if (mainImage.startsWith('/image/WPC_Door/') ||
          mainImage.startsWith('/image/Detail_WPC/')) {
        mainImage = 'assets$mainImage';
      } else if (mainImage.startsWith('/')) {
        mainImage = 'https://www.hz-qide.com$mainImage';
      }

      String category = json['category']?.toString().toLowerCase() ?? 'unknown';
      if (category.contains('wpc')) {
        category = 'WPC Door';
      } else if (category.contains('wood')) {
        category = 'Wooden Door';
      } else if (category.contains('hardware')) {
        category = 'Hardware';
      } else {
        category = 'Other Product';
      }

      String fallbackImage = _generateFallbackImage(category);

      return Product(
        id: json['id'] ?? 0,
        title: json['title']?.toString() ?? 'Unknown Product',
        category: category,
        description:
            (json['description'] as List?)
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

  static String _generateFallbackImage(String category) {
    String categoryLower = category.toLowerCase();
    if (categoryLower.contains('wpc')) {
      return 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=600&h=400&fit=crop&auto=format';
    } else if (categoryLower.contains('wooden') ||
        categoryLower.contains('wood')) {
      return 'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=600&h=400&fit=crop&auto=format';
    } else if (categoryLower.contains('security')) {
      return 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&h=400&fit=crop&auto=format';
    } else if (categoryLower.contains('hardware')) {
      return 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=600&h=400&fit=crop&auto=format';
    } else {
      return 'https://images.unsplash.com/photo-1493663284031-b7e3aaa4c4bc?w=600&h=400&fit=crop&auto=format';
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

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<Product> _displayedProducts = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String _selectedCategory = 'All Products';
  int _currentPage = 0;
  final int _pageSize = 20;

  List<Product> get products => _products;
  List<Product> get filteredProducts => _filteredProducts;
  List<Product> get displayedProducts => _displayedProducts;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String get selectedCategory => _selectedCategory;

  Future<void> loadProducts({String? serverUrl}) async {
    try {
      String response;
      if (serverUrl != null) {
        final result = await http.get(Uri.parse(serverUrl));
        if (result.statusCode == 200) {
          response = result.body;
        } else {
          print('HTTP request failed with status ${result.statusCode}, falling back to assets');
          response = await rootBundle.loadString('assets/data.json');
        }
      } else {
        response = await rootBundle.loadString('assets/data.json');
      }

      final dynamic jsonData = json.decode(response);
      if (jsonData is! List) {
        throw Exception('JSON root should be a List');
      }

      final List<Product> loadedProducts =
          jsonData.map<Product>((json) => Product.fromJson(json)).toList();

      _products = loadedProducts;
      _filteredProducts = _sortProductsByCategory(loadedProducts);
      _displayedProducts = _filteredProducts.take(_pageSize).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading products: $e');
      _products = [
        Product(
          id: -1,
          title: "WPC Door Test",
          category: "WPC Door",
          description: [
            ProductDescription(key: "Main Lock", value: "A28-20"),
            ProductDescription(
              key: "Handle",
              value: "BL902 fingerprint password handle",
            ),
          ],
          image: "assets/image/WPC_Door/pic5.jpg",
          additionalImages: [
            "assets/image/Detail_WPC/pic4.jpg",
            "assets/image/Detail_WPC/pic5.jpg",
          ],
        ),
      ];
      _filteredProducts = _sortProductsByCategory(_products);
      _displayedProducts = _filteredProducts.take(_pageSize).toList();
      _isLoading = false;
      notifyListeners();
    }
  }

  void loadMoreProducts() {
    if (_isLoadingMore ||
        (_currentPage + 1) * _pageSize >= _filteredProducts.length) {
      return;
    }

    _isLoadingMore = true;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 500), () {
      _currentPage++;
      _displayedProducts.addAll(
        _filteredProducts
            .skip(_currentPage * _pageSize)
            .take(_pageSize)
            .toList(),
      );
      _isLoadingMore = false;
      notifyListeners();
    });
  }

  void filterProductsByCategory(String category) {
    _selectedCategory = category;
    _currentPage = 0;
    if (category == 'All Products') {
      _filteredProducts = _sortProductsByCategory(_products);
    } else {
      _filteredProducts = _products.where((product) {
        String productCategory = product.category.toLowerCase();
        String selectedCategory = category.toLowerCase();
        if (selectedCategory == 'wpc door') {
          return productCategory.contains('wpc');
        } else if (selectedCategory == 'wooden door') {
          return productCategory.contains('wood');
        } else if (selectedCategory == 'hardware') {
          return productCategory.contains('hardware');
        } else if (selectedCategory == 'other product') {
          return !productCategory.contains('wpc') &&
              !productCategory.contains('wood') &&
              !productCategory.contains('hardware');
        }
        return productCategory.contains(selectedCategory);
      }).toList();
    }
    _displayedProducts = _filteredProducts.take(_pageSize).toList();
    notifyListeners();
  }

  List<Product> _sortProductsByCategory(List<Product> products) {
    final categoryPriority = {
      'wpc door': 1,
      'wooden door': 2,
      'hardware': 3,
      'other product': 4,
    };

    return products.toList()
      ..sort((a, b) {
        String aCategory = a.category.toLowerCase();
        String bCategory = b.category.toLowerCase();

        int aPriority = categoryPriority.entries
            .firstWhere(
              (entry) => aCategory.contains(entry.key),
              orElse: () => const MapEntry('other product', 4),
            )
            .value;
        int bPriority = categoryPriority.entries
            .firstWhere(
              (entry) => bCategory.contains(entry.key),
              orElse: () => const MapEntry('other product', 4),
            )
            .value;

        return aPriority.compareTo(bPriority);
      });
  }
}