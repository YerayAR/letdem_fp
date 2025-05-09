import 'package:letdem/services/api/api.service.dart';
import 'package:letdem/services/api/endpoints.dart';
import 'package:letdem/services/api/models/endpoint.dart';
import 'package:letdem/services/api/models/response.model.dart';

abstract class IPayoutMethodRepository {
  Future<List<PayoutMethod>> fetchPayoutMethods();
  Future<void> addPayoutMethod(PayoutMethodDTO method);
  Future<void> deletePayoutMethod(String id);
}

class PayoutMethodRepository implements IPayoutMethodRepository {
  @override
  Future<List<PayoutMethod>> fetchPayoutMethods() async {
    ApiResponse response = await ApiService.sendRequest(
      endpoint: EndPoints.getPayoutMethods,
    );

    return (response.data['results'] as List)
        .map((e) => PayoutMethod.fromJson(e))
        .toList();
  }

  @override
  Future<void> addPayoutMethod(PayoutMethodDTO method) async {
    await ApiService.sendRequest(
      endpoint: EndPoints.addPayoutMethod.copyWithDTO(method),
    );
  }

  @override
  Future<void> deletePayoutMethod(String id) async {
    // await ApiService.sendRequest(
    //   endpoint: EndPoints.deletePayoutMethod.copyWith(pathParams: [id]),
    // );
  }
}

class PayoutMethodDTO extends DTO {
  // {
  // "account_number": "ES0700120345030000067890",
  // "is_default": false
  // }
  final String accountNumber;
  final bool isDefault;

  PayoutMethodDTO({
    required this.accountNumber,
    required this.isDefault,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'account_number': accountNumber,
      'is_default': isDefault,
    };
  }
}

class PayoutMethod {
  final String id;
  final String country;
  final String currency;
  final String accountHolderName;
  final String accountNumber;
  final bool isDefault;

  PayoutMethod({
    required this.id,
    required this.country,
    required this.currency,
    required this.accountHolderName,
    required this.accountNumber,
    required this.isDefault,
  });

  factory PayoutMethod.fromJson(Map<String, dynamic> json) => PayoutMethod(
        id: json['id'],
        country: json['country'],
        currency: json['currency'],
        accountHolderName: json['account_holder_name'],
        accountNumber: json['account_number'],
        isDefault: json['is_default'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'country': country,
        'currency': currency,
        'account_holder_name': accountHolderName,
        'account_number': accountNumber,
        'is_default': isDefault,
      };
}
