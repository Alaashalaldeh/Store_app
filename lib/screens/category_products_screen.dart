import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class CategoryProductsScreen extends StatefulWidget {
  final dynamic category;

  const CategoryProductsScreen({super.key, required this.category});

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  late Future<List<Product>> _futureProducts;

  @override
  void initState() {
    super.initState();
    final int categoryId = widget.category is int ? widget.category : widget.category.id;
    _futureProducts = ApiService.fetchProducts(categoryId: categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category is int ? 'المنتجات' : widget.category.name),
      ),
      body: FutureBuilder<List<Product>>(
        future: _futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا توجد منتجات في هذا التصنيف'));
          }

          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                leading: Image.network(product.image, width: 50, height: 50, fit: BoxFit.cover),
                title: Text(product.name),
                subtitle: Text('\$${product.price}'),
              );
            },
          );
        },
      ),
    );
  }
}
