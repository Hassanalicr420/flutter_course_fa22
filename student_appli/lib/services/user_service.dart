import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserService {
  static Future<User?> loginUser(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('user_email');
    final savedName = prefs.getString('user_name');

    // Check if it's the test account
    if (email == 'test@example.com' && password == 'password123') {
      final user = User(
        id: '1',
        email: email,
        name: 'Test User',
      );
      
      // Save user data
      await prefs.setString('user_email', email);
      await prefs.setString('user_name', user.name);
      
      return user;
    }
    
    // Check if it's a registered user
    if (savedEmail == email && password.length >= 6) {
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: savedName ?? 'User',
      );
      return user;
    }

    return null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    await prefs.remove('user_name');
  }
} 