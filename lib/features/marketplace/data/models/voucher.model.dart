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
      id: json['id'] as String,
      code: json['code'] as String,
      qrCode: json['qr_code'] as String? ?? '',
      redeemType: json['redeem_type'] as String,
      status: json['status'] as String,
      discountPercentage: double.parse(json['discount_percentage'].toString()),
      pointsUsed: json['points_used'] as int,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      redeemedAt: json['redeemed_at'] != null
          ? DateTime.parse(json['redeemed_at'] as String)
          : null,
      userId: json['user'] as String,
      userEmail: json['user_email'] as String? ?? '',
      productId: json['product'] as String,
      productName: json['product_name'] as String? ?? '',
      productPrice: double.parse(json['product_price'].toString()),
      storeId: json['store'] as String,
      storeName: json['store_name'] as String? ?? '',
      storeCategory: json['store_category'] as String? ?? '',
      scannedCode: json['scanned_code'] as String? ?? '',
      isValid: json['is_valid'] as bool? ?? false,
      isExpired: json['is_expired'] as bool? ?? false,
      canCancel: json['can_cancel'] as bool? ?? false,
      hoursUntilCancellationDeadline:
          double.parse(json['hours_until_cancellation_deadline'].toString()),
      hoursUntilExpiration:
          double.parse(json['hours_until_expiration'].toString()),
      discountAmount: double.parse(json['discount_amount'].toString()),
      finalPrice: double.parse(json['final_price'].toString()),
      created: DateTime.parse(json['created'] as String),
      modified: DateTime.parse(json['modified'] as String),
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
