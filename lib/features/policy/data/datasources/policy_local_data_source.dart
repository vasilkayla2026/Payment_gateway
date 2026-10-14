import '../models/policy_model.dart';

/// Policy data bundled with the app. Add a remote data source next to this
/// one when the policy moves to a backend.
abstract interface class PolicyLocalDataSource {
  Future<PolicyModel> getPolicy();
}

class PolicyLocalDataSourceImpl implements PolicyLocalDataSource {
  const PolicyLocalDataSourceImpl();

  @override
  Future<PolicyModel> getPolicy() async =>
      PolicyModel.fromJson(_samplePolicyJson);
}

/// Shaped like an API response so swapping in a backend is mechanical.
/// Amounts are in paise; premiums are for one term and include taxes.
const Map<String, dynamic> _samplePolicyJson = {
  'id': 'complete-health-cover',
  'name': 'Complete Health Cover',
  'insurer': 'Sample General Insurance',
  'category': 'Health Insurance',
  'termMonths': 12,
  'coverOptions': [
    {
      'id': 'individual',
      'name': 'Individual',
      'description': 'Covers one adult.',
      'plans': [
        {'sumInsured': 30000000, 'premium': 396000},
        {'sumInsured': 50000000, 'premium': 528000},
        {'sumInsured': 100000000, 'premium': 745000},
        {'sumInsured': 250000000, 'premium': 1089000},
      ],
    },
    {
      'id': 'family-floater',
      'name': 'Family Floater',
      'description':
          'One sum insured shared by you, your spouse and up to two '
          'children.',
      'plans': [
        {'sumInsured': 30000000, 'premium': 618000},
        {'sumInsured': 50000000, 'premium': 824000},
        {'sumInsured': 100000000, 'premium': 1162000},
        {'sumInsured': 250000000, 'premium': 1698000},
      ],
    },
  ],
  'inclusions': [
    'In-patient hospitalisation',
    '24/7 accident cover',
    'Day-care treatments',
    'Ambulance expenses',
  ],
  'exclusions': [
    'Pre-existing conditions (first 2 years)',
    'Cosmetic and dental procedures',
    'Self-inflicted injuries',
    'Experimental treatments',
  ],
};
