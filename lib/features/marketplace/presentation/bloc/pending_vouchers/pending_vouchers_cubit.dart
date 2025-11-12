import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letdem/infrastructure/storage/storage/storage.service.dart';
import '../../../models/voucher.model.dart';
import '../../../repository/marketplace.interface.dart';
import 'pending_vouchers_state.dart';

class PendingVouchersCubit extends Cubit<PendingVouchersState> {
  final IMarketplaceRepository repository;

  PendingVouchersCubit(this.repository) : super(PendingVouchersInitial());

  Future<void> loadPendingVouchers() async {
    try {
      emit(PendingVouchersLoading());
      
      final token = await SecureStorageHelper().read('access_token');
      
      print('=== DEBUG PENDING VOUCHERS ===');
      print('Token obtenido: ${token != null ? "SÍ (${token.length} chars)" : "NULL"}');
      
      if (token == null || token.isEmpty) {
        print('ERROR: Token no encontrado');
        emit(const PendingVouchersError('No estás autenticado. Por favor inicia sesión nuevamente.'));
        return;
      }
      
      print('Token (primeros 20 chars): ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
      print('Llamando a fetchPendingVouchers con authToken...');
      
      final vouchers = await repository.fetchPendingVouchers(authToken: token);
      print('Vouchers recibidos: ${vouchers.length}');
      
      emit(PendingVouchersLoaded(vouchers: vouchers));
    } catch (e, stackTrace) {
      print('ERROR en loadPendingVouchers: $e');
      print('StackTrace: $stackTrace');
      
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      if (errorMessage.contains('401') || errorMessage.toLowerCase().contains('unauthorized')) {
        errorMessage = 'Sesión expirada. Por favor vuelve a iniciar sesión.';
      }
      
      emit(PendingVouchersError(errorMessage));
    }
  }

  Future<void> cancelVoucher(String voucherId) async {
    try {
      final currentState = state;
      if (currentState is! PendingVouchersLoaded) return;
      
      emit(PendingVouchersCancelling(vouchers: currentState.vouchers));
      
      final token = await SecureStorageHelper().read('access_token');
      if (token == null || token.isEmpty) {
        emit(const PendingVouchersError('No estás autenticado'));
        return;
      }
      
      await repository.cancelVoucher(voucherId: voucherId, authToken: token);
      
      // Recargar la lista
      await loadPendingVouchers();
    } catch (e) {
      emit(PendingVouchersError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> refreshVouchers() async {
    await loadPendingVouchers();
  }
}
