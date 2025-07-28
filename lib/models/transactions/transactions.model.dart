import 'package:flutter/material.dart';
import 'package:letdem/core/extensions/locale.dart';

class TransactionParams {
  final DateTime startDate;
  final DateTime endDate;
  final int pageSize;
  final int page;
  TransactionParams({
    required this.startDate,
    required this.endDate,
    required this.pageSize,
    required this.page,
  });
}

enum TransactionType {
  SPACE_PAYMENT,
  WITHDRAW,
  SPACE_TRANSFER,
  SPACE_WITHDRAWAL,
  SPACE_DEPOSIT,
}

String getTransactionTypeString(TransactionType type, BuildContext context) {
  switch (type) {
    case TransactionType.SPACE_PAYMENT:
      return context.l10n.transactionSpacePayment;
    case TransactionType.WITHDRAW:
      return context.l10n.transactionWithdraw;
    case TransactionType.SPACE_TRANSFER:
      return context.l10n.transactionSpaceTransfer;
    case TransactionType.SPACE_WITHDRAWAL:
      return context.l10n.transactionSpaceWithdrawal;
    case TransactionType.SPACE_DEPOSIT:
      return context.l10n.transactionSpaceDeposit;
  }
}

bool isPositiveTransaction(TransactionType type) {
  switch (type) {
    case TransactionType.SPACE_PAYMENT:
    case TransactionType.SPACE_DEPOSIT:
      return true;
    case TransactionType.WITHDRAW:
    case TransactionType.SPACE_TRANSFER:
    case TransactionType.SPACE_WITHDRAWAL:
      return false;
  }
}

TransactionType getTransactionType(String type) {
  switch (type) {
    case 'SPACE_PAYMENT':
      return TransactionType.SPACE_PAYMENT;
    case 'WITHDRAW':
      return TransactionType.WITHDRAW;
    case 'SPACE_TRANSFER':
      return TransactionType.SPACE_TRANSFER;
    case 'SPACE_WITHDRAWAL':
      return TransactionType.SPACE_WITHDRAWAL;
    case 'SPACE_DEPOSIT':
      return TransactionType.SPACE_DEPOSIT;
    default:
      throw Exception('Unknown transaction type: $type');
  }
}

class Transaction {
  // {amount: 2.00, currency: eur, source: SPACE_PAYMENT, created: 2025-05-09T00:49:26.802051Z}
  final double amount;
  final TransactionType source;
  final DateTime created;

  Transaction(
      {required this.amount, required this.source, required this.created});

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
        amount: getTransactionType(json['source']) == TransactionType.WITHDRAW
            ? double.parse(json['amount'].toString())
            : double.parse(json['amount'].toString()),
        source: getTransactionType(json['source']),
        created: DateTime.parse(json['created']).toLocal());
  }
}
