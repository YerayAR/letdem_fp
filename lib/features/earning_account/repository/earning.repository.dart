import 'package:letdem/features/earning_account/dto/earning_account.dto.dart';
import 'package:letdem/features/earning_account/repository/earning.interface.dart';
import 'package:letdem/features/users/repository/user.repository.dart';
import 'package:letdem/services/api/api.service.dart';
import 'package:letdem/services/api/endpoints.dart';
import 'package:letdem/services/api/models/response.model.dart';

class EarningsRepository extends IEarningsRepository {
  @override
  Future<EarningAccount> submitAccount(EarningsAccountDTO dto) async {
    ApiResponse response = await ApiService.sendRequest(
      endpoint: EndPoints.submitEarningsAccount.copyWithDTO(dto),
    );

    return EarningAccount.fromJson(response.data);
  }

  @override
  Future<EarningAccount> submitAddress(EarningsAddressDTO dto) async {
    ApiResponse response = await ApiService.sendRequest(
      endpoint: EndPoints.submitEarningsAddress.copyWithDTO(dto),
    );
    return EarningAccount.fromJson(response.data);
  }

  @override
  Future<EarningAccount> submitDocument(EarningsDocumentDTO dto) async {
    ApiResponse response = await ApiService.sendRequest(
      endpoint: EndPoints.submitEarningsDocument.copyWithDTO(dto),
    );
    return EarningAccount.fromJson(response.data);
  }

  @override
  Future<EarningAccount> submitBankAccount(EarningsBankAccountDTO dto) async {
    ApiResponse response = await ApiService.sendRequest(
      endpoint: EndPoints.submitBankAccount.copyWithDTO(dto),
    );
    return EarningAccount.fromJson(response.data);
  }
}
