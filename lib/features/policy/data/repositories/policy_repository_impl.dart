import '../../domain/entities/policy.dart';
import '../../domain/repositories/policy_repository.dart';
import '../datasources/policy_local_data_source.dart';

class PolicyRepositoryImpl implements PolicyRepository {
  final PolicyLocalDataSource _localDataSource;

  const PolicyRepositoryImpl(this._localDataSource);

  @override
  Future<Policy> getPolicy() async =>
      (await _localDataSource.getPolicy()).toEntity();
}
