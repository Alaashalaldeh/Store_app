import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';

class FavoritesProvider extends ChangeNotifier {
  List<Product> _favorites = [];

  List<Product> get favorites => _favorites;

  FavoritesProvider() {
    _loadFavoritesFromPrefs(); // تحميل المفضلة من التخزين المحلي فور إنشاء الـ Provider
  }

  // تحقق ما إذا كان المنتج مفضلاً
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
    _saveFavoritesToPrefs(); // حفظ القائمة التحديثة في التخزين المحلي
  }

  // حفظ المفضلة في SharedPreferences
  Future<void> _saveFavoritesToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    // تحويل قائمة المنتجات إلى JSON String
    final List<String> encodedList = _favorites.map((product) {
      return jsonEncode({
        'id': product.id,
        'title': product.name,
        'price': product.price,
        'image': product.image,
        'description': product.description,
        'category_id': product.categoryId,
      });
    }).toList();

    await prefs.setStringList('favorite_products', encodedList);
  }

  // تحميل المفضلة من SharedPreferences
  Future<void> _loadFavoritesFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? encodedList = prefs.getStringList('favorite_products');

    if (encodedList != null) {
      _favorites = encodedList.map((item) {
        final Map<String, dynamic> json = jsonDecode(item);
        return Product.fromJson(json);
      }).toList();
      notifyListeners();
    }
  }
}