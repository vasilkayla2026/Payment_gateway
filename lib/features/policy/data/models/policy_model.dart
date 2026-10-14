import '../../domain/entities/policy.dart';

/// A policy as delivered by a data source (API-shaped JSON).
class PolicyModel {
  final String id;
  final String name;
  final String insurer;
  final String category;
  final int termMonths;
  final List<CoverOptionModel> coverOptions;
  final List<String> inclusions;
  final List<String> exclusions;

  const PolicyModel({
    required this.id,
    required this.name,
    required this.insurer,
    required this.category,
    required this.termMonths,
    required this.coverOptions,
    required this.inclusions,
    required this.exclusions,
  });

  factory PolicyModel.fromJson(Map<String, dynamic> json) {
    return PolicyModel(
      id: json['id'] as String,
      name: json['name'] as String,
      insurer: json['insurer'] as String,
      category: json['category'] as String,
      termMonths: json['termMonths'] as int,
      coverOptions: (json['coverOptions'] as List)
          .map(
            (option) =>
                CoverOptionModel.fromJson(option as Map<String, dynamic>),
          )
          .toList(),
      inclusions: (json['inclusions'] as List? ?? const []).cast<String>(),
      exclusions: (json['exclusions'] as List? ?? const []).cast<String>(),
    );
  }

  /// Throws a [FormatException] if the policy has no cover to choose.
  Policy toEntity() {
    if (coverOptions.isEmpty) {
      throw FormatException('Policy $id has no cover options');
    }
    return Policy(
      id: id,
      name: name,
      insurer: insurer,
      category: category,
      termMonths: termMonths,
      coverOptions: coverOptions.map((option) => option.toEntity()).toList(),
      inclusions: inclusions,
      exclusions: exclusions,
    );
  }
}

/// A cover option as delivered by a data source.
class CoverOptionModel {
  final String id;
  final String name;
  final String description;
  final List<PolicyPlanModel> plans;

  const CoverOptionModel({
    required this.id,
    required this.name,
    required this.description,
    required this.plans,
  });

  factory CoverOptionModel.fromJson(Map<String, dynamic> json) {
    return CoverOptionModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      plans: (json['plans'] as List)
          .map((plan) => PolicyPlanModel.fromJson(plan as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Orders the plans by sum insured. Throws a [FormatException] if there
  /// are none.
  CoverOption toEntity() {
    if (plans.isEmpty) {
      throw FormatException('Cover option $id has no plans');
    }
    return CoverOption(
      id: id,
      name: name,
      description: description,
      plans: plans.map((plan) => plan.toEntity()).toList()
        ..sort((a, b) => a.sumInsuredMinor.compareTo(b.sumInsuredMinor)),
    );
  }
}

/// A plan as delivered by a data source. Amounts are in paise.
class PolicyPlanModel {
  final int sumInsured;
  final int premium;

  const PolicyPlanModel({required this.sumInsured, required this.premium});

  factory PolicyPlanModel.fromJson(Map<String, dynamic> json) {
    return PolicyPlanModel(
      sumInsured: json['sumInsured'] as int,
      premium: json['premium'] as int,
    );
  }

  PolicyPlan toEntity() =>
      PolicyPlan(sumInsuredMinor: sumInsured, premiumMinor: premium);
}
