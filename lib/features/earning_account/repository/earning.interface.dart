import 'package:letdem/features/earning_account/dto/earning_account.dto.dart';
import 'package:letdem/models/earnings_account/earning_account.model.dart';

abstract class IEarningsRepository {
  Future<EarningAccount> submitAccount(EarningsAccountDTO dto);
  Future<EarningAccount> submitAddress(EarningsAddressDTO dto);
  Future<EarningAccount> submitDocument(EarningsDocumentDTO dto);
  Future<EarningAccount> submitBankAccount(EarningsBankAccountDTO dto);
}
