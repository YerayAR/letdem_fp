import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:letdem/features/payment_methods/dto/add_payment.dto.dart';
import 'package:letdem/features/payment_methods/repository/payment.interface.dart';
import 'package:letdem/models/payment/payment.model.dart';

part 'payment_method_event.dart';
part 'payment_method_state.dart';

class PaymentMethodBloc extends Bloc<PaymentMethodEvent, PaymentMethodState> {
  final IPaymentMethodRepository repository;

  PaymentMethodBloc({required this.repository})
      : super(PaymentMethodInitial()) {
    on<FetchPaymentMethods>(_onFetchPaymentMethods);
    on<RegisterPaymentMethod>(_onRegisterPaymentMethod);
    on<RemovePaymentMethod>(_onRemovePaymentMethod);
    on<SetDefaultPaymentMethod>(_onSetDefaultPaymentMethod);
  }

  Future<void> _onFetchPaymentMethods(
      FetchPaymentMethods event, Emitter<PaymentMethodState> emit) async {
    try {
      emit(PaymentMethodLoading());
      final methods = await repository.getPaymentMethods();
      emit(PaymentMethodLoaded(paymentMethods: methods));
    } catch (_) {
      emit(const PaymentMethodError("Failed to fetch payment methods."));
    }
  }

  Future<void> _onRegisterPaymentMethod(
      RegisterPaymentMethod event, Emitter<PaymentMethodState> emit) async {
    try {
      emit(PaymentMethodLoading());
      var res = await repository.addPaymentMethod(event.dto);
      emit(PaymentMethodAdded(res));
    } catch (_) {
      emit(const PaymentMethodError("Failed to register payment method."));
      add(const FetchPaymentMethods());
    }
  }

  Future<void> _onRemovePaymentMethod(
      RemovePaymentMethod event, Emitter<PaymentMethodState> emit) async {
    final currentState = state;
    if (currentState is PaymentMethodLoaded) {
      emit(currentState.copyWith(isDeleting: true));
      try {
        await repository.removePaymentMethod(event.paymentMethodId);
        add(const FetchPaymentMethods());
      } catch (_) {
        emit(const PaymentMethodError("Failed to remove payment method."));
        add(const FetchPaymentMethods());
      }
    }
  }

  Future<void> _onSetDefaultPaymentMethod(
      SetDefaultPaymentMethod event, Emitter<PaymentMethodState> emit) async {
    final currentState = state;
    if (currentState is PaymentMethodLoaded) {
      emit(currentState.copyWith(isSettingDefault: true));
      try {
        await repository.setDefaultPaymentMethod(event.paymentMethodId);
        add(const FetchPaymentMethods());
      } catch (_) {
        emit(const PaymentMethodError("Failed to set default payment method."));
      }
    }
  }
}
