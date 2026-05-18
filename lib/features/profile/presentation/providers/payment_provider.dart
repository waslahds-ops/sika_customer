import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sika_customer/features/profile/data/datasources/payment_remote_datasource.dart';
import 'package:sika_customer/features/profile/data/repositories/payment_repository_impl.dart';
import 'package:sika_customer/features/profile/domain/repositories/payment_repository.dart';
import '../../../../features/models/models.dart';
import '../../../../injection_container.dart';

// Data Source Provider
final paymentRemoteDataSourceProvider = Provider<PaymentRemoteDataSource>((
  ref,
) {
  return PaymentRemoteDataSourceImpl(apiService: ref.watch(apiServiceProvider));
});

// Repository Provider
final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepositoryImpl(
    remoteDataSource: ref.watch(paymentRemoteDataSourceProvider),
  );
});

// State Notifier for Payment Methods List
class PaymentMethodsNotifier
    extends StateNotifier<AsyncValue<List<PaymentMethod>>> {
  final PaymentRepository repository;
  final Ref ref;

  PaymentMethodsNotifier(this.repository, this.ref)
    : super(const AsyncValue.loading()) {
    _initializeAndLoad();
  }

  Future<void> _initializeAndLoad() async {
    try {
      // First, restore token from storage
      final authRepository = ref.read(authRepositoryProvider);
      final apiService = ref.read(apiServiceProvider);
      final storedToken = await authRepository.getStoredToken();

      if (storedToken != null && storedToken.isNotEmpty) {
        apiService.setAuthToken(storedToken);
        print(
          '🔐 Token restored from storage: ${storedToken.substring(0, 20)}...',
        );
      } else {
        print('⚠️ No stored token found');
      }

      // Then load payment methods
      await _loadPaymentMethods();
    } catch (e, stackTrace) {
      if (mounted) {
        state = AsyncValue.error(e, stackTrace);
      }
    }
  }

  Future<void> _loadPaymentMethods() async {
    try {
      state = const AsyncValue.loading();
      final result = await repository.getPaymentMethods();

      // Check if notifier is still mounted before updating state
      if (!mounted) return;

      state = result.fold(
        (failure) => AsyncValue.error(failure, StackTrace.current),
        (paymentMethods) => AsyncValue.data(paymentMethods),
      );
    } catch (e, stackTrace) {
      if (mounted) {
        state = AsyncValue.error(e, stackTrace);
      }
    }
  }

  Future<void> addPaymentMethod({
    required String cardNumber,
    required String expiryDate,
    required String cvv,
    required String cardholderName,
  }) async {
    try {
      final result = await repository.storePaymentMethod(
        cardNumber: cardNumber,
        expiryDate: expiryDate,
        cvv: cvv,
        cardholderName: cardholderName,
      );

      if (!mounted) return;

      result.fold(
        (failure) {
          if (mounted) {
            state = AsyncValue.error(failure, StackTrace.current);
          }
        },
        (newPaymentMethod) {
          if (mounted) {
            final currentState = state;
            if (currentState.hasValue) {
              final currentList = currentState.value ?? <PaymentMethod>[];
              final updatedList = <PaymentMethod>[
                ...currentList,
                newPaymentMethod,
              ];
              state = AsyncValue.data(updatedList);
            }
          }
        },
      );
    } catch (e, stackTrace) {
      if (mounted) {
        state = AsyncValue.error(e, stackTrace);
      }
    }
  }

  Future<void> removePaymentMethod(int paymentMethodId) async {
    try {
      final result = await repository.deletePaymentMethod(paymentMethodId);

      if (!mounted) return;

      result.fold(
        (failure) {
          if (mounted) {
            state = AsyncValue.error(failure, StackTrace.current);
          }
        },
        (_) {
          if (mounted) {
            final currentState = state;
            if (currentState.hasValue) {
              final currentList = currentState.value ?? <PaymentMethod>[];
              final updatedList = currentList
                  .where((pm) => pm.paymentMethodId != paymentMethodId)
                  .toList();
              state = AsyncValue.data(updatedList);
            }
          }
        },
      );
    } catch (e, stackTrace) {
      if (mounted) {
        state = AsyncValue.error(e, stackTrace);
      }
    }
  }

  Future<void> refreshPaymentMethods() async {
    await _loadPaymentMethods();
  }
}

// Riverpod State Notifier Provider
final paymentMethodsProvider =
    StateNotifierProvider<
      PaymentMethodsNotifier,
      AsyncValue<List<PaymentMethod>>
    >((ref) {
      final repository = ref.watch(paymentRepositoryProvider);
      return PaymentMethodsNotifier(repository, ref);
    });

// Single Payment Method Provider
final singlePaymentMethodProvider = FutureProvider.family<PaymentMethod, int>((
  ref,
  paymentMethodId,
) async {
  final repository = ref.watch(paymentRepositoryProvider);
  final result = await repository.getPaymentMethod(paymentMethodId);

  return result.fold(
    (failure) => throw Exception(failure.toString()),
    (paymentMethod) => paymentMethod,
  );
});
