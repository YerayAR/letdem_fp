import 'package:letdem/features/earning_account/dto/earning_account.dto.dart';
import 'package:letdem/features/earning_account/repository/earning.interface.dart';
import 'package:letdem/services/api/api.service.dart';
import 'package:letdem/services/api/endpoints.dart';

class EarningsRepository extends IEarningsRepository {
  @override
  Future<void> submitAccount(EarningsAccountDTO dto) async {
    await ApiService.sendRequest(
      endpoint: EndPoints.submitEarningsAccount.copyWithDTO(dto),
    );
  }

  @override
  Future<void> submitAddress(EarningsAddressDTO dto) async {
    await ApiService.sendRequest(
      endpoint: EndPoints.submitEarningsAddress.copyWithDTO(dto),
    );
  }

  @override
  Future<void> submitDocument(EarningsDocumentDTO dto) async {
    await ApiService.sendRequest(
      endpoint: EndPoints.submitEarningsDocument.copyWithDTO(dto),
    );
  }

  @override
  Future<void> submitBankAccount(EarningsBankAccountDTO dto) async {
    await ApiService.sendRequest(
      endpoint: EndPoints.submitBankAccount.copyWithDTO(dto),
    );
  }
}
