import 'package:equatable/equatable.dart';

class Context extends Equatable {
  final Country country;
  final Postcode postcode;
  final PlaceLocation place;
  final Locality locality;
  final Neighborhood neighborhood;
  final Address address;
  final Street street;

  const Context({
    required this.country,
    required this.postcode,
    required this.place,
    required this.locality,
    required this.neighborhood,
    required this.address,
    required this.street,
  });

  factory Context.fromJson(Map<String, dynamic> json) {
    return Context(
      country: Country.fromJson(json['country'] ?? {}),
      postcode: Postcode.fromJson(json['postcode'] ?? {}),
      place: PlaceLocation.fromJson(json['place'] ?? {}),
      locality: Locality.fromJson(json['locality'] ?? {}),
      neighborhood: Neighborhood.fromJson(json['neighborhood'] ?? {}),
      address: Address.fromJson(json['address'] ?? {}),
      street: Street.fromJson(json['street'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'country': country.toJson(),
      'postcode': postcode.toJson(),
      'place': place.toJson(),
      'locality': locality.toJson(),
      'neighborhood': neighborhood.toJson(),
      'address': address.toJson(),
      'street': street.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        country,
        postcode,
        place,
        locality,
        neighborhood,
        address,
        street,
      ];
}

class Country extends Equatable {
  final String name;
  final String countryCode;
  final String countryCodeAlpha3;

  const Country({
    required this.name,
    required this.countryCode,
    required this.countryCodeAlpha3,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name'] ?? '',
      countryCode: json['country_code'] ?? '',
      countryCodeAlpha3: json['country_code_alpha_3'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'country_code': countryCode,
      'country_code_alpha_3': countryCodeAlpha3,
    };
  }

  @override
  List<Object?> get props => [name, countryCode, countryCodeAlpha3];
}

class Postcode extends Equatable {
  final String id;
  final String name;

  const Postcode({required this.id, required this.name});

  factory Postcode.fromJson(Map<String, dynamic> json) {
    return Postcode(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  @override
  List<Object?> get props => [id, name];
}

class PlaceLocation extends Equatable {
  final String id;
  final String name;

  const PlaceLocation({required this.id, required this.name});

  factory PlaceLocation.fromJson(Map<String, dynamic> json) {
    return PlaceLocation(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  @override
  List<Object?> get props => [id, name];
}

class Locality extends Equatable {
  final String id;
  final String name;

  const Locality({required this.id, required this.name});

  factory Locality.fromJson(Map<String, dynamic> json) {
    return Locality(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  @override
  List<Object?> get props => [id, name];
}

class Neighborhood extends Equatable {
  final String id;
  final String name;

  const Neighborhood({required this.id, required this.name});

  factory Neighborhood.fromJson(Map<String, dynamic> json) {
    return Neighborhood(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  @override
  List<Object?> get props => [id, name];
}

class Address extends Equatable {
  final String name;
  final String addressNumber;
  final String streetName;

  const Address({
    required this.name,
    required this.addressNumber,
    required this.streetName,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      name: json['name'] ?? '',
      addressNumber: json['address_number'] ?? '',
      streetName: json['street_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'address_number': addressNumber,
        'street_name': streetName,
      };

  @override
  List<Object?> get props => [name, addressNumber, streetName];
}

class Street extends Equatable {
  final String name;

  const Street({required this.name});

  factory Street.fromJson(Map<String, dynamic> json) {
    return Street(name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() => {'name': name};

  @override
  List<Object?> get props => [name];
}
