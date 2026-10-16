import 'package:flutter_test/flutter_test.dart';
import 'package:payment_gateway/core/utils/date_formatter.dart';
import 'package:payment_gateway/core/utils/money_formatter.dart';
import 'package:payment_gateway/core/utils/period_formatter.dart';

void main() {
  test('formatMoney shows paise', () {
    expect(formatMoney(824000), '₹8,240.00');
    expect(formatMoney(824050), '₹8,240.50');
  });

  test('formatMoneyWhole shows whole rupees with Indian digit grouping', () {
    expect(formatMoneyWhole(50000000), '₹5,00,000');
    expect(formatMoneyWhole(250000000), '₹25,00,000');
  });

  test('formatMonths uses years when the months divide evenly', () {
    expect(formatMonths(12), '1 year');
    expect(formatMonths(36), '3 years');
    expect(formatMonths(1), '1 month');
    expect(formatMonths(18), '18 months');
  });

  test('formatDateTime shows the day, month, year and 12-hour time', () {
    expect(
      formatDateTime(DateTime(2026, 10, 16, 14, 38)),
      '16 Oct 2026, 2:38 PM',
    );
    expect(formatDateTime(DateTime(2026, 1, 5, 9, 5)), '5 Jan 2026, 9:05 AM');
  });

  test('formatDateTime shows UTC moments in local time', () {
    final moment = DateTime.utc(2026, 10, 16, 9, 8);

    expect(formatDateTime(moment), formatDateTime(moment.toLocal()));
  });
}
