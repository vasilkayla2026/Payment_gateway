import '../entities/policy.dart';

/// Source of the policy on sale.
abstract interface class PolicyRepository {
  Future<Policy> getPolicy();
}
