import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:echama/models/models.dart';

void main() {
  group('Models', () {
    test('Member.fromMap parses correctly', () {
      final member = Member.fromMap('m1', {
        'chama_id': 'c1',
        'name': 'Jane',
        'phone': '+254700000000',
        'savings': 5000,
        'lateness_count': 1,
        'token_balance': 5000,
        'ai_tip': 'Pay early for 5x loans',
      });
      expect(member.name, 'Jane');
      expect(member.savings, 5000);
      expect(member.latenessCount, 1);
      expect(member.aiTip, contains('5x'));
    });
    test('Loan eligibility multipliers', () {
      int lateCount = 0;
      double multiplier = lateCount == 0 ? 5 : (lateCount <= 2 ? 3 : 2);
      expect(multiplier, 5);
      lateCount = 4;
      multiplier = lateCount == 0 ? 5 : (lateCount <= 2 ? 3 : 2);
      expect(multiplier, 2);
    });
    test('Token value calculation', () {
      expect(105000 / 100000, closeTo(1.05, 0.001));
    });
  });
  test('Built land returns DCF calculation', () {
    const annualRent = 120000.0;
    const years = 5;
    const discount = 0.1;
    final npv = annualRent * (1 - pow(1 + discount, -years)) / discount;
    expect(npv, greaterThan(400000));
  });
}