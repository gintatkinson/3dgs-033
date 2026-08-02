import 'package:app_flutter/domain/annotations.dart';
import 'package:meta/meta.dart';

/// Thrown when a country code fails ISO 3166-1 alpha-2 format validation.
@immutable
class CountryCodeFormatError implements Exception {
  final String message;
  const CountryCodeFormatError(this.message);

  @override
  String toString() => 'CountryCodeFormatError: $message';
}

/// Represents a physical address as defined in UML::PhysicalAddress.
///
/// Fields correspond to address components; all are optional but at least one must be set for validity.
@immutable
@realizes(r'UML::PhysicalAddress')
class PhysicalAddress {
  static final _countryCodePattern = RegExp(r'^[A-Z]{2}$');

  final String? address;
  final String? postalCode;
  final String? state;
  final String? city;
  final String? countryCode;

  const PhysicalAddress({
    this.address,
    this.postalCode,
    this.state,
    this.city,
    this.countryCode,
  });

  bool isValid() {
    final hasField = address != null ||
        postalCode != null ||
        state != null ||
        city != null ||
        countryCode != null;
    if (!hasField) return false;

    if (countryCode != null && !_countryCodePattern.hasMatch(countryCode!)) {
      return false;
    }

    return true;
  }

  String? formatted() {
    if (!isValid()) return null;

    final parts = <String>[];
    if (address != null) parts.add(address!);
    if (postalCode != null && city != null) {
      parts.add('$postalCode $city');
    } else {
      if (postalCode != null) parts.add(postalCode!);
      if (city != null) parts.add(city!);
    }
    if (state != null) parts.add(state!);
    if (countryCode != null) parts.add(countryCode!);

    if (parts.isEmpty) return null;
    return parts.join(', ');
  }

  Map<String, dynamic> toJson() {
    return {
      if (address != null) 'address': address,
      if (postalCode != null) 'postal-code': postalCode,
      if (state != null) 'state': state,
      if (city != null) 'city': city,
      if (countryCode != null) 'country-code': countryCode,
    };
  }

  factory PhysicalAddress.fromJson(Map<String, dynamic> json) {
    return PhysicalAddress(
      address: json['address'] as String?,
      postalCode: json['postal-code'] as String?,
      state: json['state'] as String?,
      city: json['city'] as String?,
      countryCode: json['country-code'] as String?,
    );
  }
}
