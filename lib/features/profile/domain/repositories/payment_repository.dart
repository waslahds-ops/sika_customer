import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../features/models/models.dart';

abstract class PaymentRepository {
  Future<Either<Failure, PaymentMethod>> storePaymentMethod({
    required String cardNumber,
    required String expiryDate,
    required String cvv,
    required String cardholderName,
  });

  Future<Either<Failure, List<PaymentMethod>>> getPaymentMethods();
  Future<Either<Failure, PaymentMethod>> getPaymentMethod(int paymentMethodId);
  Future<Either<Failure, void>> deletePaymentMethod(int paymentMethodId);
  Future<Either<Failure, PaymentMethod>> verifyPaymentMethod(
    int paymentMethodId,
  );
}
