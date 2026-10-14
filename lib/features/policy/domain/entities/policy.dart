import 'package:equatable/equatable.dart';

/// One level of cover under a [CoverOption]. Amounts are integer minor units
/// (paise).
class PolicyPlan extends Equatable {
  /// The most the insurer pays out over one policy term; on a family
  /// floater, shared by everyone covered.
  final int sumInsuredMinor;

  /// Price of one policy term, inclusive of taxes.
  final int premiumMinor;

  const PolicyPlan({required this.sumInsuredMinor, required this.premiumMinor});

  @override
  List<Object?> get props => [sumInsuredMinor, premiumMinor];
}

/// Who a [Policy] covers, e.g. one person or a family, with the plans on
/// offer for that cover.
class CoverOption extends Equatable {
  final String id;

  /// E.g. "Individual" or "Family Floater".
  final String name;

  /// One line on who is covered.
  final String description;

  /// Never empty, in ascending order of sum insured.
  final List<PolicyPlan> plans;

  const CoverOption({
    required this.id,
    required this.name,
    required this.description,
    required this.plans,
  });

  @override
  List<Object?> get props => [id, name, description, plans];
}

/// The insurance policy on sale.
class Policy extends Equatable {
  final String id;
  final String name;

  /// The insurance company that issues the policy.
  final String insurer;

  /// Line of insurance, e.g. "Health Insurance".
  final String category;

  /// How long the policy runs once issued.
  final int termMonths;

  /// Never empty. The first option and its first plan are the defaults.
  final List<CoverOption> coverOptions;

  /// What the policy pays for.
  final List<String> inclusions;

  /// What the policy does not pay for.
  final List<String> exclusions;

  const Policy({
    required this.id,
    required this.name,
    required this.insurer,
    required this.category,
    required this.termMonths,
    required this.coverOptions,
    required this.inclusions,
    required this.exclusions,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    insurer,
    category,
    termMonths,
    coverOptions,
    inclusions,
    exclusions,
  ];
}
