class Voucher {
  final String id;
  final String code;
  final String qrCode;
  final String redeemType; // ONLINE o IN_STORE
  final String status; // PENDING, REDEEMED, EXPIRED, CANCELLED
  final double discountPercentage;
  final int pointsUsed;
  final DateTime expiresAt;
  final DateTime? redeemedAt;
  final String userId;
  final String userEmail;
  final String productId;
  final String productName;
  final double productPrice;
  final String storeId;
  final String storeName;
  final String storeCategory;
  final String scannedCode;
  final bool isValid;
  final bool isExpired;
  final bool canCancel;
  final double hoursUntilCancellationDeadline;
  final double hoursUntilExpiration;
  final double discountAmount;
  final double finalPrice;
  final DateTime created;
  final DateTime modified;

  Voucher({
    required this.id,
    required this.code,
    required this.qrCode,
    required this.redeemType,
    required this.status,
    required this.discountPercentage,
    required this.pointsUsed,
    required this.expiresAt,
    this.redeemedAt,
    required this.userId,
    required this.userEmail,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.storeId,
    required this.storeName,
    required this.storeCategory,
    required this.scannedCode,
    required this.isValid,
    required this.isExpired,
    required this.canCancel,
    required this.hoursUntilCancellationDeadline,
    required this.hoursUntilExpiration,
    required this.discountAmount,
    required this.finalPrice,
    required this.created,
    required this.modified,
  });

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      // Algunos campos pueden venir como int en el backend; forzamos a String con toString()
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      qrCode: json['qr_code']?.toString() ?? '',
      redeemType: json['redeem_type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      discountPercentage: (json['discount_percentage'] is num)
          ? (json['discount_percentage'] as num).toDouble()
          : double.tryParse(json['discount_percentage']?.toString() ?? '') ?? 0.0,
      pointsUsed: (json['points_used'] is int)
          ? json['points_used'] as int
          : int.tryParse(json['points_used'].toString()) ?? 0,
      expiresAt: DateTime.parse(json['expires_at'].toString()),
      redeemedAt: json['redeemed_at'] != null
          ? DateTime.parse(json['redeemed_at'].toString())
          : null,
      userId: json['user']?.toString() ?? '',
      userEmail: json['user_email']?.toString() ?? '',
      productId: json['product']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? '',
      productPrice: (json['product_price'] is num)
          ? (json['product_price'] as num).toDouble()
          : double.tryParse(json['product_price']?.toString() ?? '') ?? 0.0,
      storeId: json['store']?.toString() ?? '',
      storeName: json['store_name']?.toString() ?? '',
      storeCategory: json['store_category']?.toString() ?? '',
      scannedCode: json['scanned_code']?.toString() ?? '',
      isValid: json['is_valid'] as bool? ?? false,
      isExpired: json['is_expired'] as bool? ?? false,
      canCancel: json['can_cancel'] as bool? ?? false,
      hoursUntilCancellationDeadline:
          (json['hours_until_cancellation_deadline'] is num)
              ? (json['hours_until_cancellation_deadline'] as num).toDouble()
              : double.tryParse(json['hours_until_cancellation_deadline']?.toString() ?? '') ?? 0.0,
      hoursUntilExpiration:
          (json['hours_until_expiration'] is num)
              ? (json['hours_until_expiration'] as num).toDouble()
              : double.tryParse(json['hours_until_expiration']?.toString() ?? '') ?? 0.0,
      discountAmount: (json['discount_amount'] is num)
          ? (json['discount_amount'] as num).toDouble()
          : double.tryParse(json['discount_amount']?.toString() ?? '') ?? 0.0,
      finalPrice: (json['final_price'] is num)
          ? (json['final_price'] as num).toDouble()
          : double.tryParse(json['final_price']?.toString() ?? '') ?? 0.0,
      created: DateTime.parse(json['created'].toString()),
      modified: DateTime.parse(json['modified'].toString()),
    );
  }

  String get statusDisplay {
    switch (status) {
      case 'PENDING':
        return 'Pendiente';
      case 'REDEEMED':
        return 'Canjeado';
      case 'EXPIRED':
        return 'Expirado';
      case 'CANCELLED':
        return 'Cancelado';
      default:
        return status;
    }
  }

  String get redeemTypeDisplay {
    switch (redeemType) {
      case 'ONLINE':
        return 'Online';
      case 'IN_STORE':
        return 'En tienda';
      default:
        return redeemType;
    }
  }
}
