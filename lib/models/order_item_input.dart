class OrderItemInput {
  final String productId;
  final int quantity;

  OrderItemInput({
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
    };
  }
}