import 'package:equatable/equatable.dart';

/// The customer's contact details, entered at checkout and used to prefill
/// the payment gateway.
class CustomerDetails extends Equatable {
  final String fullName;
  final String email;

  /// 10-digit mobile number, digits only.
  final String phone;

  const CustomerDetails({
    required this.fullName,
    required this.email,
    required this.phone,
  });

  @override
  List<Object?> get props => [fullName, email, phone];
}
