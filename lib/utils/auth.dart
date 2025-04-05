class Auth {
// A simple mock method to simulate logging in

  static Future<bool> login(String username, String password) async {
// Simulating an API call delay (e.g., network request)

    await Future.delayed(const Duration(seconds: 2));

// Mock authentication logic

    if (username == 'a' && password == 'a') {
      return true; // Successful login
    } else {
      return false; // Login failed
    }
  }
}
