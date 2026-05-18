import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/store_entities.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_stores_usecase.dart';
import '../../domain/usecases/get_products_by_store_usecase.dart';

// States
class StoresState extends Equatable {
  final bool isLoading;
  final List<CategoryEntity> categories;
  final List<StoreEntity> stores;
  final List<ProductEntity> products;
  final String? errorMessage;
  final CategoryEntity? selectedCategory;
  final StoreEntity? selectedStore;

  const StoresState({
    this.isLoading = false,
    this.categories = const [],
    this.stores = const [],
    this.products = const [],
    this.errorMessage,
    this.selectedCategory,
    this.selectedStore,
  });

  StoresState copyWith({
    bool? isLoading,
    List<CategoryEntity>? categories,
    List<StoreEntity>? stores,
    List<ProductEntity>? products,
    String? errorMessage,
    CategoryEntity? selectedCategory,
    StoreEntity? selectedStore,
    bool clearError = false,
    bool clearSelectedCategory = false,
    bool clearSelectedStore = false,
  }) {
    return StoresState(
      isLoading: isLoading ?? this.isLoading,
      categories: categories ?? this.categories,
      stores: stores ?? this.stores,
      products: products ?? this.products,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedCategory: clearSelectedCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      selectedStore: clearSelectedStore
          ? null
          : (selectedStore ?? this.selectedStore),
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    categories,
    stores,
    products,
    errorMessage,
    selectedCategory,
    selectedStore,
  ];
}

// Notifier
class StoresNotifier extends StateNotifier<StoresState> {
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetStoresUseCase getStoresUseCase;
  final GetProductsByStoreUseCase getProductsByStoreUseCase;

  StoresNotifier({
    required this.getCategoriesUseCase,
    required this.getStoresUseCase,
    required this.getProductsByStoreUseCase,
  }) : super(const StoresState());

  Future<void> loadCategories() async {
    try {
      print('🔄 loadCategories: Starting...');
      
      // Load cached categories immediately
      final appStateBox = Hive.box('appStateBox');
      final cachedCategoriesJson = appStateBox.get('categories_cache');
      
      if (cachedCategoriesJson != null && cachedCategoriesJson is List) {
        try {
          final cachedCategories = (cachedCategoriesJson)
              .map((json) {
                // Convert Map<dynamic, dynamic> to Map<String, dynamic>
                if (json is Map) {
                  final converted = <String, dynamic>{};
                  json.forEach((key, value) {
                    converted[key.toString()] = value;
                  });
                  return _categoryFromJson(converted);
                }
                return _categoryFromJson(json as Map<String, dynamic>);
              })
              .toList();
          
          _processCategoriesData(cachedCategories);
          print('✅ Loaded ${cachedCategories.length} categories from cache');
        } catch (e) {
          print('⚠️ Error parsing cached categories: $e');
        }
      }
      
      // Fetch fresh data from API in background
      state = state.copyWith(clearError: true);
      final result = await getCategoriesUseCase(NoParams());
      
      result.fold(
        (failure) {
          // Only show error if no cached data
          if (state.categories.isEmpty) {
            state = state.copyWith(errorMessage: _mapFailureToMessage(failure));
            print('❌ Error loading categories: ${_mapFailureToMessage(failure)}');
          }
        },
        (categories) {
          print('📱 Loaded ${categories.length} fresh categories from API');
          // Process and cache the fresh categories
          _processCategoriesData(categories);
        },
      );
    } catch (e) {
      print('❌ Error in loadCategories: $e');
    }
  }
  
  CategoryEntity _categoryFromJson(Map<String, dynamic> json) {
    return CategoryEntity(
      categoryId: json['categoryId'] ?? 0,
      nameEn: json['nameEn'] ?? '',
      nameAr: json['nameAr'] ?? '',
      imageUrl: json['imageUrl'],
      isActive: json['isActive'] ?? true,
    );
  }
  
