import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/product.model.dart';
import '../models/store.model.dart';
import '../models/order.model.dart';
import '../models/voucher.model.dart';
import '../../domain/repositories/marketplace_repository.dart';

class MarketplaceRepositoryImpl extends MarketplaceRepository {
  // Host base para marketplace. En STG/PROD debe coincidir con la API principal.
  // Se puede sobreescribir con --dart-define=MARKETPLACE_HOST=<url>.
  static const String baseHost = String.fromEnvironment(
    'MARKETPLACE_HOST',
    // Por defecto apuntamos a staging para evitar IPs locales en builds CI/dev.
    defaultValue: 'https://api-staging.letdem.org',
  );
  static const String baseUrl = '$baseHost/v1/marketplace';

  // Helper para normalizar URLs de imágenes que vienen del backend
  // - Reemplaza host localhost/127.0.0.1 por baseHost
  // - Si la URL es relativa ("/media/..."), la convierte en absoluta usando baseHost
  static String _normalizeUrl(String url) {
    if (url.isEmpty) return url;

    // Primero normalizamos localhost -> baseHost
    var normalized = url
        .replaceAll('http://localhost:8000', baseHost)
        .replaceAll('http://127.0.0.1:8000', baseHost);

    // Si es ruta relativa, anteponer baseHost
    if (normalized.startsWith('/')) {
      return '$baseHost$normalized';
    }

    // Si es URL absoluta pero apunta a otro host (por ejemplo 192.168.1.34),
    // reescribimos el host para que sea siempre baseHost, manteniendo path/query.
    try {
      final uri = Uri.parse(normalized);
      final baseUri = Uri.parse(baseHost);

      if (uri.hasScheme && uri.host.isNotEmpty) {
        if (uri.host != baseUri.host || uri.port != baseUri.port) {
          final fixed = baseUri.replace(path: uri.path, query: uri.query);
          return fixed.toString();
        }
      }
    } catch (_) {
      // Si falla el parseo, devolvemos la versión normalizada tal cual
    }

    return normalized;
  }

  static bool _isHtmlResponse(http.Response response) {
    final contentType = response.headers['content-type'] ?? '';
    if (contentType.contains('text/html')) {
      return true;
    }
    final trimmed = response.body.trimLeft();
    return trimmed.startsWith('<!DOCTYPE') || trimmed.startsWith('<html');
  }

  Future<http.Response> _withRetry(Future<http.Response> Function() fn, {int retries = 2}) async {
    int attempt = 0;
    while (true) {
      try {
        return await fn();
      } on SocketException catch (_) {
        if (attempt++ >= retries) rethrow;
        await Future.delayed(Duration(milliseconds: 300 * (1 << attempt)));
      }
    }
  }

  Never _throwHtmlError(String endpoint) {
    throw Exception(
      'El backend devolvió HTML al llamar $endpoint. Verifica que la URL $baseUrl sea correcta y que el servidor esté disponible.',
    );
  }

  @override
  Future<List<Store>> fetchStores({String? category, String? search}) async {
    try {
      var uri = Uri.parse('$baseUrl/stores/');

      final queryParams = <String, String>{};
      if (category != null) queryParams['category'] = category;
      if (search != null) queryParams['search'] = search;

      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http
          .get(uri)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw Exception('Timeout: No se pudo conectar al servidor');
            },
          );

