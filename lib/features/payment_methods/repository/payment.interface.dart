import 'package:letdem/features/payment_methods/dto/add_payment.dto.dart';
import 'package:letdem/models/payment/payment.model.dart';

abstract class IPaymentMethodRepository {
  Future<PaymentMethodModel> addPaymentMethod(AddPaymentMethodDTO dto);
  Future<List<PaymentMethodModel>> getPaymentMethods();
  Future<void> removePaymentMethod(String paymentMethodId);
  Future<void> setDefaultPaymentMethod(String paymentMethodId);
}
