import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/config/app_config.dart';
import 'core/di/di.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/checkout/presentation/bloc/checkout_bloc.dart';

/// Root widget. The [CheckoutBloc] sits above the navigator because the
/// checkout spans several routes.
class ShopApp extends StatelessWidget {
  const ShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CheckoutBloc>(
      create: (_) => sl<CheckoutBloc>(),
      child: MaterialApp(
        title: AppConfig.storeName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        initialRoute: AppRoutes.product,
        onGenerateRoute: AppRouter.onGenerateRoute,
        onGenerateInitialRoutes: AppRouter.onGenerateInitialRoutes,
      ),
    );
  }
}
