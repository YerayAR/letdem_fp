part of 'payment_method_bloc.dart';

sealed class PaymentMethodState extends Equatable {
  const PaymentMethodState();
}

final class PaymentMethodInitial extends PaymentMethodState {
  @override
  List<Object> get props => [];
}

final class PaymentMethodLoaded extends PaymentMethodState {
  final List<PaymentMethodModel> paymentMethods;
  final bool isDeleting;
  final bool isSettingDefault;

  const PaymentMethodLoaded({
    required this.paymentMethods,
    this.isDeleting = false,
    this.isSettingDefault = false,
  });

  PaymentMethodLoaded copyWith({
    List<PaymentMethodModel>? paymentMethods,
    bool? isDeleting,
    bool? isSettingDefault,
  }) {
    return PaymentMethodLoaded(
      paymentMethods: paymentMethods ?? this.paymentMethods,
      isDeleting: isDeleting ?? this.isDeleting,
      isSettingDefault: isSettingDefault ?? this.isSettingDefault,
    );
  }

  @override
  List<Object> get props => [paymentMethods, isDeleting, isSettingDefault];
}

final class PaymentMethodError extends PaymentMethodState {
  final String message;

  const PaymentMethodError(this.message);

  @override
  List<Object> get props => [message];
}

class PaymentMethodLoading extends PaymentMethodState {
  @override
  List<Object> get props => [];
}
