import 'package:letdem/services/api/models/endpoint.dart';

class EarningsAccountDTO extends DTO {
  final String country;
  final String userIp;
  final String legalFirstName;
  final String legalLastName;
  final String phone;
  final String birthday;

  EarningsAccountDTO({
    required this.country,
    required this.userIp,
    required this.legalFirstName,
    required this.legalLastName,
    required this.phone,
    required this.birthday,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      "country": country,
      "user_ip": userIp,
      "legal_first_name": legalFirstName,
      "legal_last_name": legalLastName,
      "phone": phone,
      "birthday": birthday,
    };
  }
}

class EarningsAddressDTO extends DTO {
  final String fullStreet;
  final String city;
  final String postalCode;
  final String country;

  EarningsAddressDTO({
    required this.fullStreet,
    required this.city,
    required this.postalCode,
    required this.country,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      "full_street": fullStreet,
      "city": city,
      "postal_code": postalCode,
      "country": country,
    };
  }
}

class EarningsDocumentDTO extends DTO {
  final String documentType;
  final String frontSide;
  final String backSide;

  EarningsDocumentDTO({
    required this.documentType,
    required this.frontSide,
    required this.backSide,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      "document_type": documentType,
      "front_side": frontSide,
      "back_side": backSide,
    };
  }
}

class EarningsBankAccountDTO extends DTO {
  final String accountNumber;

  EarningsBankAccountDTO({
    required this.accountNumber,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      "account_number": accountNumber,
    };
  }
}
