import 'package:letdem/core/enums/EarningStatus.dart';
import 'package:letdem/core/enums/EarningStep.dart';
import 'package:letdem/features/payout_methods/repository/payout.repository.dart';

class AddressInfo {
  // Replace with actual fields
  AddressInfo();

  factory AddressInfo.fromJson(Map<String, dynamic> json) {
    return AddressInfo(); // Implement properly once you know the fields
  }
}

class DocumentInfo {
  // Replace with actual fields
  DocumentInfo();

  factory DocumentInfo.fromJson(Map<String, dynamic> json) {
    return DocumentInfo(); // Implement properly once you know the fields
  }
}

class EarningAccount {
  final double balance;
  final double pendingBalance;
  final String currency;
  final String legalFirstName;
  final String legalLastName;
  final String phone;
  final String birthday;
  final EarningStatus status;
  final EarningStep step;
  final AddressInfo? address;
  final DocumentInfo? document;
  final List<PayoutMethod> payoutMethods;

  EarningAccount({
    required this.balance,
    required this.pendingBalance,
    required this.currency,
    required this.legalFirstName,
    required this.legalLastName,
    required this.phone,
    required this.birthday,
    required this.status,
    required this.step,
    this.address,
    this.document,
    required this.payoutMethods,
  });

  factory EarningAccount.fromJson(Map<String, dynamic> json) {
    return EarningAccount(
      balance: double.tryParse(json['balance'].toString()) ?? 0.0,
      pendingBalance:
          double.tryParse((json['pending_balance']).toString()) ?? 0.0,
      currency: json['currency'] ?? '',
      legalFirstName: json['legal_first_name'] ?? '',
      legalLastName: json['legal_last_name'] ?? '',
      phone: json['phone'] ?? '',
      birthday: json['birthday'] ?? '',
      status: parseEarningStatus(json['status'].toString().toLowerCase()),
      step: parseEarningStep(json['step'].toString().toLowerCase()),
      address: json['address'] != null
          ? AddressInfo.fromJson(json['address'])
          : null,
      document: json['document'] != null
          ? DocumentInfo.fromJson(json['document'])
          : null,
      payoutMethods: [],
    );
  }
}
