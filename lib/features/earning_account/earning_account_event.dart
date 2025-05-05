import 'package:equatable/equatable.dart';
import 'package:letdem/features/earning_account/dto/earning_account.dto.dart';

abstract class EarningsEvent extends Equatable {
  const EarningsEvent();

  @override
  List<Object?> get props => [];
}

class SubmitEarningsAccount extends EarningsEvent {
  final EarningsAccountDTO dto;

  const SubmitEarningsAccount(this.dto);

  @override
  List<Object?> get props => [dto];
}

class SubmitEarningsAddress extends EarningsEvent {
  final EarningsAddressDTO dto;

  const SubmitEarningsAddress(this.dto);

  @override
  List<Object?> get props => [dto];
}

class SubmitEarningsDocument extends EarningsEvent {
  final EarningsDocumentDTO dto;

  const SubmitEarningsDocument(this.dto);

  @override
  List<Object?> get props => [dto];
}

class SubmitEarningsBankAccount extends EarningsEvent {
  final EarningsBankAccountDTO dto;

  const SubmitEarningsBankAccount(this.dto);

  @override
  List<Object?> get props => [dto];
}
