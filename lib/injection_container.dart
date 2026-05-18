import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';
import 'core/utils/api_service.dart';

// Auth imports
import '../features/auth/data/datasources/auth_local_datasource.dart';
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../features/auth/domain/usecases/login_usecase.dart';
import '../features/auth/domain/usecases/logout_usecase.dart';
import '../features/auth/domain/usecases/register_usecase.dart';
import '../features/auth/domain/usecases/update_profile_usecase.dart';
import '../features/auth/domain/usecases/send_verification_code_usecase.dart';
import '../features/auth/domain/usecases/verify_code_usecase.dart';
import '../features/auth/presentation/providers/auth_provider.dart';

// Stores imports
import '../features/stores/data/datasources/store_remote_datasource.dart';
import '../features/stores/data/repositories/store_repository_impl.dart';
import '../features/stores/domain/repositories/store_repository.dart';
import '../features/stores/domain/usecases/get_categories_usecase.dart';
import '../features/stores/domain/usecases/get_stores_usecase.dart';
import '../features/stores/domain/usecases/get_popular_stores_usecase.dart';
import '../features/stores/domain/usecases/get_products_by_store_usecase.dart';
import '../features/stores/domain/usecases/get_product_by_id_usecase.dart';
import '../features/stores/presentation/providers/stores_provider.dart';

// Home imports
import '../features/home/presentation/providers/home_provider.dart';

// Orders imports
import '../features/orders/data/datasources/order_remote_datasource.dart';
import '../features/orders/data/repositories/order_repository_impl.dart';
import '../features/orders/domain/repositories/order_repository.dart';
import '../features/orders/domain/usecases/create_order_usecase.dart';
import '../features/orders/domain/usecases/get_orders_usecase.dart';
// import '../features/orders/domain/usecases/track_order_usecase.dart'; // Not available in customer API
import '../features/orders/presentation/providers/orders_provider.dart';

// Profile imports
import '../features/profile/data/datasources/profile_remote_datasource.dart';
import '../features/profile/data/datasources/promo_remote_datasource.dart';
import '../features/profile/data/repositories/profile_repository_impl.dart';
import '../features/profile/domain/repositories/profile_repository.dart';
import '../features/profile/domain/usecases/get_customer_profile_usecase.dart';
import '../features/profile/domain/usecases/get_addresses_usecase.dart';
import '../features/profile/domain/usecases/create_address_usecase.dart';
import '../features/profile/domain/usecases/update_address_usecase.dart';
import '../features/profile/domain/usecases/delete_address_usecase.dart';
import '../features/profile/domain/usecases/set_default_address_usecase.dart';
import '../features/profile/presentation/providers/profile_provider.dart';
// Promo (voucher) repo & usecases
import '../features/profile/data/repositories/promo_repository_impl.dart';
import '../features/profile/domain/repositories/promo_repository.dart';
import '../features/profile/domain/usecases/get_customer_promo_codes_usecase.dart';
import '../features/profile/domain/usecases/get_used_promo_codes_usecase.dart';
import '../features/profile/domain/usecases/validate_promo_code_usecase.dart';
import '../features/profile/domain/usecases/apply_promo_code_usecase.dart';

// Core
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
final dioClientProvider = Provider<DioClient>((ref) => DioClient());

// Auth Data Sources
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.read(apiServiceProvider));
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl();
});

// Auth Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.read(authRemoteDataSourceProvider),
    localDataSource: ref.read(authLocalDataSourceProvider),
    apiService: ref.read(apiServiceProvider),
    dioClient: ref.read(dioClientProvider),
  );
});

// Auth Use Cases
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.read(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.read(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.read(authRepositoryProvider));
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.read(authRepositoryProvider));
});

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  return UpdateProfileUseCase(ref.read(authRepositoryProvider));
});

final sendVerificationCodeUseCaseProvider =
    Provider<SendVerificationCodeUseCase>((ref) {
      return SendVerificationCodeUseCase(ref.read(authRepositoryProvider));
    });

final verifyCodeUseCaseProvider = Provider<VerifyCodeUseCase>((ref) {
  return VerifyCodeUseCase(ref.read(authRepositoryProvider));
});

// Auth State Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref: ref,
    loginUseCase: ref.read(loginUseCaseProvider),
    registerUseCase: ref.read(registerUseCaseProvider),
    logoutUseCase: ref.read(logoutUseCaseProvider),
    getCurrentUserUseCase: ref.read(getCurrentUserUseCaseProvider),
    updateProfileUseCase: ref.read(updateProfileUseCaseProvider),
    sendVerificationCodeUseCase: ref.read(sendVerificationCodeUseCaseProvider),
    verifyCodeUseCase: ref.read(verifyCodeUseCaseProvider),
    authRepository: ref.read(authRepositoryProvider),
  );
});

// ============= STORES FEATURE =============

// Stores Data Sources
final storeRemoteDataSourceProvider = Provider<StoreRemoteDataSource>((ref) {
  return StoreRemoteDataSourceImpl(dioClient: ref.read(dioClientProvider));
});

// Stores Repository
final storeRepositoryProvider = Provider<StoreRepository>((ref) {
  return StoreRepositoryImpl(
    remoteDataSource: ref.read(storeRemoteDataSourceProvider),
  );
});

// Stores Use Cases
final getCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>((ref) {
  return GetCategoriesUseCase(ref.read(storeRepositoryProvider));
});

final getStoresUseCaseProvider = Provider<GetStoresUseCase>((ref) {
  return GetStoresUseCase(ref.read(storeRepositoryProvider));
});

final getPopularStoresUseCaseProvider = Provider<GetPopularStoresUseCase>((
  ref,
) {
  return GetPopularStoresUseCase(ref.read(storeRepositoryProvider));
});

