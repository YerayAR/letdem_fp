import 'package:flutter/material.dart';
import 'package:letdem/core/extensions/locale.dart';

enum EarningStatus {
  missingInfo,
  pending,
  rejected,
  blocked,
  accepted,
}

getStatusString(EarningStatus status, BuildContext context) {
  switch (status) {
    case EarningStatus.missingInfo:
      return context.l10n.missingInfo;
    case EarningStatus.pending:
      return context.l10n.pending;
    case EarningStatus.rejected:
      return context.l10n.rejected;
    case EarningStatus.blocked:
      return context.l10n.blocked;
    case EarningStatus.accepted:
      return context.l10n.accepted;
  }
}

EarningStatus parseEarningStatus(String? value) {
  switch (value) {
    case 'missing_info':
      return EarningStatus.missingInfo;
    case 'pending':
      return EarningStatus.pending;
    case 'rejected':
      return EarningStatus.rejected;
    case 'blocked':
      return EarningStatus.blocked;
    case 'accepted':
      return EarningStatus.accepted;
    default:
      return EarningStatus.missingInfo;
  }
}
