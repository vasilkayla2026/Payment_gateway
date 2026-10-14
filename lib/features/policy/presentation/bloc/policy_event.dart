import 'package:equatable/equatable.dart';

import '../../domain/entities/policy.dart';

sealed class PolicyEvent extends Equatable {
  const PolicyEvent();

  @override
  List<Object?> get props => [];
}

/// Load the policy (also used to retry after a failure).
class PolicyRequested extends PolicyEvent {
  const PolicyRequested();
}

/// The customer chose who to cover.
class PolicyCoverSelected extends PolicyEvent {
  final CoverOption cover;

  const PolicyCoverSelected(this.cover);

  @override
  List<Object?> get props => [cover];
}

/// The customer chose a sum insured.
class PolicyPlanSelected extends PolicyEvent {
  final PolicyPlan plan;

  const PolicyPlanSelected(this.plan);

  @override
  List<Object?> get props => [plan];
}
