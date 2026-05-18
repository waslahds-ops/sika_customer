import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/profile_entities.dart';
import '../../domain/usecases/get_customer_profile_usecase.dart';
import '../../domain/usecases/get_addresses_usecase.dart';
import '../../domain/usecases/create_address_usecase.dart';
import '../../domain/usecases/update_address_usecase.dart';
import '../../domain/usecases/delete_address_usecase.dart';
import '../../domain/usecases/set_default_address_usecase.dart';

// States
class ProfileState extends Equatable {
  final bool isLoading;
  final CustomerEntity? customer;
  final List<AddressEntity> addresses;
  final String? errorMessage;
  final String? successMessage;

  const ProfileState({
    this.isLoading = false,
    this.customer,
    this.addresses = const [],
    this.errorMessage,
    this.successMessage,
  });

  ProfileState copyWith({
    bool? isLoading,
    CustomerEntity? customer,
    List<AddressEntity>? addresses,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      customer: customer ?? this.customer,
      addresses: addresses ?? this.addresses,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    customer,
    addresses,
    errorMessage,
    successMessage,
  ];
}

// Notifier
class ProfileNotifier extends StateNotifier<ProfileState> {
  final GetCustomerProfileUseCase getCustomerProfileUseCase;
  final GetAddressesUseCase getAddressesUseCase;
  final CreateAddressUseCase createAddressUseCase;
  final UpdateAddressUseCase updateAddressUseCase;
  final DeleteAddressUseCase deleteAddressUseCase;
  final SetDefaultAddressUseCase setDefaultAddressUseCase;

  ProfileNotifier({
    required this.getCustomerProfileUseCase,
    required this.getAddressesUseCase,
    required this.createAddressUseCase,
    required this.updateAddressUseCase,
    required this.deleteAddressUseCase,
    required this.setDefaultAddressUseCase,
  }) : super(const ProfileState());

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await getCustomerProfileUseCase(NoParams());

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: _mapFailureToMessage(failure),
      ),
      (customer) =>
          state = state.copyWith(isLoading: false, customer: customer),
    );
  }

  Future<void> loadAddresses() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await getAddressesUseCase(NoParams());

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _mapFailureToMessage(failure),
        );
      },
      (addresses) {
        state = state.copyWith(isLoading: false, addresses: addresses);
      },
    );
  }

  Future<void> createAddress({
    required String label,
    required String address,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );

    final result = await createAddressUseCase(
      CreateAddressParams(
        label: label,
        address: address,
        latitude: latitude,
        longitude: longitude,
        isDefault: isDefault,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: _mapFailureToMessage(failure),
      ),
      (address) {
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Address created successfully',
        );
        loadAddresses();
      },
    );
  }

  Future<void> updateAddress({
    required int addressId,
    String? label,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );

    final result = await updateAddressUseCase(
      UpdateAddressParams(
        addressId: addressId,
        label: label,
        address: address,
        latitude: latitude,
        longitude: longitude,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: _mapFailureToMessage(failure),
      ),
      (address) {
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Address updated successfully',
        );
        loadAddresses();
      },
    );
  }

  Future<void> deleteAddress(int addressId) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );

    final result = await deleteAddressUseCase(
      DeleteAddressParams(addressId: addressId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: _mapFailureToMessage(failure),
      ),
      (_) {
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Address deleted successfully',
        );
        loadAddresses();
      },
    );
  }

  Future<void> setDefaultAddress(int addressId) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );

    final result = await setDefaultAddressUseCase(
      SetDefaultAddressParams(addressId: addressId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: _mapFailureToMessage(failure),
      ),
      (address) {
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Default address updated',
        );
        loadAddresses();
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return 'Server error occurred';
    } else if (failure is NetworkFailure) {
      return 'No internet connection';
    } else if (failure is UnauthorizedFailure) {
      return 'Unauthorized access';
    } else if (failure is NotFoundFailure) {
      return 'Not found';
    }
    return 'An unexpected error occurred';
  }
}
