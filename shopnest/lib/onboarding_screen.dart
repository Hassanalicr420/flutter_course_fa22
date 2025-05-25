import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:lottie/lottie.dart';
import ' login_signup_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  final List<OnboardingItem> _onboardingItems = [
    OnboardingItem(
      title: "Local Businesses Near You",
      description: "Discover and support shops in your neighborhood",
      lottieAsset: 'assets/lottie/store_animation.json',
      color: Colors.teal,
    ),
    OnboardingItem(
      title: "Fast 2-Hour Delivery",
      description: "Get what you need delivered in just 2 hours",
      lottieAsset: 'assets/lottie/delivery_animation.json',
      color: Colors.orange,
    ),
    OnboardingItem(
      title: "Secure Payments",
      description: "100% secure payment options including COD",
      lottieAsset: 'assets/lottie/payment_animation.json',
      color: Colors.green,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _navigateToAuth() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginSignupPage(),
        transitionsBuilder: (_, a, __, c) =>
            FadeTransition(opacity: a, child: c),
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _onboardingItems.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
                _controller.reset();
                _controller.forward();
              });
            },
            itemBuilder: (context, index) {
              final item = _onboardingItems[index];
              return OnboardingPage(
                item: item,
                scaleAnimation: _scaleAnimation,
                opacityAnimation: _opacityAnimation,
              );
            },
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _onboardingItems.length,
                        (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? _onboardingItems[index].color
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: ElevatedButton(
                    onPressed: _navigateToAuth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _onboardingItems[_currentPage].color,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(200, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 5,
                      shadowColor: _onboardingItems[_currentPage]
                          .color
                          .withOpacity(0.3),
                    ),
                    child: Text(
                      _currentPage == _onboardingItems.length - 1
                          ? 'Get Started'
                          : 'Next',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                FadeTransition(
                  opacity: _opacityAnimation,
                  child: TextButton(
                    onPressed: _navigateToAuth,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: _onboardingItems[_currentPage].color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final OnboardingItem item;
  final Animation<double> scaleAnimation;
  final Animation<double> opacityAnimation;

  const OnboardingPage({
    super.key,
    required this.item,
    required this.scaleAnimation,
    required this.opacityAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: item.color.withOpacity(0.1),
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: scaleAnimation,
            child: Container(
              height: 250,
              padding: const EdgeInsets.all(30),
              child: Lottie.asset(
                item.lottieAsset,
                fit: BoxFit.contain,
                repeat: true,
              ),
            ),
          ),
          const SizedBox(height: 40),
          FadeTransition(
            opacity: opacityAnimation,
            child: Text(
              item.title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: item.color,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          FadeTransition(
            opacity: opacityAnimation,
            child: Text(
              item.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final String lottieAsset;
  final Color color;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.lottieAsset,
    required this.color,
  });
}