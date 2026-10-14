import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/checkout/presentation/screens/order_success_screen.dart';
import '../../features/payment/presentation/bloc/payment_bloc.dart';
import '../../features/policy/presentation/bloc/policy_bloc.dart';
import '../../features/policy/presentation/bloc/policy_event.dart';
import '../../features/policy/domain/entities/policy_quote.dart';
import '../../features/policy/presentation/screens/policy_screen.dart';
import '../di/di.dart';
import '../widgets/no_data_screen.dart';

/// Route names. Screens navigate by name, so features never import each
/// other's screens.
abstract final class AppRoutes {
  static const String policy = '/';

  /// Takes [OrderSuccessArgs].
  static const String orderSuccess = '/checkout/success';
}

/// Route arguments of [AppRoutes.orderSuccess]: the references of a
/// successful payment and the policy it paid for.
class OrderSuccessArgs {
  /// Razorpay's order id, created by the backend.
  final String orderId;

  /// Razorpay's payment id.
  final String transactionId;

  final PolicyQuote quote;

  const OrderSuccessArgs({
    required this.orderId,
    required this.transactionId,
    required this.quote,
  });
}

/// Builds the page for each of [AppRoutes]. Any other name is a sidebar
/// destination without content: a "No data" page titled by the route's
/// `String` argument.
abstract final class AppRouter {
  static Route<void> onGenerateRoute(RouteSettings settings) {
    if (settings.name == AppRoutes.orderSuccess) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) =>
            OrderSuccessScreen(args: settings.arguments as OrderSuccessArgs?),
      );
    }

    // Sidebar destinations swap in place, as in ESS, so the sidebar stays
    // still instead of moving with a page transition.
    return PageRouteBuilder<void>(
      settings: settings,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (_, _, _) => switch (settings.name) {
        AppRoutes.policy => MultiBlocProvider(
          providers: [
            BlocProvider<PolicyBloc>(
              create: (_) => sl<PolicyBloc>()..add(const PolicyRequested()),
            ),
            BlocProvider<PaymentBloc>(create: (_) => sl<PaymentBloc>()),
          ],
          child: const PolicyScreen(),
        ),
        _ => NoDataScreen(title: settings.arguments as String? ?? ''),
      },
    );
  }

  /// Always starts on the policy page, even when a web URL points elsewhere:
  /// the other pages need state that lives in memory.
  static List<Route<void>> onGenerateInitialRoutes(String initialRoute) => [
    onGenerateRoute(const RouteSettings(name: AppRoutes.policy)),
  ];
}
