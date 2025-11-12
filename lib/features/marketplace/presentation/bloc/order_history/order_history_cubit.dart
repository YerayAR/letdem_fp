import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letdem/infrastructure/storage/storage/storage.service.dart';
import '../../../models/order.model.dart';
import '../../../repository/marketplace.interface.dart';
import 'order_history_state.dart';

class OrderHistoryCubit extends Cubit<OrderHistoryState> {
  final IMarketplaceRepository repository;

  OrderHistoryCubit(this.repository) : super(OrderHistoryInitial());

  Future<void> loadOrderHistory({String? status}) async {
    try {
      emit(OrderHistoryLoading());
      
      // Obtener token de autenticación
      final token = await SecureStorageHelper().read('access_token');
      
      print('=== DEBUG ORDER HISTORY ===');
      print('Token obtenido: ${token != null ? "SÍ (${token.length} chars)" : "NULL"}');
      
      if (token == null || token.isEmpty) {
        print('ERROR: Token no encontrado');
        emit(const OrderHistoryError('No estás autenticado. Inicia sesión para ver tu historial'));
        return;
      }
      
      print('Token (primeros 20 chars): ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
      print('Llamando a fetchOrderHistory con authToken...');
      
      final response = await repository.fetchOrderHistory(
        status: status,
        authToken: token,
      );
      print('Orders recibidas: ${response.orders.length}');
      
      emit(OrderHistoryLoaded(
        stats: response.stats,
        orders: response.orders,
      ));
    } catch (e, stackTrace) {
      print('ERROR en loadOrderHistory: $e');
      print('StackTrace: $stackTrace');
      
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      if (errorMessage.contains('401') || errorMessage.toLowerCase().contains('unauthorized')) {
        errorMessage = 'Sesión expirada. Por favor vuelve a iniciar sesión.';
      }
      
      emit(OrderHistoryError(errorMessage));
    }
  }

  Future<void> refreshOrderHistory({String? status}) async {
    await loadOrderHistory(status: status);
  }
}
