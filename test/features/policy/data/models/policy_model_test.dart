import 'package:flutter_test/flutter_test.dart';
import 'package:payment_gateway/features/policy/data/datasources/policy_local_data_source.dart';
import 'package:payment_gateway/features/policy/data/models/policy_model.dart';

Map<String, dynamic> _policyJson({required List<Object> coverOptions}) => {
  'id': 'p1',
  'name': 'Health Cover',
  'insurer': 'Test Insurance',
  'category': 'Health Insurance',
  'termMonths': 12,
  'coverOptions': coverOptions,
};

Map<String, dynamic> _coverJson({required List<Object> plans}) => {
  'id': 'individual',
  'name': 'Individual',
  'description': '',
  'plans': plans,
};

void main() {
  test('the bundled policy has plans under every cover', () async {
    final policy = (await const PolicyLocalDataSourceImpl().getPolicy())
        .toEntity();

    expect(policy.coverOptions, isNotEmpty);
    for (final cover in policy.coverOptions) {
      expect(cover.plans, isNotEmpty);
    }
  });

  test('orders plans by sum insured', () {
    final policy = PolicyModel.fromJson(
      _policyJson(
        coverOptions: [
          _coverJson(
            plans: [
              {'sumInsured': 100000000, 'premium': 745000},
              {'sumInsured': 30000000, 'premium': 396000},
            ],
          ),
        ],
      ),
    ).toEntity();

    expect(
      policy.coverOptions.single.plans.map((plan) => plan.sumInsuredMinor),
      [30000000, 100000000],
    );
  });

  test('missing inclusions and exclusions become empty lists', () {
    final policy = PolicyModel.fromJson(
      _policyJson(
        coverOptions: [
          _coverJson(
            plans: [
              {'sumInsured': 30000000, 'premium': 396000},
            ],
          ),
        ],
      ),
    ).toEntity();

    expect(policy.inclusions, isEmpty);
    expect(policy.exclusions, isEmpty);
  });

  test('rejects a policy without cover options', () {
    final model = PolicyModel.fromJson(_policyJson(coverOptions: []));

    expect(model.toEntity, throwsFormatException);
  });

  test('rejects a cover option without plans', () {
    final model = PolicyModel.fromJson(
      _policyJson(coverOptions: [_coverJson(plans: [])]),
    );

    expect(model.toEntity, throwsFormatException);
  });
}
