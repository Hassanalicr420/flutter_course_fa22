import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import ' login_signup_page.dart';
import 'home_page.dart';
import 'business_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _scaleController = AnimationController(
      vsync: this,
      duration: 1500.ms,
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: 1000.ms,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    // Start animations with delays
    Future.delayed(300.ms, () => _scaleController.forward());
    Future.delayed(800.ms, () => _fadeController.forward());

    // Check auth status
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final userType = prefs.getString('userType') ?? 'customer';

    await Future.delayed(3.seconds);

    if (!mounted) return;

    if (isFirstLaunch) {
      Navigator.pushReplacementNamed(context, '/onboarding');
      await prefs.setBool('isFirstLaunch', false);
    } else if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => userType == 'business'
              ? BusinessDashboard(
            userData: {
              'name': prefs.getString('name') ?? 'Business',
              'email': prefs.getString('email') ?? '',
              'businessName': prefs.getString('businessName') ?? '',
            },
          )
              : CustomerHome(
            userData: {
              'name': prefs.getString('name') ?? 'Customer',
              'email': prefs.getString('email') ?? '',
            },
          ),
        ),
      );
    } else {
      Navigator.pushReplacementNamed(context, '/auth');
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.teal.shade800,
              Colors.teal.shade400,
              Colors.teal.shade200,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background elements
            Positioned.fill(
              child: Lottie.asset(
                'assets/lottie/waves.json',
                fit: BoxFit.cover,
              ),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with scale animation
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Lottie.asset(
                        'assets/lottie/shop_icon.json',
                        width: 80,
                        height: 80,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Text with fade animation
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          "ShopNest Local",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 10,
                                color: Colors.black26,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                        ).animate().shimmer(duration: 1500.ms),
                        const SizedBox(height: 10),
                        Text(
                          "Supporting Local Businesses",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 100,
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation(Colors.white),
                            minHeight: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}