  void _processCategoriesData(List<CategoryEntity> categories) {
    print('📂 Processing ${categories.length} categories...');
    
    // Check if "All" category exists
    CategoryEntity? allCategory;
    try {
      allCategory = categories.firstWhere(
        (cat) => cat.nameEn.toLowerCase() == 'all',
      );
    } catch (e) {
      allCategory = CategoryEntity(
        categoryId: 0,
        nameEn: 'All',
        nameAr: 'الكل',
        imageUrl: null,
        isActive: true,
      );
    }
    
    // Find Driver/Rider category
    CategoryEntity? driverCategory;
    try {
      driverCategory = categories.firstWhere(
        (cat) {
          final name = cat.nameEn.toLowerCase();
          return name == 'driver' || name == 'rider' || name == 'butler';
        },
      );
      print('✅ Found Driver/Rider category: ${driverCategory.nameEn}');
    } catch (e) {
      driverCategory = null;
      print('⚠️ No Driver/Rider category found');
    }
    
    // Get other categories (excluding All and Driver/Rider)
    final otherCategories = categories.where(
      (cat) {
        final name = cat.nameEn.toLowerCase();
        return name != 'all' && name != 'driver' && name != 'rider' && name != 'butler';
      },
    ).toList();
    print('📋 Other categories: ${otherCategories.map((c) => c.nameEn).toList()}');
    
    // Build ordered list: All -> Driver -> Others
    final List<CategoryEntity> orderedCategories = [
      allCategory,
      if (driverCategory != null) driverCategory,
      ...otherCategories,
    ];
    
    print('✅ Category order: ${orderedCategories.map((c) => c.nameEn).toList()}');
    
    // Cache the ordered categories immediately
    try {
      final appStateBox = Hive.box('appStateBox');
      final categoriesJson = orderedCategories
          .map((c) => {
            'categoryId': c.categoryId,
            'nameEn': c.nameEn,
            'nameAr': c.nameAr,
            'imageUrl': c.imageUrl,
            'isActive': c.isActive,
          })
          .toList();
      appStateBox.put('categories_cache', categoriesJson);
      print('💾 Cached ${orderedCategories.length} categories');
    } catch (e) {
      print('⚠️ Error caching categories: $e');
    }
    
    // Update state with ordered categories, "All" as default selected
    state = state.copyWith(
      categories: orderedCategories,
      selectedCategory: allCategory,
    );
  }

  Future<void> loadStores({
    int? categoryId,
    double? latitude,
    double? longitude,
    String? search,
    bool excludeSpecialCategories = false,
  }) async {
    try {
      print('🔄 loadStores: Starting (categoryId: $categoryId, search: $search)');
      // Load cached stores immediately
      final appStateBox = Hive.box('appStateBox');
      final cacheKey =
          'stores_cache_${categoryId ?? "all"}_${excludeSpecialCategories ? "nospecial" : "all"}';
      final cachedStoresJson = appStateBox.get(cacheKey);
      
      if (cachedStoresJson != null && cachedStoresJson is List) {
        try {
          final cachedStores = (cachedStoresJson)
              .map((json) {
                // Convert Map<dynamic, dynamic> to Map<String, dynamic>
                if (json is Map) {
                  final converted = <String, dynamic>{};
                  json.forEach((key, value) {
                    converted[key.toString()] = value;
                  });
                  return _storeFromJson(converted);
                }
                return _storeFromJson(json as Map<String, dynamic>);
              })
              .toList();
          
          final filteredCachedStores =
              _filterExcludedStores(cachedStores, excludeSpecialCategories);

          state = state.copyWith(stores: filteredCachedStores, isLoading: true);
          print(
            '✅ Loaded ${filteredCachedStores.length} stores from cache (key: $cacheKey)',
          );
        } catch (e) {
          print('⚠️ Error parsing cached stores: $e');
          state = state.copyWith(isLoading: true);
        }
      } else {
        // No cache, show loading state
        print('📭 No cached stores for key: $cacheKey');
        state = state.copyWith(isLoading: true);
      }
      
      // Fetch fresh data from API in background
      print('🌐 Fetching fresh stores from API...');
      state = state.copyWith(clearError: true);

      final result = await getStoresUseCase(
        GetStoresParams(
          categoryId: categoryId,
          latitude: latitude,
          longitude: longitude,
          search: search,
          excludeSpecialCategories: excludeSpecialCategories,
        ),
      );

      result.fold(
        (failure) {
          // Only show error if no cached data
          if (state.stores.isEmpty) {
            state = state.copyWith(
              isLoading: false,
              errorMessage: _mapFailureToMessage(failure)
            );
            print('❌ Error loading stores: ${_mapFailureToMessage(failure)}');
          } else {
            // Keep cached data visible
            state = state.copyWith(isLoading: false);
            print('⚠️ Error loading fresh stores but using cache: ${_mapFailureToMessage(failure)}');
          }
        },
        (stores) async {
          final filteredStores =
              _filterExcludedStores(stores, excludeSpecialCategories);
          // Save to cache as JSON list
          try {
            final storesJson = filteredStores
                .map((s) => {
                  'storeId': s.storeId,
                  'merchantId': s.merchantId,
                  'categoryId': s.categoryId,
                  'name': s.name,
                  'deliveryFee': s.deliveryFee,
                  'minOrderAmount': s.minOrderAmount,
                  'isOpen': s.isOpen,
                  'isActive': s.isActive,
                  'logoUrl': s.logoUrl,
                  'coverUrl': s.coverUrl,
                  'description': s.description,
                  'ratingAvg': s.ratingAvg,
                  'latitude': s.latitude,
                  'longitude': s.longitude,
                  'estimatedDeliveryTime': s.estimatedDeliveryTime,
                  'ordersCount': s.ordersCount,
                })
                .toList();
            appStateBox.put(cacheKey, storesJson);
            print('💾 Cached ${filteredStores.length} stores (key: $cacheKey)');
          } catch (e) {
            print('⚠️ Error caching stores: $e');
          }
          
          state = state.copyWith(stores: filteredStores, isLoading: false);
          print(
            '📱 Loaded ${filteredStores.length} fresh stores from API (key: $cacheKey)',
          );
        },
      );
    } catch (e) {
      print('❌ Error in loadStores: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An unexpected error occurred'
      );
    }
  }
  
