import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:letdem/features/payout_methods/repository/payout.repository.dart';
import 'package:letdem/services/api/models/error.dart';
import 'package:letdem/services/toast/toast.dart';

part 'payout_method_event.dart';
part 'payout_method_state.dart';

class PayoutMethodBloc extends Bloc<PayoutMethodEvent, PayoutMethodState> {
  final PayoutMethodRepository payoutMethodRepository;

  PayoutMethodBloc({required this.payoutMethodRepository})
      : super(PayoutMethodInitial()) {
    on<FetchPayoutMethods>(_onFetch);
    on<AddPayoutMethod>(_onAdd);
    on<DeletePayoutMethod>(_onDelete);
  }

  Future<void> _onFetch(
      FetchPayoutMethods event, Emitter<PayoutMethodState> emit) async {
    emit(PayoutMethodLoading());
    try {
      final methods = await payoutMethodRepository.fetchPayoutMethods();
      emit(PayoutMethodSuccess(methods, const [], false));
    } on ApiError catch (err) {
      emit(PayoutMethodFailure(err.message));
    } catch (e) {
      emit(PayoutMethodFailure(e.toString()));
    }
  }

  Future<void> _onAdd(
      AddPayoutMethod event, Emitter<PayoutMethodState> emit) async {
    emit(PayoutMethodLoading());
    try {
      await payoutMethodRepository.addPayoutMethod(event.method);
      add(FetchPayoutMethods());
    } on ApiError catch (err) {
      Toast.showError(err.message);
      add(FetchPayoutMethods());
    } catch (e) {
      Toast.showError("An error occurred");
      add(FetchPayoutMethods());
    }
  }

  Future<void> _onDelete(
      DeletePayoutMethod event, Emitter<PayoutMethodState> emit) async {
    emit(PayoutMethodLoading());
    try {
      await payoutMethodRepository.deletePayoutMethod(event.methodId);

      var data = await payoutMethodRepository.fetchPayoutMethods();

      emit(PayoutMethodSuccess(data, const [], false));
    } catch (e) {
      emit(PayoutMethodFailure(e.toString()));
    }
  }
}
