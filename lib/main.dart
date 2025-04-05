import 'package:flutter/material.dart';
import 'package:nfc_01/screens/main_screen.dart';
import 'package:nfc_01/Models/API.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo API và kết nối MongoDB
  final api = Testapi();
  try {
    await api.fetchWordData();
  } catch (e) {
    print('Error initializing MongoDB: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NFC App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
