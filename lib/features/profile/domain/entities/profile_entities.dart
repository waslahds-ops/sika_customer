import 'package:equatable/equatable.dart';

class CustomerEntity extends Equatable {
  final int customerId;
  final int userId;
  final String? phoneNumber;
  final String? defaultAddressId;

  const CustomerEntity({
    required this.customerId,
    required this.userId,
    this.phoneNumber,
    this.defaultAddressId,
  });

  @override
  List<Object?> get props => [
    customerId,
    userId,
    phoneNumber,
    defaultAddressId,
  ];
}

class AddressEntity extends Equatable {
  final int addressId;
  final int userId;
  final String label;
  final String address;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  const AddressEntity({
    required this.addressId,
    required this.userId,
    required this.label,
    required this.address,
    this.latitude,
    this.longitude,
    required this.isDefault,
  });

  @override
  List<Object?> get props => [
    addressId,
    userId,
    label,
    address,
    latitude,
    longitude,
    isDefault,
  ];
}
