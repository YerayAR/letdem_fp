import 'package:flutter/material.dart';
import 'package:letdem/core/extensions/locale.dart';

enum EarningStep {
  personalInfo,
  addressInfo,
  documentUpload,
  bankAccountInfo,
  submitted,
}

getStepString(EarningStep step, BuildContext context) {
  switch (step) {
    case EarningStep.personalInfo:
      return context.l10n.personalInfo;
    case EarningStep.addressInfo:
      return context.l10n.addressInfo;
    case EarningStep.documentUpload:
      return context.l10n.documentUpload;
    case EarningStep.bankAccountInfo:
      return context.l10n.bankAccountInfo;
    case EarningStep.submitted:
      return context.l10n.submitted;
  }
}

EarningStep parseEarningStep(String? value) {
  switch (value) {
    case 'personal_info':
      return EarningStep.personalInfo;
    case 'address_info':
      return EarningStep.addressInfo;
    case 'document_info':
      return EarningStep.documentUpload;
    case 'bank_account_info':
      return EarningStep.bankAccountInfo;
    case 'submitted':
      return EarningStep.submitted;
    default:
      return EarningStep.personalInfo;
  }
}
