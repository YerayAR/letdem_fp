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
      id: json['id']?.toString() ?? '',
      product: json['product']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? '',
      productImage: json['product_image']?.toString() ?? '',
      storeName: json['store_name']?.toString() ?? '',
      quantity: json['quantity'] is int
          ? json['quantity'] as int
          : int.tryParse(json['quantity']?.toString() ?? '') ?? 0,
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
    DateTime _parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      final str = value.toString();
      return DateTime.tryParse(str) ?? DateTime.now();
    }

    return Order(
      id: json['id']?.toString() ?? '',
      userId: json['user']?.toString() ?? '',
      userEmail: json['user_email']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
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
      created: _parseDate(json['created']),
      modified: _parseDate(json['modified']),
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
    int _int(dynamic value) =>
        value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;

    return OrderHistoryStats(
      totalOrders: _int(json['total_orders'] ?? 0),
      totalSpent: double.parse((json['total_spent'] ?? 0).toString()),
      totalPointsUsed: _int(json['total_points_used'] ?? 0),
      totalSaved: double.parse((json['total_saved'] ?? 0).toString()),
      currentPoints: _int(json['current_points'] ?? 0),
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
    final statsJson = json['stats'];
    final ordersJson = json['orders'];

    final stats = statsJson is Map<String, dynamic>
        ? OrderHistoryStats.fromJson(statsJson)
        : OrderHistoryStats(
            totalOrders: 0,
            totalSpent: 0,
            totalPointsUsed: 0,
            totalSaved: 0,
            currentPoints: 0,
          );

    final List<Order> orders;
    if (ordersJson is List) {
      orders = ordersJson
          .whereType<Map<String, dynamic>>()
          .map((order) => Order.fromJson(order))
          .toList();
    } else {
      orders = const [];
    }

    return OrderHistoryResponse(
      stats: stats,
      orders: orders,
    );
  }
}
