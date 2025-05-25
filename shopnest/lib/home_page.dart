import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class CustomerHome extends StatefulWidget {
  final Map<String, dynamic> userData;

  const CustomerHome({super.key, required this.userData});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentIndex = 0;
  int _bottomNavIndex = 0;
  final PageController _featuredController = PageController();

  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.shopping_basket, 'name': 'Grocery'},
    {'icon': Icons.restaurant, 'name': 'Food'},
    {'icon': Icons.local_pharmacy, 'name': 'Medicine'},
    {'icon': Icons.shopping_cart, 'name': 'General'},
    {'icon': Icons.local_florist, 'name': 'Flowers'},
  ];

  final List<Map<String, dynamic>> _featuredShops = [
    {
      'name': 'Fresh Mart',
      'category': 'Grocery',
      'rating': 4.8,
      'deliveryTime': '30-45 min',
      'image': 'assets/images/grocery.jpg',
    },
    {
      'name': 'Spice Kitchen',
      'category': 'Restaurant',
      'rating': 4.5,
      'deliveryTime': '45-60 min',
      'image': 'assets/images/restaurant.jpg',
    },
    {
      'name': 'MediCare',
      'category': 'Pharmacy',
      'rating': 4.7,
      'deliveryTime': '20-30 min',
      'image': 'assets/images/pharmacy.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: 1000.ms,
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _featuredController.dispose();
    super.dispose();
  }

  Widget _buildCategoryItem(IconData icon, String name, int index) {
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: 300.ms,
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _currentIndex == index ? Colors.teal : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          boxShadow: _currentIndex == index
              ? [
            BoxShadow(
              color: Colors.teal.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            )
          ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30,
                color: _currentIndex == index ? Colors.white : Colors.teal),
            const SizedBox(height: 8),
            Text(name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _currentIndex == index ? Colors.white : Colors.black,
                )),
          ],
        ),
      ).animate().scale(delay: (index * 100).ms),
    );
  }

  Widget _buildFeaturedShop(Map<String, dynamic> shop, int index) {
    return Container(
      width: 200,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.asset(
              shop['image'],
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[200],
                height: 120,
                child: Icon(Icons.store, size: 50, color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(shop['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(shop['category'],
                    style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    Text(shop['rating'].toString()),
                    const SizedBox(width: 10),
                    Icon(Icons.access_time, color: Colors.grey[500], size: 18),
                    Text(shop['deliveryTime'],
                        style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, ${widget.userData['name']}',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16),
                Text('Current Location',
                    style: GoogleFonts.poppins(fontSize: 12)),
                const Icon(Icons.arrow_drop_down, size: 16),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(
              onPressed: () {}, icon: const Icon(Icons.notifications_none)),
        ],
      ),
      body: IndexedStack(
        index: _bottomNavIndex,
        children: [
          // Home Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Promo Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.teal.shade800, Colors.teal.shade400]),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Fast Delivery in 2 Hours',
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('Order from local shops near you',
                                style: TextStyle(color: Colors.white.withOpacity(0.9))),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.teal,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                              ),
                              child: const Text('Order Now'),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.delivery_dining,
                          color: Colors.white, size: 80),
                    ],
                  ),
                ).animate().fadeIn().slideX(begin: -0.1),

                const SizedBox(height: 30),

                // Categories
                Text('Categories',
                    style: GoogleFonts.poppins(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) =>
                        _buildCategoryItem(
                            _categories[index]['icon'],
                            _categories[index]['name'],
                            index),
                  ),
                ),

                const SizedBox(height: 30),

                // Featured Shops
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Featured Shops',
                        style: GoogleFonts.poppins(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () {},
                      child: const Text('See All', style: TextStyle(color: Colors.teal)),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                SizedBox(
                  height: 220,
                  child: PageView.builder(
                    controller: _featuredController,
                    itemCount: _featuredShops.length,
                    itemBuilder: (context, index) =>
                        _buildFeaturedShop(_featuredShops[index], index),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: SmoothPageIndicator(
                    controller: _featuredController,
                    count: _featuredShops.length,
                    effect: const WormEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      activeDotColor: Colors.teal,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Special Offers
                Text('Special Offers',
                    style: GoogleFonts.poppins(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/offer.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.teal,
                              borderRadius: BorderRadius.circular(4)),
                          child: const Text('50% OFF',
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 8),
                        Text('On your first order',
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text('Use code: LOCAL50',
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ).animate().fadeIn().slideY(begin: 0.1),
              ],
            ),
          ),

          // Other Tabs (Placeholders)
          Center(child: Text('Search Page',
              style: GoogleFonts.poppins(fontSize: 24))),
          Center(child: Text('Orders Page',
              style: GoogleFonts.poppins(fontSize: 24))),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  child: Text(widget.userData['name'][0],
                      style: const TextStyle(fontSize: 40)),
                ),
                const SizedBox(height: 20),
                Text(widget.userData['name'],
                    style: GoogleFonts.poppins(fontSize: 24)),
                Text(widget.userData['email'],
                    style: const TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: (index) => setState(() => _bottomNavIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}