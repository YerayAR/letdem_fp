class OrderItem {
  final String id;
  final String product;
  final String productName;
  final String productImage;
  final String storeName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final bool hasDiscount;
  final double discountAmount;

  OrderItem({
    required this.id,
    required this.product,
    required this.productName,
    required this.productImage,
    required this.storeName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.hasDiscount,
    required this.discountAmount,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      product: json['product'] as String,
      productName: json['product_name'] as String? ?? '',
      productImage: json['product_image'] as String? ?? '',
      storeName: json['store_name'] as String? ?? '',
      quantity: json['quantity'] as int,
      unitPrice: double.parse(json['unit_price'].toString()),
      totalPrice: double.parse(json['total_price'].toString()),
      hasDiscount: json['has_discount'] as bool? ?? false,
      discountAmount: double.parse((json['discount_amount'] ?? 0).toString()),
    );
  }
}

class Order {
  final String id;
  final String userId;
  final String userEmail;
  final String status;
  final double subtotal;
  final double pointsDiscount;
  final double total;
  final bool usedPoints;
  final int pointsUsedAmount;
  final List<OrderItem> items;
  final int itemsCount;
  final DateTime created;
  final DateTime modified;

  Order({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.status,
    required this.subtotal,
    required this.pointsDiscount,
    required this.total,
    required this.usedPoints,
    required this.pointsUsedAmount,
    required this.items,
    required this.itemsCount,
    required this.created,
    required this.modified,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      userId: json['user'] as String,
      userEmail: json['user_email'] as String? ?? '',
      status: json['status'] as String,
      subtotal: double.parse(json['subtotal'].toString()),
      pointsDiscount: double.parse(json['points_discount'].toString()),
      total: double.parse(json['total'].toString()),
      usedPoints: json['used_points'] as bool? ?? false,
      pointsUsedAmount: json['points_used_amount'] as int? ?? 0,
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      itemsCount: json['items_count'] as int? ?? 0,
      created: DateTime.parse(json['created'] as String),
      modified: DateTime.parse(json['modified'] as String),
    );
  }

  String get statusDisplay {
    switch (status) {
      case 'PENDING':
        return 'Pendiente';
      case 'PAID':
        return 'Pagado';
      case 'PROCESSING':
        return 'Procesando';
      case 'COMPLETED':
        return 'Completado';
      case 'CANCELLED':
        return 'Cancelado';
      default:
        return status;
    }
  }
}

class OrderHistoryStats {
  final int totalOrders;
  final double totalSpent;
  final int totalPointsUsed;
  final double totalSaved;
  final int currentPoints;

  OrderHistoryStats({
    required this.totalOrders,
    required this.totalSpent,
    required this.totalPointsUsed,
    required this.totalSaved,
    required this.currentPoints,
  });

  factory OrderHistoryStats.fromJson(Map<String, dynamic> json) {
    return OrderHistoryStats(
      totalOrders: json['total_orders'] as int,
      totalSpent: double.parse(json['total_spent'].toString()),
      totalPointsUsed: json['total_points_used'] as int,
      totalSaved: double.parse(json['total_saved'].toString()),
      currentPoints: json['current_points'] as int,
    );
  }
}

class OrderHistoryResponse {
  final OrderHistoryStats stats;
  final List<Order> orders;

  OrderHistoryResponse({
    required this.stats,
    required this.orders,
  });

  factory OrderHistoryResponse.fromJson(Map<String, dynamic> json) {
    return OrderHistoryResponse(
      stats: OrderHistoryStats.fromJson(json['stats'] as Map<String, dynamic>),
      orders: (json['orders'] as List<dynamic>)
          .map((order) => Order.fromJson(order as Map<String, dynamic>))
          .toList(),
    );
  }
}
