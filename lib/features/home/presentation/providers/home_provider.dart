import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../stores/domain/entities/store_entities.dart';

// Home State
class HomeState extends Equatable {
  final bool isLoading;
  final List<StoreEntity> popularStores;
  final List<CategoryEntity> categories;
  final List<StoreEntity> trendyStores;
  final List<StoreEntity> nearbyStores;
  final String? errorMessage;
  final String currentAddress;
  final bool isLoadingLocation;

  const HomeState({
    this.isLoading = false,
    this.popularStores = const [],
    this.categories = const [],
    this.trendyStores = const [],
    this.nearbyStores = const [],
    this.errorMessage,
    this.currentAddress = 'Locating...',
    this.isLoadingLocation = true,
  });

  HomeState copyWith({
    bool? isLoading,
    List<StoreEntity>? popularStores,
    List<CategoryEntity>? categories,
    List<StoreEntity>? trendyStores,
    List<StoreEntity>? nearbyStores,
    String? errorMessage,
    String? currentAddress,
    bool? isLoadingLocation,
    bool clearError = false,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      popularStores: popularStores ?? this.popularStores,
      categories: categories ?? this.categories,
      trendyStores: trendyStores ?? this.trendyStores,
      nearbyStores: nearbyStores ?? this.nearbyStores,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      currentAddress: currentAddress ?? this.currentAddress,
      isLoadingLocation: isLoadingLocation ?? this.isLoadingLocation,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    popularStores,
    categories,
    trendyStores,
    nearbyStores,
    errorMessage,
    currentAddress,
    isLoadingLocation,
  ];
}

// Home Notifier
class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(const HomeState());

  void setAddress(String address) {
    state = state.copyWith(currentAddress: address, isLoadingLocation: false);
  }

  void setLoadingLocation(bool isLoading) {
    state = state.copyWith(isLoadingLocation: isLoading);
  }

  void setPopularStores(List<StoreEntity> stores) {
    state = state.copyWith(popularStores: stores.take(10).toList());
  }

  void setCategories(List<CategoryEntity> categories) {
    state = state.copyWith(categories: categories.take(5).toList());
  }

  void setTrendyStores(List<StoreEntity> stores) {
    state = state.copyWith(trendyStores: stores);
  }

  void setNearbyStores(List<StoreEntity> stores) {
    state = state.copyWith(nearbyStores: stores);
  }

  void setError(String message) {
    state = state.copyWith(errorMessage: message);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }
}
