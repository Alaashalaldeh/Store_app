import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/order_item_input.dart';

class ApiService {
  static const String baseUrl = 'https://store.bcite.org/public/api';

  // 1. جلب المنتجات مع الفلترة والبحث
  static Future<List<Product>> fetchProducts({
    String? search,
    int? categoryId,
  }) async {
    final query = <String, String>{};
    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }
    if (categoryId != null) {
      query['category'] = '$categoryId';
    }

    final uri = Uri.parse('$baseUrl/products')
        .replace(queryParameters: query.isEmpty ? null : query);

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List data = decoded['data'];
      return data.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('فشل في جلب المنتجات من السيرفر');
    }
  }

  // 2. جلب الفئات
  static Future<List<Category>> fetchCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/categories'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List data = decoded['data'];
      return data.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('فشل في جلب الفئات');
    }
  }

  // 3. إنشاء طلب جديد (دون الحاجة لملف order_model.dart)
  static Future<Map<String, dynamic>> createOrder({
    required String phone,
    required List<dynamic> items,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'phone': phone,
        'items': items.map((item) {
          if (item is OrderItemInput) return item.toJson();
          return item;
        }).toList(),
      }),
    );

    final decoded = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return decoded['data'] as Map<String, dynamic>;
    } else {
      final message = decoded['message'] ?? 'فشل إنشاء الطلب';
      throw Exception(message);
    }
  }
}