final getProductsByStoreUseCaseProvider = Provider<GetProductsByStoreUseCase>((
  ref,
) {
  return GetProductsByStoreUseCase(ref.read(storeRepositoryProvider));
});

final getProductByIdUseCaseProvider = Provider<GetProductByIdUseCase>((ref) {
  return GetProductByIdUseCase(ref.read(storeRepositoryProvider));
});

// Stores State Provider
final storesProvider = StateNotifierProvider<StoresNotifier, StoresState>((
  ref,
) {
  return StoresNotifier(
    getCategoriesUseCase: ref.read(getCategoriesUseCaseProvider),
    getStoresUseCase: ref.read(getStoresUseCaseProvider),
    getProductsByStoreUseCase: ref.read(getProductsByStoreUseCaseProvider),
  );
});

// Home Provider
final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier();
});
// ============= ORDERS FEATURE =============

// Orders Data Sources
final orderRemoteDataSourceProvider = Provider<OrderRemoteDataSource>((ref) {
  return OrderRemoteDataSourceImpl(dioClient: ref.read(dioClientProvider));
});

// Orders Repository
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl(
    remoteDataSource: ref.read(orderRemoteDataSourceProvider),
  );
});

// Orders Use Cases
final createOrderUseCaseProvider = Provider<CreateOrderUseCase>((ref) {
  return CreateOrderUseCase(ref.read(orderRepositoryProvider));
});

final getOrdersUseCaseProvider = Provider<GetOrdersUseCase>((ref) {
  return GetOrdersUseCase(ref.read(orderRepositoryProvider));
});

// Track Order Use Case - Not available in customer API
// final trackOrderUseCaseProvider = Provider<TrackOrderUseCase>((ref) {
//   return TrackOrderUseCase(ref.read(orderRepositoryProvider));
// });

// Orders State Provider
final ordersProvider = StateNotifierProvider<OrdersNotifier, OrdersState>((
  ref,
) {
  return OrdersNotifier(
    createOrderUseCase: ref.read(createOrderUseCaseProvider),
    getOrdersUseCase: ref.read(getOrdersUseCaseProvider),
    // trackOrderUseCase: ref.read(trackOrderUseCaseProvider), // Not available in customer API
  );
});

// ============= PROFILE FEATURE =============

// Profile Data Sources
final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((
  ref,
) {
  return ProfileRemoteDataSourceImpl(dioClient: ref.read(dioClientProvider));
});

// Promo (Voucher) Data Source
final promoRemoteDataSourceProvider = Provider<PromoRemoteDataSource>((ref) {
  return PromoRemoteDataSourceImpl(dioClient: ref.read(dioClientProvider));
});

// Profile Repository
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    remoteDataSource: ref.read(profileRemoteDataSourceProvider),
  );
});

// Profile Use Cases
final getCustomerProfileUseCaseProvider = Provider<GetCustomerProfileUseCase>((
  ref,
) {
  return GetCustomerProfileUseCase(ref.read(profileRepositoryProvider));
});

final getAddressesUseCaseProvider = Provider<GetAddressesUseCase>((ref) {
  return GetAddressesUseCase(ref.read(profileRepositoryProvider));
});

final createAddressUseCaseProvider = Provider<CreateAddressUseCase>((ref) {
  return CreateAddressUseCase(ref.read(profileRepositoryProvider));
});

final updateAddressUseCaseProvider = Provider<UpdateAddressUseCase>((ref) {
  return UpdateAddressUseCase(ref.read(profileRepositoryProvider));
});

final deleteAddressUseCaseProvider = Provider<DeleteAddressUseCase>((ref) {
  return DeleteAddressUseCase(ref.read(profileRepositoryProvider));
});

final setDefaultAddressUseCaseProvider = Provider<SetDefaultAddressUseCase>((
  ref,
) {
  return SetDefaultAddressUseCase(ref.read(profileRepositoryProvider));
});

// Promo Repository
final promoRepositoryProvider = Provider<PromoRepository>((ref) {
  return PromoRepositoryImpl(
    remoteDataSource: ref.read(promoRemoteDataSourceProvider),
  );
});

// Promo Use Cases
final getCustomerPromoCodesUseCaseProvider =
    Provider<GetCustomerPromoCodesUseCase>((ref) {
      return GetCustomerPromoCodesUseCase(ref.read(promoRepositoryProvider));
    });

final getUsedPromoCodesUseCaseProvider = Provider<GetUsedPromoCodesUseCase>((
  ref,
) {
  return GetUsedPromoCodesUseCase(ref.read(promoRepositoryProvider));
});

final validatePromoCodeUseCaseProvider = Provider<ValidatePromoCodeUseCase>((
  ref,
) {
  return ValidatePromoCodeUseCase(ref.read(promoRepositoryProvider));
});

final applyPromoCodeUseCaseProvider = Provider<ApplyPromoCodeUseCase>((ref) {
  return ApplyPromoCodeUseCase(ref.read(promoRepositoryProvider));
});

// Profile State Provider
final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((
  ref,
) {
  return ProfileNotifier(
    getCustomerProfileUseCase: ref.read(getCustomerProfileUseCaseProvider),
    getAddressesUseCase: ref.read(getAddressesUseCaseProvider),
    createAddressUseCase: ref.read(createAddressUseCaseProvider),
    updateAddressUseCase: ref.read(updateAddressUseCaseProvider),
    deleteAddressUseCase: ref.read(deleteAddressUseCaseProvider),
    setDefaultAddressUseCase: ref.read(setDefaultAddressUseCaseProvider),
  );
});
