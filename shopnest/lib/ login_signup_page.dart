import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopnest/database_helper.dart';
import 'package:shopnest/home_page.dart';
import 'package:shopnest/business_dashboard.dart';

class LoginSignupPage extends StatefulWidget {
  const LoginSignupPage({super.key});

  @override
  State<LoginSignupPage> createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage>
    with SingleTickerProviderStateMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();

  bool _isLogin = true;
  bool _isBusiness = false;
  bool _isPasswordVisible = false;
  bool _biometricAvailable = false;
  bool _isAuthenticating = false;
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _translateAnimation;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _businessAddressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _translateAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
    _checkBiometrics();
    _checkSavedCredentials();
  }

  Future<void> _checkBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isAvailable = await _localAuth.isDeviceSupported();
      setState(() {
        _biometricAvailable = canCheck && isAvailable;
      });
    } catch (e) {
      debugPrint('Biometric check error: $e');
    }
  }

  Future<void> _checkSavedCredentials() async {
    try {
      final email = await _secureStorage.read(key: 'saved_email');
      final password = await _secureStorage.read(key: 'saved_password');

      if (email != null && password != null) {
        _emailController.text = email;
        _passwordController.text = password;
      }
    } catch (e) {
      debugPrint('Secure storage error: $e');
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    if (!_biometricAvailable) return;

    setState(() => _isAuthenticating = true);
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your account',
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        _handleAuth();
      }
    } catch (e) {
      debugPrint('Authentication error: $e');
    } finally {
      setState(() => _isAuthenticating = false);
    }
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();

    if (_isLogin) {
      final user = await _dbHelper.authenticateUser(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null) {
        // Save credentials securely if biometrics available
        if (_biometricAvailable) {
          await _secureStorage.write(
            key: 'saved_email',
            value: _emailController.text.trim(),
          );
          await _secureStorage.write(
            key: 'saved_password',
            value: _passwordController.text.trim(),
          );
        }

        // Save auth state
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userType', user['userType'] ?? 'customer');
        await prefs.setString('name', user['name'] ?? '');
        await prefs.setString('email', user['email'] ?? '');
        if (user['businessName'] != null) {
          await prefs.setString('businessName', user['businessName']!);
        }

        // Navigate with animation
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => user['userType'] == 'business'
                ? BusinessDashboard(userData: user)
                : CustomerHome(userData: user),
            transitionsBuilder: (_, a, __, c) =>
                ScaleTransition(scale: a, child: c),
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid credentials')),
        );
      }
    } else {
      // Registration logic
      final user = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'password': _passwordController.text.trim(),
        'userType': _isBusiness ? 'business' : 'customer',
        'businessName': _isBusiness ? _businessNameController.text.trim() : null,
        'businessAddress': _isBusiness ? _businessAddressController.text.trim() : null,
      };

      try {
        await _dbHelper.registerUser(user);

        // Save auth state
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userType', user['userType'] ?? 'customer');
        await prefs.setString('name', user['name'] ?? '');
        await prefs.setString('email', user['email'] ?? '');
        if (user['businessName'] != null) {
          await prefs.setString('businessName', user['businessName']!);
        }

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => _isBusiness
                ? BusinessDashboard(userData: user)
                : CustomerHome(userData: user),
            transitionsBuilder: (_, a, __, c) =>
                FadeTransition(opacity: a, child: c),
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return FadeTransition(
            opacity: _opacityAnimation,
            child: Transform.translate(
              offset: Offset(0, _translateAnimation.value),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        Text(
                          _isLogin ? 'Welcome Back!' : 'Create Account',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (!_isLogin) ...[
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (value) =>
                            value!.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 15),
                        ],
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) =>
                          value!.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 15),
                        if (!_isLogin) ...[
                          TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              labelText: 'Phone',
                              prefixIcon: Icon(Icons.phone),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value) =>
                            value!.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 15),
                        ],
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(_isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () => setState(
                                      () => _isPasswordVisible = !_isPasswordVisible),
                            ),
                          ),
                          obscureText: !_isPasswordVisible,
                          validator: (value) =>
                          value!.length < 6 ? 'Minimum 6 characters' : null,
                        ),
                        if (!_isLogin) ...[
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              const Text('Register as:'),
                              const SizedBox(width: 20),
                              ChoiceChip(
                                label: const Text('Customer'),
                                selected: !_isBusiness,
                                onSelected: (val) =>
                                    setState(() => _isBusiness = !val),
                              ),
                              const SizedBox(width: 10),
                              ChoiceChip(
                                label: const Text('Business'),
                                selected: _isBusiness,
                                onSelected: (val) =>
                                    setState(() => _isBusiness = val),
                              ),
                            ],
                          ),
                          if (_isBusiness) ...[
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: _businessNameController,
                              decoration: const InputDecoration(
                                labelText: 'Business Name',
                                prefixIcon: Icon(Icons.business),
                              ),
                              validator: (value) =>
                              value!.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: _businessAddressController,
                              decoration: const InputDecoration(
                                labelText: 'Business Address',
                                prefixIcon: Icon(Icons.location_on),
                              ),
                              validator: (value) =>
                              value!.isEmpty ? 'Required' : null,
                            ),
                          ],
                        ],
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _handleAuth,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                          child: _isAuthenticating
                              ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                              : Text(_isLogin ? 'Login' : 'Register'),
                        ),
                        if (_isLogin && _biometricAvailable) ...[
                          const SizedBox(height: 15),
                          OutlinedButton(
                            onPressed: _authenticateWithBiometrics,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              side: const BorderSide(color: Colors.teal),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.fingerprint),
                                SizedBox(width: 10),
                                Text('Use Biometrics'),
                              ],
                            ),
                          ),
                        ],
                        TextButton(
                          onPressed: () => setState(() => _isLogin = !_isLogin),
                          child: Text(
                            _isLogin
                                ? "Don't have an account? Register"
                                : "Already have an account? Login",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _businessNameController.dispose();
    _businessAddressController.dispose();
    super.dispose();
  }
}