  StoreEntity _storeFromJson(Map<String, dynamic> json) {
    return StoreEntity(
      storeId: json['storeId'] ?? 0,
      merchantId: json['merchantId'] ?? 0,
      categoryId: json['categoryId'] ?? 0,
      name: json['name'] ?? '',
      deliveryFee: json['deliveryFee'] ?? 0.0,
      minOrderAmount: json['minOrderAmount'] ?? 0.0,
      isOpen: json['isOpen'] ?? false,
      isActive: json['isActive'] ?? false,
      logoUrl: json['logoUrl'],
      coverUrl: json['coverUrl'],
      description: json['description'],
      ratingAvg: json['ratingAvg'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      estimatedDeliveryTime: json['estimatedDeliveryTime'],
      ordersCount: json['ordersCount'],
    );
  }

  List<StoreEntity> _filterExcludedStores(
    List<StoreEntity> stores,
    bool excludeSpecialCategories,
  ) {
    if (!excludeSpecialCategories) return stores;
    final excludedCategoryIds = state.categories
        .where((c) => _isExcludedCategoryName(c.nameEn))
        .map((c) => c.categoryId)
        .toSet();
    if (excludedCategoryIds.isEmpty) return stores;

    return stores
        .where((s) => !excludedCategoryIds.contains(s.categoryId))
        .toList();
  }

  bool _isExcludedCategoryName(String name) {
    final lower = name.toLowerCase();
    return lower.contains('butler') ||
        lower.contains('barber') ||
        lower.contains('booking');
  }

  Future<void> loadProductsByStore(int storeId) async {
    print(
      '📱 [PRODUCTS] Provider: Loading for store $storeId at ${DateTime.now()}',
    );
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await getProductsByStoreUseCase(storeId).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print(
            '❌ [PRODUCTS] Provider: TIMEOUT after 15 seconds for store $storeId',
          );
          throw Exception('Product loading timeout');
        },
      );

      result.fold(
        (failure) {
          final errorMsg = _mapFailureToMessage(failure);
          print('📱 [PRODUCTS] Provider: Error - $errorMsg');
          state = state.copyWith(isLoading: false, errorMessage: errorMsg);
        },
        (products) {
          print(
            '📱 [PRODUCTS] Provider: Success at ${DateTime.now()} - ${products.length} products',
          );
          state = state.copyWith(isLoading: false, products: products);
        },
      );
    } catch (e, stackTrace) {
      print('📱 [PRODUCTS] Provider: Exception - $e');
      print('📱 [PRODUCTS] Stack: $stackTrace');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load products'
      );
    }
  }

  void selectCategory(CategoryEntity? category) {
    // Immediately show loading state
    state = state.copyWith(
      selectedCategory: category,
      clearSelectedCategory: category == null,
      isLoading: true,
      clearError: true,
    );
    if (category != null) {
      // Check if it's the "All" category (categoryId == 0 or by name)
      if (category.categoryId == 0 || category.nameEn.toLowerCase() == 'all') {
        // Load all stores without category filter
        loadStores(excludeSpecialCategories: true);
      } else {
        // Load stores for specific category
        loadStores(categoryId: category.categoryId);
      }
    } else {
      loadStores();
    }
  }

  void selectStore(StoreEntity? store) {
    state = state.copyWith(
      selectedStore: store,
      clearSelectedStore: store == null,
    );
    if (store != null) {
      loadProductsByStore(store.storeId);
    }
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

// Popular Stores Provider - Available from injection_container
final popularStoresProvider = FutureProvider<List<StoreEntity>>((ref) async {
  try {
    final getPopularStoresUseCase = ref.read(getPopularStoresUseCaseProvider);
    final result = await getPopularStoresUseCase.call(NoParams());
    
    // Use fold to handle Either properly
    final stores = await result.fold(
      (failure) async {
        print('⚠️ Failed to load popular stores: $failure, using fallback');
        // Fallback to getting all stores and returning first 10
        final storeRepository = ref.read(storeRepositoryProvider);
        final storesResult = await storeRepository.getStores();
        return storesResult.fold(
          (failure) {
            print('⚠️ Fallback also failed: $failure');
            return <StoreEntity>[];
          },
          (stores) {
            print('✅ Fallback successful: ${stores.length} stores');
            return stores.take(10).toList();
          },
        );
      },
      (stores) async {
        print('✅ Loaded ${stores.length} popular stores from API');
        return stores;
      },
    );
    
    return stores;
  } catch (e) {
    print('❌ Error in popularStoresProvider: $e');
    // Return empty list instead of throwing, so UI can handle it gracefully
    return <StoreEntity>[];
  }
});
// Flash Deals Provider
final flashDealsProvider = FutureProvider<List<ProductEntity>>((ref) async {
  final storeRepository = ref.read(storeRepositoryProvider);
  final result = await storeRepository.getFlashDeals();
  return result.fold(
    (failure) => throw Exception('Failed to load flash deals'),
    (deals) => deals,
  );
});
