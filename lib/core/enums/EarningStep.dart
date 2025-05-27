enum EarningStep {
  personalInfo,
  addressInfo,
  documentUpload,
  bankAccountInfo,
  submitted,
}

getStepString(EarningStep step) {
  switch (step) {
    case EarningStep.personalInfo:
      return 'Personal Info';
    case EarningStep.addressInfo:
      return 'Address Info';
    case EarningStep.documentUpload:
      return 'Document Upload';
    case EarningStep.bankAccountInfo:
      return 'Bank Account Info';
    case EarningStep.submitted:
      return 'Submitted';
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
