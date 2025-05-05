import 'package:letdem/features/earning_account/dto/earning_account.dto.dart';

abstract class IEarningsRepository {
  Future<void> submitAccount(EarningsAccountDTO dto);
  Future<void> submitAddress(EarningsAddressDTO dto);
  Future<void> submitDocument(EarningsDocumentDTO dto);
  Future<void> submitBankAccount(EarningsBankAccountDTO dto);
}
