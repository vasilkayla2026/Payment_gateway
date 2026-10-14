import 'package:get_it/get_it.dart';

import '../../features/payment/data/repositories/payment_repository_impl.dart';
import '../../features/payment/data/services/razorpay_checkout.dart';
import '../../features/payment/domain/repositories/payment_repository.dart';
import '../../features/payment/domain/services/payment_checkout.dart';
import '../../features/payment/domain/usecases/create_payment_order.dart';
import '../../features/payment/presentation/bloc/payment_bloc.dart';
import '../../features/policy/data/datasources/policy_local_data_source.dart';
import '../../features/policy/data/repositories/policy_repository_impl.dart';
import '../../features/policy/domain/repositories/policy_repository.dart';
import '../../features/policy/domain/usecases/get_policy.dart';
import '../../features/policy/presentation/bloc/policy_bloc.dart';
import '../client/api_client.dart';

final GetIt sl = GetIt.instance;

/// Composition root: wires data sources → repositories → use cases → BLoCs.
/// Call once before `runApp`.
Future<void> init() async {
  sl.registerLazySingleton<ApiClient>(() => ApiClient());

  // Policy
  sl.registerLazySingleton<PolicyLocalDataSource>(
    () => const PolicyLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<PolicyRepository>(
    () => PolicyRepositoryImpl(sl<PolicyLocalDataSource>()),
  );
  sl.registerLazySingleton<GetPolicy>(() => GetPolicy(sl<PolicyRepository>()));
  // Factory: the policy screen gets a fresh BLoC.
  sl.registerFactory<PolicyBloc>(() => PolicyBloc(sl<GetPolicy>()));

  // Payment
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<CreatePaymentOrder>(
    () => CreatePaymentOrder(sl<PaymentRepository>()),
  );
  sl.registerLazySingleton<PaymentCheckout>(() => const RazorpayCheckout());
  // Factory: provided with the policy screen, next to its PolicyBloc.
  sl.registerFactory<PaymentBloc>(
    () => PaymentBloc(sl<CreatePaymentOrder>(), sl<PaymentCheckout>()),
  );
}
