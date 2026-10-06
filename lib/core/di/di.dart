import 'package:get_it/get_it.dart';

import '../../features/checkout/domain/usecases/calculate_price_breakdown.dart';
import '../../features/checkout/presentation/bloc/checkout_bloc.dart';
import '../../features/payment/data/repositories/payment_repository_impl.dart';
import '../../features/payment/domain/repositories/payment_repository.dart';
import '../../features/payment/domain/usecases/create_order_id.dart';
import '../../features/payment/presentation/bloc/payment_bloc.dart';
import '../../features/product/data/datasources/product_local_data_source.dart';
import '../../features/product/data/repositories/product_repository_impl.dart';
import '../../features/product/domain/repositories/product_repository.dart';
import '../../features/product/domain/usecases/get_product.dart';
import '../../features/product/presentation/bloc/product_bloc.dart';
import '../client/api_client.dart';
import '../config/app_config.dart';

final GetIt sl = GetIt.instance;

/// Composition root: wires data sources → repositories → use cases → BLoCs.
/// Call once before `runApp`.
Future<void> init() async {
  sl.registerLazySingleton<ApiClient>(() => ApiClient());

  // Product
  sl.registerLazySingleton<ProductLocalDataSource>(
    () => const ProductLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(sl<ProductLocalDataSource>()),
  );
  sl.registerLazySingleton<GetProduct>(
    () => GetProduct(sl<ProductRepository>()),
  );
  // Factory: the product screen gets a fresh BLoC.
  sl.registerFactory<ProductBloc>(() => ProductBloc(sl<GetProduct>()));

  // Payment
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<CreateOrderId>(
    () => CreateOrderId(sl<PaymentRepository>()),
  );
  // Factory: each visit to the review screen gets a fresh BLoC.
  sl.registerFactory<PaymentBloc>(() => PaymentBloc(sl<CreateOrderId>()));

  // Checkout
  sl.registerLazySingleton<CalculatePriceBreakdown>(
    () => const CalculatePriceBreakdown(
      deliveryFeeMinor: AppConfig.deliveryFeeMinor,
      freeDeliveryThresholdMinor: AppConfig.freeDeliveryThresholdMinor,
    ),
  );
  // Factory: created once by ShopApp and shared by every checkout screen.
  sl.registerFactory<CheckoutBloc>(
    () => CheckoutBloc(sl<CalculatePriceBreakdown>()),
  );
}
