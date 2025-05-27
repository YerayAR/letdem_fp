enum EarningStatus {
  missingInfo,
  pending,
  rejected,
  blocked,
  accepted,
}

getStatusString(EarningStatus status) {
  switch (status) {
    case EarningStatus.missingInfo:
      return 'Missing Info';
    case EarningStatus.pending:
      return 'Pending';
    case EarningStatus.rejected:
      return 'Rejected';
    case EarningStatus.blocked:
      return 'Blocked';
    case EarningStatus.accepted:
      return 'Accepted';
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
