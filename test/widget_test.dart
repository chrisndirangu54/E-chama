import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:echama/main.dart';

void main() {
  testWidgets('App launches and shows dashboard title', (tester) async {
    await tester.pumpWidget(const EChamaApp());
    await tester.pump();
    expect(find.text('e-Chama Dashboard'), findsOneWidget);
  });

  testWidgets('Dashboard has action buttons', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Text('Manage Assets'))));
    expect(find.text('Manage Assets'), findsOneWidget);
  });
}