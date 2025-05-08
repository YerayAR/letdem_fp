import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:letdem/features/earning_account/dto/earning_account.dto.dart';

abstract class EarningsEvent extends Equatable {
  const EarningsEvent();

  @override
  List<Object?> get props => [];
}

class SubmitEarningsAccount extends EarningsEvent {
  final String legalFirstName;
  final String legalLastName;
  final String phone;
  final String birthday;

  const SubmitEarningsAccount({
    required this.legalFirstName,
    required this.legalLastName,
    required this.phone,
    required this.birthday,
  });

  @override
  List<Object?> get props => [
        legalFirstName,
        legalLastName,
        phone,
        birthday,
      ];
}

class SubmitEarningsAddress extends EarningsEvent {
  final EarningsAddressDTO dto;

  const SubmitEarningsAddress(this.dto);

  @override
  List<Object?> get props => [dto];
}

class SubmitEarningsDocument extends EarningsEvent {
  final File? frontSide;
  final File? backSide;
  final String documentType;

  const SubmitEarningsDocument(
      this.frontSide, this.backSide, this.documentType);

  @override
  List<Object?> get props => [frontSide, backSide, documentType];
}

class SubmitEarningsBankAccount extends EarningsEvent {
  final EarningsBankAccountDTO dto;

  const SubmitEarningsBankAccount(this.dto);

  @override
  List<Object?> get props => [dto];
}
