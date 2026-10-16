import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_payment_history.dart';
import 'payment_history_event.dart';
import 'payment_history_state.dart';

/// Drives the payment history page: loads the orders, and reloads them on
/// refresh, e.g. to see a pending payment that the webhook has since
/// confirmed. Provided with the page.
class PaymentHistoryBloc
    extends Bloc<PaymentHistoryEvent, PaymentHistoryState> {
  final GetPaymentHistory _getPaymentHistory;

  static const String errorMessage =
      'Could not load the payment history. Please try again.';

  PaymentHistoryBloc(this._getPaymentHistory)
    : super(const PaymentHistoryState()) {
    on<PaymentHistoryRequested>(_onRequested);
  }

  Future<void> _onRequested(
    PaymentHistoryRequested event,
    Emitter<PaymentHistoryState> emit,
  ) async {
    if (state.isLoading) return;

    emit(
      PaymentHistoryState(
        status: PaymentHistoryStatus.loading,
        records: state.records,
      ),
    );
    try {
      final records = await _getPaymentHistory();
      emit(
        PaymentHistoryState(
          status: PaymentHistoryStatus.loaded,
          records: records,
        ),
      );
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        const PaymentHistoryState(
          status: PaymentHistoryStatus.failure,
          error: errorMessage,
        ),
      );
    }
  }
}
