import 'package:equatable/equatable.dart';

import 'policy.dart';

/// A [Policy] priced for the customer's choice of cover and sum insured:
/// what the checkout sells.
class PolicyQuote extends Equatable {
  final Policy policy;
  final CoverOption cover;

  /// One of [cover]'s plans.
  final PolicyPlan plan;

  const PolicyQuote({
    required this.policy,
    required this.cover,
    required this.plan,
  });

  /// The amount the customer pays, in minor units.
  int get premiumMinor => plan.premiumMinor;

  @override
  List<Object?> get props => [policy, cover, plan];
}
