import '../entities/policy.dart';
import '../repositories/policy_repository.dart';

/// Loads the policy shown on the home screen.
class GetPolicy {
  final PolicyRepository _repository;

  const GetPolicy(this._repository);

  Future<Policy> call() => _repository.getPolicy();
}
