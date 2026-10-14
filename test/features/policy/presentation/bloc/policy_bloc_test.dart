import 'package:flutter_test/flutter_test.dart';
import 'package:payment_gateway/features/policy/domain/entities/policy.dart';
import 'package:payment_gateway/features/policy/domain/entities/policy_quote.dart';
import 'package:payment_gateway/features/policy/domain/repositories/policy_repository.dart';
import 'package:payment_gateway/features/policy/domain/usecases/get_policy.dart';
import 'package:payment_gateway/features/policy/presentation/bloc/policy_bloc.dart';
import 'package:payment_gateway/features/policy/presentation/bloc/policy_event.dart';
import 'package:payment_gateway/features/policy/presentation/bloc/policy_state.dart';

const _individual3L = PolicyPlan(
  sumInsuredMinor: 30000000,
  premiumMinor: 396000,
);
const _individual5L = PolicyPlan(
  sumInsuredMinor: 50000000,
  premiumMinor: 528000,
);
const _family5L = PolicyPlan(sumInsuredMinor: 50000000, premiumMinor: 824000);
const _family10L = PolicyPlan(
  sumInsuredMinor: 100000000,
  premiumMinor: 1162000,
);

const _individual = CoverOption(
  id: 'individual',
  name: 'Individual',
  description: '',
  plans: [_individual3L, _individual5L],
);

/// Offers no ₹3,00,000 plan.
const _family = CoverOption(
  id: 'family-floater',
  name: 'Family Floater',
  description: '',
  plans: [_family5L, _family10L],
);

const _policy = Policy(
  id: 'p1',
  name: 'Health Cover',
  insurer: 'Test Insurance',
  category: 'Health Insurance',
  termMonths: 12,
  coverOptions: [_individual, _family],
  inclusions: [],
  exclusions: [],
);

class _FakePolicyRepository implements PolicyRepository {
  _FakePolicyRepository(this._getPolicy);

  final Future<Policy> Function() _getPolicy;

  @override
  Future<Policy> getPolicy() => _getPolicy();
}

PolicyBloc _bloc(Future<Policy> Function() getPolicy) {
  final bloc = PolicyBloc(GetPolicy(_FakePolicyRepository(getPolicy)));
  addTearDown(bloc.close);
  return bloc;
}

/// A bloc that has loaded [_policy].
Future<PolicyBloc> _loadedBloc() async {
  final bloc = _bloc(() async => _policy)..add(const PolicyRequested());
  await expectLater(
    bloc.stream,
    emitsThrough(
      isA<PolicyState>().having((s) => s.status, 'status', PolicyStatus.loaded),
    ),
  );
  return bloc;
}

/// Lets the bloc handle the events added so far.
Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  test('selects the first cover and its first plan once loaded', () async {
    final bloc = await _loadedBloc();

    expect(
      bloc.state.quote,
      const PolicyQuote(
        policy: _policy,
        cover: _individual,
        plan: _individual3L,
      ),
    );
  });

  test(
    'switching cover keeps the sum insured if the cover offers it',
    () async {
      final bloc = await _loadedBloc()
        ..add(const PolicyPlanSelected(_individual5L))
        ..add(const PolicyCoverSelected(_family));
      await _settle();

      expect(bloc.state.selectedCover, _family);
      expect(bloc.state.selectedPlan, _family5L);
    },
  );

  test(
    "switching cover otherwise falls back to the cover's first plan",
    () async {
      final bloc = await _loadedBloc()
        ..add(const PolicyCoverSelected(_family));
      await _settle();

      expect(bloc.state.selectedCover, _family);
      expect(bloc.state.selectedPlan, _family5L);
    },
  );

  test('ignores a plan the selected cover does not offer', () async {
    final bloc = await _loadedBloc()
      ..add(const PolicyPlanSelected(_family10L));
    await _settle();

    expect(bloc.state.selectedPlan, _individual3L);
  });

  test('a failed load reports an error that a retry clears', () async {
    var fail = true;
    final bloc = _bloc(() async {
      if (fail) throw Exception('offline');
      return _policy;
    })..add(const PolicyRequested());
    await _settle();

    expect(bloc.state.status, PolicyStatus.failure);
    expect(bloc.state.error, isNotNull);
    expect(bloc.state.quote, isNull);

    fail = false;
    bloc.add(const PolicyRequested());
    await _settle();

    expect(bloc.state.status, PolicyStatus.loaded);
    expect(bloc.state.error, isNull);
  });
}
