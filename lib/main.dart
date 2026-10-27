import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/dashboard.dart';
import 'screens/assets.dart';
import 'screens/trading.dart';
import 'screens/voting.dart';
import 'screens/chat.dart';
import 'screens/insurance.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const EChamaApp());
}

class EChamaApp extends StatelessWidget {
  const EChamaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'e-Chama',
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      initialRoute: '/',
      routes: {
        '/': (context) => const DashboardScreen(),
        '/assets': (context) => const AssetScreen(chamaId: 'demo'),
        '/trading': (context) => const TradingScreen(chamaId: 'demo'),
        '/voting': (context) => const VotingScreen(chamaId: 'demo'),
        '/chat': (context) => const ChatScreen(chamaId: 'demo'),
        '/insurance': (context) => const ChamaInsuranceScreen(chamaId: 'demo'),
      },
    );
  }
}