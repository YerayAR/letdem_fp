class CartItem {
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  int quantity;
  bool applyDiscount;
  
  CartItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    this.quantity = 1,
    this.applyDiscount = false,
  });
  
  double get subtotal => price * quantity;
  double get discount => applyDiscount ? subtotal * 0.30 : 0;
  double get total => subtotal - discount;
  int get pointsNeeded => applyDiscount ? 500 : 0;
  
  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'quantity': quantity,
    'apply_discount': applyDiscount,
  };
  
  CartItem copyWith({
    String? productId,
    String? productName,
    String? productImage,
    double? price,
    int? quantity,
    bool? applyDiscount,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      applyDiscount: applyDiscount ?? this.applyDiscount,
    );
  }
}
