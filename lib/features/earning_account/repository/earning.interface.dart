import 'package:letdem/features/earning_account/dto/earning_account.dto.dart';
import 'package:letdem/features/users/repository/user.repository.dart';

abstract class IEarningsRepository {
  Future<EarningAccount> submitAccount(EarningsAccountDTO dto);
  Future<EarningAccount> submitAddress(EarningsAddressDTO dto);
  Future<EarningAccount> submitDocument(EarningsDocumentDTO dto);
  Future<EarningAccount> submitBankAccount(EarningsBankAccountDTO dto);
}