      if (_isHtmlResponse(response)) {
        _throwHtmlError('$baseUrl/stores/');
      }

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // Manejar respuesta paginada del backend
        final List<dynamic> data =
            responseData is Map && responseData.containsKey('results')
                ? responseData['results'] as List<dynamic>
                : responseData as List<dynamic>;
        // Normalizar URLs de imágenes
        final normalizedData =
            data.map((item) {
              // backend expone `image` (ImageField). Lo normalizamos y lo
              // mapeamos a `image_url` para el modelo Flutter.
              final raw = item['image_url'] ?? item['image'];
              if (raw != null && raw is String && raw.isNotEmpty) {
                item['image_url'] = _normalizeUrl(raw);
              }
              return item;
            }).toList();
        return normalizedData.map((json) => Store.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar tiendas: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetchStores: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  @override
  Future<Store> fetchStoreById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/stores/$id/'));

      if (_isHtmlResponse(response)) {
        _throwHtmlError('$baseUrl/stores/$id/');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final raw = data['image_url'] ?? data['image'];
        if (raw != null && raw is String && raw.isNotEmpty) {
          data['image_url'] = _normalizeUrl(raw);
        }
        return Store.fromJson(data);
      } else {
        throw Exception('Error al cargar tienda: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  @override
  Future<List<Product>> fetchProducts({int? limit, String? storeId, String? search}) async {
    try {
      var uri = Uri.parse('$baseUrl/products/');

      final queryParams = <String, String>{};
      if (limit != null) queryParams['limit'] = limit.toString();
      if (storeId != null) queryParams['store'] = storeId;
      if (search != null) queryParams['search'] = search;

      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http
          .get(uri)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw Exception('Timeout: No se pudo conectar al servidor');
            },
          );

      if (_isHtmlResponse(response)) {
        _throwHtmlError('$baseUrl/products/');
      }

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // Manejar respuesta paginada del backend
        final List<dynamic> data =
            responseData is Map && responseData.containsKey('results')
                ? responseData['results'] as List<dynamic>
                : responseData as List<dynamic>;
        // Normalizar URLs de imágenes
        final normalizedData =
            data.map((item) {
              // backend expone `image` (ImageField). Lo normalizamos y lo
              // mapeamos a `image_url` para el modelo Flutter.
              final raw = item['image_url'] ?? item['image'];
              if (raw != null && raw is String && raw.isNotEmpty) {
                item['image_url'] = _normalizeUrl(raw);
              }
              return item;
            }).toList();
        return normalizedData.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar productos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  @override
  Future<Product> fetchProductById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products/$id/'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final raw = data['image_url'] ?? data['image'];
        if (raw != null && raw is String && raw.isNotEmpty) {
          data['image_url'] = _normalizeUrl(raw);
        }
        return Product.fromJson(data);
      } else {
        throw Exception('Error al cargar producto: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> purchaseWithRedeem({
    required String productId,
    required int quantity,
    required String authToken,
    String? paymentIntentId,
  }) async {
    try {
      final body = {'product_id': productId, 'quantity': quantity};

      if (paymentIntentId != null) {
        body['payment_intent_id'] = paymentIntentId;
      }

      final uri = Uri.parse('$baseUrl/purchase/with-redeem/');
      print('[API] POST '+uri.toString());
      final response = await _withRetry(() => http.post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Token $authToken',
            },
            body: json.encode(body),
          )).timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw TimeoutException('Timeout: No se pudo conectar al servidor'),
      );

      if (_isHtmlResponse(response)) {
        _throwHtmlError(uri.toString());
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        // Debug logging for failures
        print('[API] purchaseWithRedeem failed: status=${response.statusCode}');
        print('[API] body=${response.body}');
        if (response.statusCode == 401) {
          throw Exception('Sesión expirada o inválida. Inicia sesión nuevamente.');
        }
        try {
          final errorData = json.decode(response.body);
          throw Exception(errorData['error'] ?? 'Error al procesar compra');
        } catch (_) {
          throw Exception('Error al procesar compra');
        }
      }
    } on SocketException catch (e) {
      print('[API] SocketException: '+e.message);
      throw Exception('Sin conexión a Internet');
    } on TimeoutException catch (e) {
      print('[API] Timeout');
      throw Exception(e.message);
    } catch (e) {
      print('[API] Error: '+e.toString());
      throw Exception('Error de conexión: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> purchaseWithoutRedeem({
    required String productId,
    required int quantity,
    required String authToken,
    String? paymentIntentId,
  }) async {
    try {
      final body = {'product_id': productId, 'quantity': quantity};

      if (paymentIntentId != null) {
        body['payment_intent_id'] = paymentIntentId;
      }

      final uri = Uri.parse('$baseUrl/purchase/without-redeem/');
      print('[API] POST '+uri.toString());
      final response = await _withRetry(() => http.post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Token $authToken',
            },
            body: json.encode(body),
          )).timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw TimeoutException('Timeout: No se pudo conectar al servidor'),
      );

      if (_isHtmlResponse(response)) {
        _throwHtmlError(uri.toString());
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        // Debug logging for failures
        print('[API] purchaseWithoutRedeem failed: status=${response.statusCode}');
        print('[API] body=${response.body}');
        if (response.statusCode == 401) {
          throw Exception('Sesión expirada o inválida. Inicia sesión nuevamente.');
        }
        try {
          final errorData = json.decode(response.body);
          throw Exception(errorData['error'] ?? 'Error al procesar compra');
        } catch (_) {
          throw Exception('Error al procesar compra');
        }
      }
    } on SocketException catch (e) {
      print('[API] SocketException: '+e.message);
      throw Exception('Sin conexión a Internet');
    } on TimeoutException catch (e) {
      print('[API] Timeout');
      throw Exception(e.message);
    } catch (e) {
      print('[API] Error: '+e.toString());
      throw Exception('Error de conexión: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> checkoutCart({
    required List<Map<String, dynamic>> items,
    String? paymentIntentId,
  }) async {
    try {
      final Map<String, dynamic> body = {'items': items};

      if (paymentIntentId != null) {
        body['payment_intent_id'] = paymentIntentId;
      }

      final uri = Uri.parse('$baseUrl/cart/checkout/');
      print('[API] POST '+uri.toString());
      final response = await _withRetry(() => http.post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )).timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw TimeoutException('Timeout: No se pudo conectar al servidor'),
      );

      if (_isHtmlResponse(response)) {
        _throwHtmlError(uri.toString());
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        // Debug logging for failures
        print('[API] checkoutCart failed: status=${response.statusCode}');
        print('[API] body=${response.body}');
        if (response.statusCode == 401) {
          throw Exception('Sesión expirada o inválida. Inicia sesión nuevamente.');
        }
        try {
          final errorData = json.decode(response.body);
          throw Exception(errorData['error'] ?? 'Error en checkout');
        } catch (_) {
          throw Exception('Error en checkout');
        }
      }
    } on SocketException catch (e) {
      print('[API] SocketException: '+e.message);
      throw Exception('Sin conexión a Internet');
    } on TimeoutException catch (e) {
      print('[API] Timeout');
      throw Exception(e.message);
    } catch (e) {
      print('[API] Error: '+e.toString());
      throw Exception('Error de conexión: $e');
    }
  }

  @override
  Future<OrderHistoryResponse> fetchOrderHistory({
    String? status,
    required String authToken,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/orders/history/');

      if (status != null) {
        uri = uri.replace(queryParameters: {'status': status});
      }

      final response = await http
          .get(uri, headers: {'Authorization': 'Token $authToken'})
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Timeout: No se pudo conectar al servidor');
            },
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Normalizar URLs de imágenes de productos
        if (data['orders'] != null) {
          for (var order in data['orders']) {
            if (order['items'] != null) {
              for (var item in order['items']) {
                if (item['product_image'] != null) {
                  item['product_image'] = _normalizeUrl(item['product_image']);
                }
              }
            }
          }
        }
        return OrderHistoryResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Inicia sesión para ver tu historial');
      } else {
        throw Exception('Error al cargar historial: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  @override
  Future<List<Voucher>> fetchPendingVouchers({
    required String authToken,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/vouchers/',
      ).replace(queryParameters: {'status': 'PENDING'});

      final response = await http
          .get(uri, headers: {'Authorization': 'Token $authToken'})
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Timeout: No se pudo conectar al servidor');
            },
          );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Voucher.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado');
      } else {
        throw Exception('Error al cargar vouchers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  @override
  Future<Voucher> createVirtualCard({
    required int points,
    String? productId,
    required String redeemType,
    required String authToken,
  }) async {
    if (authToken.isEmpty) {
      throw Exception('No est�s autenticado');
    }
    if (points < 500 || points % 500 != 0) {
      throw Exception('Los puntos deben ingresarse en m�ltiplos de 500');
    }
    try {
      final Map<String, dynamic> body = {
        'redeem_type': redeemType,
        'points': points,
      };
      if (productId != null && productId.isNotEmpty) {
        body['product_id'] = productId;
      }

      final headers = {
        'Content-Type': 'application/json',
      };

      if (authToken.isNotEmpty) {
        headers['Authorization'] = 'Token $authToken';
      }

      final uri = Uri.parse('$baseUrl/vouchers/create-online/');
      print('[API] POST '+uri.toString());
      final response = await _withRetry(() => http.post(
            uri,
            headers: headers,
            body: json.encode(body),
          )).timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw TimeoutException('Timeout: No se pudo conectar al servidor'),
      );

      if (_isHtmlResponse(response)) {
        _throwHtmlError(uri.toString());
      }

      if (response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return Voucher.fromJson(data);
      } else {
        print('Error response status: ${response.statusCode}');
        print('Error response body: ${response.body}');
        try {
          final errorData = json.decode(response.body);
          final message =
              (errorData is Map && errorData['error'] != null)
                  ? errorData['error'].toString()
                  : (errorData is Map && errorData['detail'] != null)
                      ? errorData['detail'].toString()
                      : 'Error al generar la tarjeta virtual: ${response.statusCode}';
          throw Exception(message);
        } catch (e) {
          throw Exception('Error ${response.statusCode}: ${response.body}');
        }
      }
    } on SocketException catch (e) {
      print('[API] SocketException: '+e.message);
      throw Exception('Sin conexión a Internet');
    } on TimeoutException catch (e) {
      print('[API] Timeout');
      throw Exception(e.message);
    } catch (e) {
      print('Exception in createVirtualCard: $e');
      throw Exception('Error: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> cancelVoucher({
    required String voucherId,
    required String authToken,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/vouchers/cancel/'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Token $authToken',
            },
            body: json.encode({'voucher_id': voucherId}),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Timeout: No se pudo conectar al servidor');
            },
          );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Error al cancelar voucher');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> validateVoucher({
    required String code,
    String? pin,
    required String authToken,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/vouchers/validate/'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Token $authToken',
            },
            body: json.encode({
              'code': code,
              if (pin != null && pin.isNotEmpty) 'pin': pin,
            }),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Timeout: No se pudo conectar al servidor');
            },
          );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Error al validar voucher');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
