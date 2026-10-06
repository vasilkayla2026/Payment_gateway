import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/checkout/presentation/screens/customer_details_screen.dart';
import '../../features/checkout/presentation/screens/order_success_screen.dart';
import '../../features/checkout/presentation/screens/order_summary_screen.dart';
import '../../features/payment/presentation/bloc/payment_bloc.dart';
import '../../features/product/presentation/bloc/product_bloc.dart';
import '../../features/product/presentation/bloc/product_event.dart';
import '../../features/product/presentation/screens/product_screen.dart';
import '../di/di.dart';

/// Route names. Screens navigate by name, so features never import each
/// other's screens.
abstract final class AppRoutes {
  static const String product = '/';
  static const String customerDetails = '/checkout/details';
  static const String orderSummary = '/checkout/review';
  static const String orderSuccess = '/checkout/success';
}

/// Builds the page for each of [AppRoutes].
abstract final class AppRouter {
  static Route<void> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => switch (settings.name) {
        AppRoutes.customerDetails => const CustomerDetailsScreen(),
        AppRoutes.orderSummary => BlocProvider<PaymentBloc>(
          create: (_) => sl<PaymentBloc>(),
          child: const OrderSummaryScreen(),
        ),
        AppRoutes.orderSuccess => OrderSuccessScreen(
          args: settings.arguments as OrderSuccessArgs?,
        ),
        _ => BlocProvider<ProductBloc>(
          create: (_) => sl<ProductBloc>()..add(const ProductRequested()),
          child: const ProductScreen(),
        ),
      },
    );
  }

  /// Always starts on the product page, even when a web URL points into the
  /// checkout: checkout state lives in memory and would be missing.
  static List<Route<void>> onGenerateInitialRoutes(String initialRoute) => [
    onGenerateRoute(const RouteSettings(name: AppRoutes.product)),
  ];
}
