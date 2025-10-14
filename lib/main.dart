import 'package:flutter/material.dart';
import 'package:nfc_01/screens/main_screen.dart';
import 'package:nfc_01/screens/login_screen.dart';
import 'package:nfc_01/Models/API.dart';
import 'package:nfc_01/utils/auth.dart';

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
      home: const AuthChecker(), // Kiểm tra trạng thái đăng nhập
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Widget kiểm tra trạng thái đăng nhập khi khởi động app
class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  /// Kiểm tra xem user đã đăng nhập chưa
  Future<void> _checkLoginStatus() async {
    // Đợi một chút để hiển thị splash screen
    await Future.delayed(const Duration(seconds: 1));
    
    if (!mounted) return;

    // Kiểm tra trạng thái đăng nhập
    final isLoggedIn = await Auth.isLoggedIn();
    
    if (!mounted) return;

    // Điều hướng dựa trên trạng thái đăng nhập
    if (isLoggedIn) {
      // Đã đăng nhập -> vào MainScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      // Chưa đăng nhập -> vào LoginScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Màn hình splash đơn giản khi đang kiểm tra
    return Scaffold(
      backgroundColor: const Color(0xFFFFDAC1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo hoặc icon app
            const Icon(
              Icons.nfc,
              size: 100,
              color: Color.fromARGB(255, 160, 95, 41),
            ),
            const SizedBox(height: 20),
            const Text(
              'NFC App',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 160, 95, 41),
              ),
            ),
            const SizedBox(height: 40),
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Color.fromARGB(255, 160, 95, 41),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
