/// Insurance Policy Model
library;

class InsurancePolicy {
  final String id;
  final String insurer;
  final String name;
  final String type;
  final String category;
  final double premiumMonthly;
  final double premiumYearly;
  final double coverageAmount;
  final double claimSettlementRatio;
  final List<String> benefits;
  final List<String> exclusions;
  final List<String> riders;
  final String suitableFor;
  final String notIdealFor;
  final int readabilityScore;
  final int riskScore;
  final String iconUrl;

  const InsurancePolicy({
    required this.id,
    required this.insurer,
    required this.name,
    required this.type,
    required this.category,
    required this.premiumMonthly,
    required this.premiumYearly,
    required this.coverageAmount,
    required this.claimSettlementRatio,
    required this.benefits,
    required this.exclusions,
    required this.riders,
    required this.suitableFor,
    required this.notIdealFor,
    required this.readabilityScore,
    required this.riskScore,
    required this.iconUrl,
  });

  factory InsurancePolicy.fromJson(Map<String, dynamic> json) {
    return InsurancePolicy(
      id: json['id'] ?? '',
      insurer: json['insurer'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      category: json['category'] ?? '',
      premiumMonthly: (json['premiumMonthly'] ?? 0).toDouble(),
      premiumYearly: (json['premiumYearly'] ?? 0).toDouble(),
      coverageAmount: (json['coverageAmount'] ?? 0).toDouble(),
      claimSettlementRatio: (json['claimSettlementRatio'] ?? 0).toDouble(),
      benefits: List<String>.from(json['benefits'] ?? []),
      exclusions: List<String>.from(json['exclusions'] ?? []),
      riders: List<String>.from(json['riders'] ?? []),
      suitableFor: json['suitableFor'] ?? '',
      notIdealFor: json['notIdealFor'] ?? '',
      readabilityScore: json['readabilityScore'] ?? 5,
      riskScore: json['riskScore'] ?? 5,
      iconUrl: json['iconUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'insurer': insurer,
      'name': name,
      'type': type,
      'category': category,
      'premiumMonthly': premiumMonthly,
      'premiumYearly': premiumYearly,
      'coverageAmount': coverageAmount,
      'claimSettlementRatio': claimSettlementRatio,
      'benefits': benefits,
      'exclusions': exclusions,
      'riders': riders,
      'suitableFor': suitableFor,
      'notIdealFor': notIdealFor,
      'readabilityScore': readabilityScore,
      'riskScore': riskScore,
      'iconUrl': iconUrl,
    };
  }
}

// Sample policy data for demo
class SamplePolicies {
  static const List<Map<String, dynamic>> policies = [
    {
      'id': 'POL001',
      'insurer': 'LIC',
      'name': 'Jeevan Anand',
      'type': 'Life Insurance',
      'category': 'Individual',
      'premiumMonthly': 2500,
      'premiumYearly': 28000,
      'coverageAmount': 1000000,
      'claimSettlementRatio': 98.5,
      'benefits': ['Death Benefit', 'Maturity Benefit', 'Bonus'],
      'exclusions': ['Suicide within 1 year'],
      'riders': ['Accidental Death', 'Critical Illness'],
      'suitableFor': 'Young professionals, First-time buyers',
      'notIdealFor': 'Senior citizens above 55',
      'readabilityScore': 7,
      'riskScore': 3,
      'iconUrl': '',
    },
    {
      'id': 'POL002',
      'insurer': 'HDFC Life',
      'name': 'Click2Protect Plus',
      'type': 'Term Insurance',
      'category': 'Individual',
      'premiumMonthly': 1200,
      'premiumYearly': 13500,
      'coverageAmount': 5000000,
      'claimSettlementRatio': 99.1,
      'benefits': ['High Coverage', 'Online Discount', 'Flexible Term'],
      'exclusions': ['Pre-existing illness not disclosed'],
      'riders': ['Waiver of Premium', 'Income Benefit'],
      'suitableFor': 'Budget-conscious families, High coverage seekers',
      'notIdealFor': 'Those seeking maturity benefits',
      'readabilityScore': 8,
      'riskScore': 2,
      'iconUrl': '',
    },
    {
      'id': 'POL003',
      'insurer': 'ICICI Prudential',
      'name': 'iProtect Smart',
      'type': 'Term Insurance',
      'category': 'Family',
      'premiumMonthly': 1500,
      'premiumYearly': 17000,
      'coverageAmount': 7500000,
      'claimSettlementRatio': 97.8,
      'benefits': ['Return of Premium Option', 'Life Stage Benefit'],
      'exclusions': ['Self-inflicted injuries'],
      'riders': ['Terminal Illness', 'Disability Cover'],
      'suitableFor': 'Growing families, Long-term planners',
      'notIdealFor': 'Single individuals without dependents',
      'readabilityScore': 6,
      'riskScore': 2,
      'iconUrl': '',
    },
    {
      'id': 'POL004',
      'insurer': 'Star Health',
      'name': 'Family Health Optima',
      'type': 'Health Insurance',
      'category': 'Family',
      'premiumMonthly': 1800,
      'premiumYearly': 20000,
      'coverageAmount': 1000000,
      'claimSettlementRatio': 96.5,
      'benefits': ['No Claim Bonus', 'Day Care Procedures', 'Pre & Post Hospitalization'],
      'exclusions': ['Cosmetic surgery', 'Dental treatments'],
      'riders': ['Maternity Cover', 'OPD Cover'],
      'suitableFor': 'Families with children, Senior parents',
      'notIdealFor': 'Individuals preferring individual plans',
      'readabilityScore': 7,
      'riskScore': 4,
      'iconUrl': '',
    },
    {
      'id': 'POL005',
      'insurer': 'Max Bupa',
      'name': 'Health Companion',
      'type': 'Health Insurance',
      'category': 'Senior Citizen',
      'premiumMonthly': 3500,
      'premiumYearly': 40000,
      'coverageAmount': 500000,
      'claimSettlementRatio': 95.2,
      'benefits': ['No Medical Check-up', 'Lifetime Renewal', 'Ayush Treatment'],
      'exclusions': ['Pre-existing diseases (2 year wait)'],
      'riders': ['Personal Accident', 'Hospital Cash'],
      'suitableFor': 'Senior citizens 60+, Retired individuals',
      'notIdealFor': 'Young individuals',
      'readabilityScore': 6,
      'riskScore': 5,
      'iconUrl': '',
    },
  ];
}
