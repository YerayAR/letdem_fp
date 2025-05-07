import 'package:letdem/features/payment_methods/dto/add_payment.dto.dart';
import 'package:letdem/services/api/api.service.dart';
import 'package:letdem/services/api/endpoints.dart';
import 'package:letdem/services/api/models/response.model.dart';

abstract class IPaymentMethodRepository {
  Future<void> addPaymentMethod(AddPaymentMethodDTO dto);
  Future<List<PaymentMethodModel>> getPaymentMethods();
  Future<void> removePaymentMethod(String paymentMethodId);
  Future<void> setDefaultPaymentMethod(String paymentMethodId);
}

class PaymentMethodModel {
  final String paymentMethodId;
  final String holderName;
  final String last4;
  final String brand;
  final bool isDefault;

  PaymentMethodModel({
    required this.paymentMethodId,
    required this.holderName,
    required this.last4,
    required this.brand,
    required this.isDefault,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      paymentMethodId: json['payment_method_id'],
      holderName: json['holder_name'],
      last4: json['last4'],
      brand: json['brand'],
      isDefault: json['is_default'],
    );
  }
}

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
      (res.data as List).map((item) => PaymentMethodModel.fromJson(item)),
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
