import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BusinessDashboard extends StatefulWidget {
  final Map<String, dynamic> userData;

  const BusinessDashboard({super.key, required this.userData});

  @override
  State<BusinessDashboard> createState() => _BusinessDashboardState();
}

class _BusinessDashboardState extends State<BusinessDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userData['businessName'] ?? 'Business Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const AnalyticsScreen(),
                  transitionsBuilder: (_, a, __, c) =>
                      FadeTransition(opacity: a, child: c),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _toggleExpand,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: _isExpanded ? 200 : 120,
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Business Profile',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Icon(
                              _isExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              size: 30,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text('Owner: ${widget.userData['name']}'),
                        Text('Email: ${widget.userData['email']}'),
                        if (_isExpanded) ...[
                          const SizedBox(height: 15),
                          Text('Address: ${widget.userData['businessAddress']}'),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {},
                            child: const Text('Edit Profile'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _buildDashboardCard(
                  context,
                  Icons.shopping_cart,
                  'Orders',
                  Colors.teal,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OrdersManagementScreen(),
                      ),
                    );
                  },
                ).animate().flip(duration: 500.ms).slideY(begin: 0.2),
                _buildDashboardCard(
                  context,
                  Icons.inventory,
                  'Products',
                  Colors.orange,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProductsManagementScreen(),
                      ),
                    );
                  },
                ).animate().flip(delay: 100.ms, duration: 500.ms).slideY(begin: 0.2),
                _buildDashboardCard(
                  context,
                  Icons.analytics,
                  'Analytics',
                  Colors.purple,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AnalyticsScreen(),
                      ),
                    );
                  },
                ).animate().flip(delay: 200.ms, duration: 500.ms).slideY(begin: 0.2),
                _buildDashboardCard(
                  context,
                  Icons.settings,
                  'Settings',
                  Colors.blue,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SettingsScreen(),
                      ),
                    );
                  },
                ).animate().flip(delay: 300.ms, duration: 500.ms).slideY(begin: 0.2),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Recent Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...List.generate(
              3,
                  (index) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const Icon(Icons.notifications),
                  title: Text('New order #${1000 + index}'),
                  subtitle: const Text('2 items - \$45.20'),
                  trailing: const Icon(Icons.chevron_right),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new product
        },
        child: const Icon(Icons.add),
      ).animate().scale(delay: 500.ms),
    );
  }

  Widget _buildDashboardCard(
      BuildContext context,
      IconData icon,
      String title,
      Color color,
      VoidCallback onTap,
      ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.8),
                color.withOpacity(0.5),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder screens for navigation
class OrdersManagementScreen extends StatelessWidget {
  const OrdersManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders Management')),
      body: const Center(child: Text('Orders Management Content')),
    );
  }
}

class ProductsManagementScreen extends StatelessWidget {
  const ProductsManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products Management')),
      body: const Center(child: Text('Products Management Content')),
    );
  }
}

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: const Center(child: Text('Analytics Content')),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings Content')),
    );
  }
}