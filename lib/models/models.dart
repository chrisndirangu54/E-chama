/// Models for e-Chama
class Member {
  final String id;
  final String chamaId;
  final String name;
  final String phone;
  final double savings;
  final int latenessCount;
  final double tokenBalance;
  final String? aiTip;

  Member({
    required this.id,
    required this.chamaId,
    required this.name,
    required this.phone,
    this.savings = 0,
    this.latenessCount = 0,
    this.tokenBalance = 0,
    this.aiTip,
  });

  factory Member.fromMap(String id, Map<String, dynamic> map) {
    return Member(
      id: id,
      chamaId: map['chama_id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      savings: (map['savings'] ?? 0).toDouble(),
      latenessCount: map['lateness_count'] ?? 0,
      tokenBalance: (map['token_balance'] ?? 0).toDouble(),
      aiTip: map['ai_tip'],
    );
  }
}

class Chama {
  final String id;
  final String name;
  final Map<String, dynamic> settings;
  final double totalAssets;
  final String? tokenAddress;

  Chama({
    required this.id,
    required this.name,
    this.settings = const {},
    this.totalAssets = 0,
    this.tokenAddress,
  });
}

class LoanRequest {
  final String id;
  final String memberId;
  final double amount;
  final double maxEligible;
  final String status;
  final List<Map<String, dynamic>> votes;

  LoanRequest({
    required this.id,
    required this.memberId,
    required this.amount,
    required this.maxEligible,
    this.status = 'pending',
    this.votes = const [],
  });
}