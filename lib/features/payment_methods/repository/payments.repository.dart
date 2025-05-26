import 'package:letdem/features/payment_methods/dto/add_payment.dto.dart';
import 'package:letdem/infrastructure/api/api/api.service.dart';
import 'package:letdem/infrastructure/api/api/models/response.model.dart';
import 'package:letdem/models/payment/payment.model.dart';

import '../../../infrastructure/api/api/endpoints.dart';
import 'payment.interface.dart';

class PaymentMethodRepository implements IPaymentMethodRepository {
  @override
  Future<void> addPaymentMethod(AddPaymentMethodDTO dto) async {
    await ApiService.sendRequest(
      endpoint: EndPoints.addPaymentMethod.copyWithDTO(
        dto,
      ),
    );
  }

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    ApiResponse res = await ApiService.sendRequest(
      endpoint: EndPoints.getPaymentMethods,
    );

    return List<PaymentMethodModel>.from(
      (res.data['results'] as List)
          .map((item) => PaymentMethodModel.fromJson(item)),
    );
  }

  @override
  Future<void> removePaymentMethod(String paymentMethodId) async {
    await ApiService.sendRequest(
      endpoint: EndPoints.removePaymentMethod(paymentMethodId),
    );
  }

  @override
  Future<void> setDefaultPaymentMethod(String paymentMethodId) async {
    await ApiService.sendRequest(
      endpoint: EndPoints.setDefaultPaymentMethod(paymentMethodId),
    );
  }
}
