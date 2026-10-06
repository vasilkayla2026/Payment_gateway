import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/bottom_action_bar.dart';
import '../../../../core/widgets/product_image_placeholder.dart';
import '../../../../core/widgets/responsive_center.dart';
import '../../../checkout/domain/entities/order_item.dart';
import '../../../checkout/presentation/bloc/checkout_bloc.dart';
import '../../../checkout/presentation/bloc/checkout_event.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../widgets/color_selector.dart';
import '../widgets/product_highlights.dart';
import '../widgets/product_price.dart';
import '../widgets/quantity_selector.dart';

/// Home screen: the product with its colour and quantity pickers and the
/// "Buy now" button that starts the checkout.
class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        final selection = state.status == ProductStatus.loaded
            ? state.selection
            : null;

        return Scaffold(
          appBar: AppBar(title: const Text(AppConfig.storeName)),
          body: switch (state.status) {
            ProductStatus.failure => _ProductFailure(
              message: state.error ?? 'Could not load the product.',
            ),
            _ when selection != null => _ProductContent(
              selection: selection,
              canIncrementQuantity: state.canIncrementQuantity,
              canDecrementQuantity: state.canDecrementQuantity,
            ),
            _ => const Center(child: CircularProgressIndicator()),
          },
          bottomNavigationBar: selection == null
              ? null
              : _BuyNowBar(subtotalMinor: selection.totalMinor),
        );
      },
    );
  }
}

class _ProductFailure extends StatelessWidget {
  const _ProductFailure({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppLayout.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () =>
                  context.read<ProductBloc>().add(const ProductRequested()),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Image beside the details on wide screens, above them on narrow ones.
class _ProductContent extends StatelessWidget {
  const _ProductContent({
    required this.selection,
    required this.canIncrementQuantity,
    required this.canDecrementQuantity,
  });

  final OrderItem selection;
  final bool canIncrementQuantity;
  final bool canDecrementQuantity;

  @override
  Widget build(BuildContext context) {
    final image = ProductImagePlaceholder(
      color: Color(selection.color.argb),
      semanticLabel: '${selection.product.name}, ${selection.color.name}',
    );
    final details = _ProductDetails(
      selection: selection,
      canIncrementQuantity: canIncrementQuantity,
      canDecrementQuantity: canDecrementQuantity,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppLayout.pagePadding),
      child: ResponsiveCenter(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= AppLayout.wideBreakpoint) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: AspectRatio(aspectRatio: 1, child: image)),
                  const SizedBox(width: 32),
                  Expanded(child: details),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(aspectRatio: 4 / 3, child: image),
                const SizedBox(height: 24),
                details,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProductDetails extends StatelessWidget {
  const _ProductDetails({
    required this.selection,
    required this.canIncrementQuantity,
    required this.canDecrementQuantity,
  });

  final OrderItem selection;
  final bool canIncrementQuantity;
  final bool canDecrementQuantity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final product = selection.product;
    final bloc = context.read<ProductBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 24,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Semantics(
              header: true,
              child: Text(
                product.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              product.tagline,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        ProductPrice(product: product),
        _Section(
          title: 'Colour: ',
          titleValue: selection.color.name,
          child: ColorSelector(
            colors: product.colors,
            selected: selection.color,
            onSelected: (color) => bloc.add(ProductColorSelected(color)),
          ),
        ),
        _Section(
          title: 'Quantity',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              QuantitySelector(
                quantity: selection.quantity,
                onIncrement: canIncrementQuantity
                    ? () => bloc.add(const ProductQuantityIncremented())
                    : null,
                onDecrement: canDecrementQuantity
                    ? () => bloc.add(const ProductQuantityDecremented())
                    : null,
              ),
              if (!canIncrementQuantity)
                Text(
                  'Maximum ${product.maxQuantityPerOrder} per order',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        if (product.highlights.isNotEmpty)
          _Section(
            title: 'Highlights',
            child: ProductHighlights(highlights: product.highlights),
          ),
        _Section(
          title: 'About this product',
          child: Text(
            product.description,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ),
      ],
    );
  }
}

/// A headed block of the details column.
class _Section extends StatelessWidget {
  const _Section({required this.title, this.titleValue, required this.child});

  final String title;

  /// Emphasised text appended to [title], e.g. the chosen colour's name.
  final String? titleValue;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final titleValue = this.titleValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Semantics(
          header: true,
          child: Text.rich(
            TextSpan(
              text: title,
              children: [
                if (titleValue != null)
                  TextSpan(
                    text: titleValue,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
              ],
            ),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        child,
      ],
    );
  }
}

/// Subtotal and "Buy now"; delivery is added on the review screen.
class _BuyNowBar extends StatelessWidget {
  const _BuyNowBar({required this.subtotalMinor});

  final int subtotalMinor;

  void _buyNow(BuildContext context) {
    final item = context.read<ProductBloc>().state.selection;
    if (item == null) return;
    context.read<CheckoutBloc>().add(CheckoutStarted(item));
    Navigator.of(context).pushNamed(AppRoutes.customerDetails);
  }

  @override
  Widget build(BuildContext context) {
    return BottomActionBar(
      label: 'Subtotal',
      value: formatMoney(subtotalMinor),
      action: FilledButton.icon(
        onPressed: () => _buyNow(context),
        icon: const Icon(Icons.shopping_bag_outlined),
        label: const Text('Buy now'),
      ),
    );
  }
}
