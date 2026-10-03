import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    if (cartProvider.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('السلة فارغة! يرجى إضافة منتجات أولاً.')),
      );
      return;
    }

    final List<Map<String, dynamic>> orderItems = cartProvider.items.map((item) {
      final pId = item['id'] ?? item['product_id'];
      final pQty = item['quantity'] ?? 1;

      return {
        'product_id': (pId as num).toInt(),
        'quantity': (pQty as num).toInt(),
      };
    }).toList();

    setState(() => _isSubmitting = true);

    try {
      final responseData = await ApiService.createOrder(
        phone: _phoneController.text.trim(),
        items: orderItems,
      );

      cartProvider.clearCart();

      if (!mounted) return;
      final int orderId = responseData['id'] ?? 0;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم إنشاء الطلب بنجاح! رقم الطلب: #$orderId')),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    double total = 0.0;
    for (var item in cartProvider.items) {
      final price = ((item['price'] ?? item['product_price'] ?? 0.0) as num).toDouble();
      final qty = ((item['quantity'] ?? 1) as num).toInt();
      total += price * qty;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('إتمام الشراء'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // عرض عناصر السلة المضافة
              const Text(
                'المنتجات في السلة:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: cartProvider.items.isEmpty
                    ? const Center(child: Text('لا توجد عناصر في السلة'))
                    : ListView.builder(
                        itemCount: cartProvider.items.length,
                        itemBuilder: (context, index) {
                          final item = cartProvider.items[index];
                          final name = item['name'] ?? item['title'] ?? 'منتج';
                          final price = ((item['price'] ?? 0.0) as num).toDouble();
                          final qty = ((item['quantity'] ?? 1) as num).toInt();

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              title: Text(name),
                              subtitle: Text('العدد: $qty × \$${price.toStringAsFixed(2)}'),
                              trailing: Text(
                                '\$${(price * qty).toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const Divider(height: 20, thickness: 2),
              // المبلغ الإجمالي
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('المبلغ الإجمالي:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // حقل إدخال رقم الهاتف
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف (9 أرقام على الأقل)',
                  hintText: '0591234567',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 9) {
                    return 'يرجى إدخال رقم هاتف صحيح لا يقل عن 9 أرقام';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // زر تأكيد الطلب
              _isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _submitOrder,
                      child: const Text('تأكيد الطلب', style: TextStyle(fontSize: 16)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}