part of 'payment_method_bloc.dart';

sealed class PaymentMethodEvent extends Equatable {
  const PaymentMethodEvent();
}

class RegisterPaymentMethod extends PaymentMethodEvent {
  final AddPaymentMethodDTO dto;

  const RegisterPaymentMethod(this.dto);

  @override
  List<Object?> get props => [
        dto.paymentMethodId,
        dto.holderName,
        dto.last4,
        dto.brand,
        dto.isDefault,
      ];
}

class FetchPaymentMethods extends PaymentMethodEvent {
  const FetchPaymentMethods();

  @override
  List<Object?> get props => [];
}

class RemovePaymentMethod extends PaymentMethodEvent {
  final String paymentMethodId;

  const RemovePaymentMethod(this.paymentMethodId);

  @override
  List<Object?> get props => [paymentMethodId];
}

class SetDefaultPaymentMethod extends PaymentMethodEvent {
  final String paymentMethodId;

  const SetDefaultPaymentMethod(this.paymentMethodId);

  @override
  List<Object?> get props => [paymentMethodId];
}
