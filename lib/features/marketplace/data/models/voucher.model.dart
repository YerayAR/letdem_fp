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
  final String? productId;
  final String productName;
  final double productPrice;
  final String? storeId;
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
    this.productId,
    required this.productName,
    required this.productPrice,
    this.storeId,
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
      // En el backend los IDs suelen ser enteros; usamos toString() para admitir int o String.
      id: json['id'].toString(),
      code: (json['code'] ?? '').toString(),
      qrCode: (json['qr_code'] ?? '').toString(),
      redeemType: (json['redeem_type'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      discountPercentage: _parseDouble(json['discount_percentage']),
      pointsUsed: (json['points_used'] as int?) ??
          int.tryParse(json['points_used']?.toString() ?? '0') ?? 0,
      expiresAt: DateTime.parse(json['expires_at'].toString()),
      redeemedAt: json['redeemed_at'] != null &&
              json['redeemed_at'].toString().isNotEmpty
          ? DateTime.parse(json['redeemed_at'].toString())
          : null,
      userId: json['user']?.toString() ?? '',
      userEmail: (json['user_email'] ?? '').toString(),
      // product y store pueden venir nulos en vouchers genéricos
      productId:
          json['product'] != null ? json['product'].toString() : null,
      productName: (json['product_name'] ?? '').toString(),
      productPrice: _parseDouble(json['product_price']),
      storeId: json['store'] != null ? json['store'].toString() : null,
      storeName: (json['store_name'] ?? '').toString(),
      storeCategory: (json['store_category'] ?? '').toString(),
      scannedCode: (json['scanned_code'] ?? '').toString(),
      isValid: json['is_valid'] as bool? ?? false,
      isExpired: json['is_expired'] as bool? ?? false,
      canCancel: json['can_cancel'] as bool? ?? false,
      hoursUntilCancellationDeadline: _parseDouble(
        json['hours_until_cancellation_deadline'],
      ),
      hoursUntilExpiration: _parseDouble(
        json['hours_until_expiration'],
      ),
      discountAmount: _parseDouble(json['discount_amount']),
      finalPrice: _parseDouble(json['final_price']),
      created: DateTime.parse(json['created'].toString()),
      modified: DateTime.parse(json['modified'].toString()),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
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
