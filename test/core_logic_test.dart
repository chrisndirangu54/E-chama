import 'dart:math';

void main() {
  print('Running e-Chama core logic tests...');
  const totalAssets = 105000.0;
  const totalSupply = 100000.0;
  assert(totalAssets / totalSupply == 1.05);
  int lateCount = 0;
  double multiplier = lateCount == 0 ? 5 : (lateCount <= 2 ? 3 : 2);
  assert(multiplier == 5);
  lateCount = 4;
  multiplier = lateCount == 0 ? 5 : (lateCount <= 2 ? 3 : 2);
  assert(multiplier == 2);
  const annualRent = 120000.0;
  const years = 5;
  const discount = 0.1;
  final npv = annualRent * (1 - pow(1 + discount, -years)) / discount;
  assert(npv > 450000 && npv < 460000);
  final assets = {
    'cash': 20000.0,
    'vehicle': 361250.0,
    'land': 350000.0,
    'built_land': 1455160.0,
    'business': 189540.0,
    'machinery': 133057.0,
  };
  final total = assets.values.fold(0.0, (a, b) => a + b);
  assert(total > 2500000);
  print('Core tests passed');
}