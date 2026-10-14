import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_policy.dart';
import 'policy_event.dart';
import 'policy_state.dart';

/// Drives the policy screen: loads the policy and tracks the chosen cover
/// and sum insured.
class PolicyBloc extends Bloc<PolicyEvent, PolicyState> {
  final GetPolicy _getPolicy;

  PolicyBloc(this._getPolicy) : super(const PolicyState()) {
    on<PolicyRequested>(_onRequested);
    on<PolicyCoverSelected>(_onCoverSelected);
    on<PolicyPlanSelected>(_onPlanSelected);
  }

  Future<void> _onRequested(
    PolicyRequested event,
    Emitter<PolicyState> emit,
  ) async {
    emit(state.copyWith(status: PolicyStatus.loading, clearError: true));
    try {
      final policy = await _getPolicy();
      final cover = policy.coverOptions.first;
      emit(
        PolicyState(
          status: PolicyStatus.loaded,
          policy: policy,
          selectedCover: cover,
          selectedPlan: cover.plans.first,
        ),
      );
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          status: PolicyStatus.failure,
          error: 'Could not load the policy. Please try again.',
        ),
      );
    }
  }

  /// Keeps the chosen sum insured if the new cover offers it; otherwise
  /// falls back to the cover's first plan.
  void _onCoverSelected(PolicyCoverSelected event, Emitter<PolicyState> emit) {
    final policy = state.policy;
    final cover = event.cover;
    if (policy == null || !policy.coverOptions.contains(cover)) return;
    final sumInsured = state.selectedPlan?.sumInsuredMinor;
    final plan = cover.plans.firstWhere(
      (plan) => plan.sumInsuredMinor == sumInsured,
      orElse: () => cover.plans.first,
    );
    emit(state.copyWith(selectedCover: cover, selectedPlan: plan));
  }

  void _onPlanSelected(PolicyPlanSelected event, Emitter<PolicyState> emit) {
    final cover = state.selectedCover;
    if (cover == null || !cover.plans.contains(event.plan)) return;
    emit(state.copyWith(selectedPlan: event.plan));
  }
}
