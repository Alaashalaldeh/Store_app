import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';

// ==========================================
// 1. كلاس إدارة حالة المفضلة (FavoritesProvider)
// ==========================================
class FavoritesProvider extends ChangeNotifier {
  List<Product> _favorites = [];

  List<Product> get favorites => _favorites;

  FavoritesProvider() {
    _loadFavoritesFromPrefs();
  }

  // التحقق مما إذا كان المنتج مفضلاً
  bool isFavorite(int productId) {
    return _favorites.any((product) => product.id == productId);
  }

  // إضافة أو إزالة المنتج من المفضلة
  void toggleFavorite(Product product) {
    if (isFavorite(product.id)) {
      _favorites.removeWhere((item) => item.id == product.id);
    } else {
      _favorites.add(product);
    }
    notifyListeners();
    _saveFavoritesToPrefs();
  }

  // حفظ المفضلة في SharedPreferences باستعمال toJson الخاصة بالـ Model
  Future<void> _saveFavoritesToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedList = _favorites
        .map((product) => jsonEncode(product.toJson()))
        .toList();
    await prefs.setStringList('favorite_products', encodedList);
  }

  // تحميل المفضلة من SharedPreferences
  Future<void> _loadFavoritesFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedList = prefs.getStringList('favorite_products');

    if (encodedList != null) {
      _favorites = encodedList.map((item) {
        final Map<String, dynamic> json = jsonDecode(item);
        return Product.fromJson(json);
      }).toList();
      notifyListeners();
    }
  }
}

// ==========================================
// 2. كلاس واجهة شاشة المفضلة (FavoritesScreen)
// ==========================================
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final favoriteProducts = favoritesProvider.favorites;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المفضلة'),
      ),
      body: favoriteProducts.isEmpty
          ? const Center(
              child: Text(
                'لا توجد منتجات في المفضلة حالياً',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: favoriteProducts.length,
              itemBuilder: (context, index) {
                final product = favoriteProducts[index];
                return ListTile(
                  leading: Image.network(
                    product.image,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 50),
                  ),
                  title: Text(
                    product.name, // استخدام name حسب عقد الـ API
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      favoritesProvider.toggleFavorite(product);
                    },
                  ),
                );
              },
            ),
    );
  }
}