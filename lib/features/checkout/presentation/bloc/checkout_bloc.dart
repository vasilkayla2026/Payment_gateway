import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/calculate_price_breakdown.dart';
import 'checkout_event.dart';
import 'checkout_state.dart';

/// Holds what is being bought and the customer's contact details. Lives above
/// the navigator because the checkout spans several screens.
class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final CalculatePriceBreakdown _calculatePriceBreakdown;

  CheckoutBloc(this._calculatePriceBreakdown) : super(const CheckoutState()) {
    on<CheckoutStarted>(_onStarted);
    on<CheckoutCustomerDetailsSubmitted>(_onCustomerDetailsSubmitted);
  }

  void _onStarted(CheckoutStarted event, Emitter<CheckoutState> emit) {
    emit(
      CheckoutState(
        item: event.item,
        pricing: _calculatePriceBreakdown(event.item),
        customer: state.customer,
      ),
    );
  }

  void _onCustomerDetailsSubmitted(
    CheckoutCustomerDetailsSubmitted event,
    Emitter<CheckoutState> emit,
  ) {
    emit(state.copyWith(customer: event.customer));
  }
}
