import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.model.dart';
import '../models/store.model.dart';

class MarketplaceRepository {
  // IP de la máquina Windows en la red local para dispositivo físico
  // Usa 10.0.2.2 para emulador, 192.168.1.35 para dispositivo físico
  static const String baseUrl = 'http://192.168.1.35:8000/v1/marketplace';
  static const String baseHost = 'http://192.168.1.35:8000';

  // Helper para normalizar URLs que vienen con localhost del backend
  static String _normalizeUrl(String url) {
    if (url.isEmpty) return url;
    // Reemplazar localhost por la IP correcta
    return url.replaceAll('http://localhost:8000', baseHost)
              .replaceAll('http://127.0.0.1:8000', baseHost);
  }

  Future<List<Store>> fetchStores({String? category, String? search}) async {
    try {
      var uri = Uri.parse('$baseUrl/stores/');
      
      final queryParams = <String, String>{};
      if (category != null) queryParams['category'] = category;
      if (search != null) queryParams['search'] = search;
      
      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http.get(uri).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('Timeout: No se pudo conectar al servidor');
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // Manejar respuesta paginada del backend
        final List<dynamic> data = responseData is Map && responseData.containsKey('results')
            ? responseData['results'] as List<dynamic>
            : responseData as List<dynamic>;
        // Normalizar URLs de imágenes
        final normalizedData = data.map((item) {
          if (item['image_url'] != null) {
            item['image_url'] = _normalizeUrl(item['image_url']);
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

  Future<Store> fetchStoreById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/stores/$id/'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['image_url'] != null) {
          data['image_url'] = _normalizeUrl(data['image_url']);
        }
        return Store.fromJson(data);
      } else {
        throw Exception('Error al cargar tienda: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Product>> fetchProducts({String? storeId, String? search}) async {
    try {
      var uri = Uri.parse('$baseUrl/products/');
      
      final queryParams = <String, String>{};
      if (storeId != null) queryParams['store'] = storeId;
      if (search != null) queryParams['search'] = search;
      
      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http.get(uri).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('Timeout: No se pudo conectar al servidor');
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // Manejar respuesta paginada del backend
        final List<dynamic> data = responseData is Map && responseData.containsKey('results')
            ? responseData['results'] as List<dynamic>
            : responseData as List<dynamic>;
        // Normalizar URLs de imágenes
        final normalizedData = data.map((item) {
          if (item['image_url'] != null) {
            item['image_url'] = _normalizeUrl(item['image_url']);
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

  Future<Product> fetchProductById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products/$id/'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['image_url'] != null) {
          data['image_url'] = _normalizeUrl(data['image_url']);
        }
        return Product.fromJson(data);
      } else {
        throw Exception('Error al cargar producto: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Map<String, dynamic>> purchaseWithRedeem({
    required String productId,
    required int quantity,
    required String authToken,
    String? paymentIntentId,
  }) async {
    try {
      final body = {
        'product_id': productId,
        'quantity': quantity,
      };
      
      if (paymentIntentId != null) {
        body['payment_intent_id'] = paymentIntentId;
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/purchase/with-redeem/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $authToken',
        },
        body: json.encode(body),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout: No se pudo conectar al servidor');
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Error al procesar compra');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Map<String, dynamic>> purchaseWithoutRedeem({
    required String productId,
    required int quantity,
    required String authToken,
    String? paymentIntentId,
  }) async {
    try {
      final body = {
        'product_id': productId,
        'quantity': quantity,
      };
      
      if (paymentIntentId != null) {
        body['payment_intent_id'] = paymentIntentId;
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/purchase/without-redeem/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $authToken',
        },
        body: json.encode(body),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout: No se pudo conectar al servidor');
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Error al procesar compra');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
