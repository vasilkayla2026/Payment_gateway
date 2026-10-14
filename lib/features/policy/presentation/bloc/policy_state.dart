import 'package:equatable/equatable.dart';

import '../../domain/entities/policy.dart';
import '../../domain/entities/policy_quote.dart';

enum PolicyStatus { initial, loading, loaded, failure }

class PolicyState extends Equatable {
  final PolicyStatus status;
  final Policy? policy;
  final CoverOption? selectedCover;

  /// One of [selectedCover]'s plans.
  final PolicyPlan? selectedPlan;
  final String? error;

  const PolicyState({
    this.status = PolicyStatus.initial,
    this.policy,
    this.selectedCover,
    this.selectedPlan,
    this.error,
  });

  /// The customer's current choice, priced; null until the policy has
  /// loaded.
  PolicyQuote? get quote {
    final policy = this.policy;
    final cover = selectedCover;
    final plan = selectedPlan;
    if (policy == null || cover == null || plan == null) return null;
    return PolicyQuote(policy: policy, cover: cover, plan: plan);
  }

  PolicyState copyWith({
    PolicyStatus? status,
    Policy? policy,
    CoverOption? selectedCover,
    PolicyPlan? selectedPlan,
    String? error,
    bool clearError = false,
  }) {
    return PolicyState(
      status: status ?? this.status,
      policy: policy ?? this.policy,
      selectedCover: selectedCover ?? this.selectedCover,
      selectedPlan: selectedPlan ?? this.selectedPlan,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
    status,
    policy,
    selectedCover,
    selectedPlan,
    error,
  ];
}
