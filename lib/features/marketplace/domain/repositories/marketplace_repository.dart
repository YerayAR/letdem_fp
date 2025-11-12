import '../../data/models/product.model.dart';
import '../../data/models/store.model.dart';
import '../../data/models/order.model.dart';
import '../../data/models/voucher.model.dart';

abstract class MarketplaceRepository {
  Future<List<Store>> fetchStores({String? category, String? search});
  Future<Store> fetchStoreById(String id);
  Future<List<Product>> fetchProducts({String? storeId, String? search});
  Future<Product> fetchProductById(String id);
  Future<Map<String, dynamic>> purchaseWithRedeem({
    required String productId,
    required int quantity,
    required String authToken,
    String? paymentIntentId,
  });
  Future<Map<String, dynamic>> purchaseWithoutRedeem({
    required String productId,
    required int quantity,
    required String authToken,
    String? paymentIntentId,
  });
  Future<Map<String, dynamic>> checkoutCart({
    required List<Map<String, dynamic>> items,
    String? paymentIntentId,
  });
  Future<OrderHistoryResponse> fetchOrderHistory({
    String? status,
    required String authToken,
  });
  Future<List<Voucher>> fetchPendingVouchers({required String authToken});
  Future<Voucher> createVirtualCard({
    required String productId,
    required String redeemType,
    required String authToken,
  });
  Future<Map<String, dynamic>> cancelVoucher({
    required String voucherId,
    required String authToken,
  });
  Future<Map<String, dynamic>> validateVoucher({
    required String code,
    String? pin,
    required String authToken,
  });
}
