import 'package:flutter/material.dart';

// 1) SnackItem Model Class
class SnackItem {
  final String name;
  final double price;
  int quantity;

  SnackItem({required this.name, required this.price, this.quantity = 1});
}

// 2) Mock list of snacks
final List<SnackItem> allSnacks = [
  SnackItem(name: 'Chocolate Bar', price: 1.50),
  SnackItem(name: 'Potato Chips', price: 2.00),
  SnackItem(name: 'Gummy Bears', price: 1.25),
  SnackItem(name: 'Pretzels', price: 1.75),
];

void main() {
  runApp(MyApp());
}

class GradientBackground extends StatelessWidget {
  final Widget child;
  const GradientBackground({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.yellowAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Order My Snacks',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(
          color: Colors.blue.shade800,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellow.shade700,
            foregroundColor: Colors.black,
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/snacks': (context) => SnackListScreen(),
        '/cart': (context) => CartScreen(),
        '/checkout': (context) => CheckoutScreen(),
        '/confirmation': (context) => ConfirmationScreen(),
      },
    );
  }
}

// Home Screen
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order My Snacks'),
        centerTitle: true,
      ),
      body: GradientBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('You tapped the image!')),
                  );
                },
                child: Container(
                  margin: EdgeInsets.all(16.0),
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.fastfood, size: 64, color: Colors.black87),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                child: Text('Start Ordering'),
                onPressed: () {
                  Navigator.pushNamed(context, '/snacks');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Snack List Screen
class SnackListScreen extends StatefulWidget {
  @override
  _SnackListScreenState createState() => _SnackListScreenState();
}

class _SnackListScreenState extends State<SnackListScreen> {
  List<SnackItem> cart = [];

  void addItemToCart(SnackItem item) {
    setState(() {
      // Check if the item already exists in the cart
      var existingItem = cart.firstWhere(
            (snack) => snack.name == item.name,
        orElse: () => SnackItem(name: '', price: 0.0, quantity: 0),
      );

      if (existingItem.name.isEmpty) {
        cart.add(item); // Add new item
      } else {
        existingItem.quantity++; // Increase quantity if already exists
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Your Snacks'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, '/cart', arguments: cart);
            },
          ),
        ],
      ),
      body: GradientBackground(
        child: ListView.builder(
          itemCount: allSnacks.length,
          itemBuilder: (context, index) {
            final snack = allSnacks[index];
            return Card(
              color: Colors.white.withOpacity(0.8),
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: ListTile(
                title: Text(
                  snack.name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('\$${snack.price.toStringAsFixed(2)}'),
                trailing: ElevatedButton(
                  child: Text('Add'),
                  onPressed: () {
                    addItemToCart(snack);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${snack.name} added to cart')),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Cart Screen
class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = ModalRoute.of(context)!.settings.arguments as List<SnackItem>;
    double totalPrice = cart.fold(0, (sum, item) => sum + (item.price * item.quantity));

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
        centerTitle: true,
      ),
      body: GradientBackground(
        child: cart.isEmpty
            ? Center(
          child: Text(
            'Your cart is empty.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cart.length,
                itemBuilder: (context, index) {
                  final snack = cart[index];
                  return Card(
                    color: Colors.white.withOpacity(0.8),
                    child: ListTile(
                      title: Text(snack.name),
                      subtitle: Text(
                          '\$${snack.price.toStringAsFixed(2)} x ${snack.quantity}'),
                    ),
                  );
                },
              ),
            ),
            Divider(color: Colors.black, thickness: 1),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Total: \$${totalPrice.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Center(
              child: ElevatedButton(
                child: Text('Proceed to Checkout'),
                onPressed: () {
                  Navigator.pushNamed(context, '/checkout');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Checkout Screen
class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _address = '';
  String _phone = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
        centerTitle: true,
      ),
      body: GradientBackground(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle('Full Name'),
                TextFormField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    hintText: 'Enter your name',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                  onSaved: (value) => _name = value!.trim(),
                ),
                SizedBox(height: 16),
                _buildTitle('Address'),
                TextFormField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    hintText: 'Enter your address',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Address is required';
                    }
                    return null;
                  },
                  onSaved: (value) => _address = value!.trim(),
                ),
                SizedBox(height: 16),
                _buildTitle('Phone Number'),
                TextFormField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    hintText: 'Enter phone number',
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Phone number is required';
                    }
                    if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                      return 'Enter only numbers';
                    }
                    return null;
                  },
                  onSaved: (value) => _phone = value!.trim(),
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    child: Text('Continue'),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        Navigator.pushNamed(
                          context,
                          '/confirmation',
                          arguments: {
                            'name': _name,
                            'address': _address,
                            'phone': _phone,
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// Confirmation Screen
class ConfirmationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    final name = args['name'] ?? '';
    final address = args['address'] ?? '';
    final phone = args['phone'] ?? '';

    final cart = ModalRoute.of(context)!.settings.arguments as List<SnackItem>;

    double totalPrice = cart.fold(0, (sum, item) => sum + (item.price * item.quantity));

    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm Your Order'),
        centerTitle: true,
      ),
      body: GradientBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: $name', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Address: $address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Phone: $phone', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: cart.length,
                itemBuilder: (context, index) {
                  final snack = cart[index];
                  return Card(
                    color: Colors.white.withOpacity(0.8),
                    child: ListTile(
                      title: Text(snack.name),
                      subtitle: Text('\$${snack.price.toStringAsFixed(2)} x ${snack.quantity}'),
                    ),
                  );
                },
              ),
            ),
            Text(
              'Total: \$${totalPrice.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                child: Text('Place Order'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Order Placed!'),
                      content: Text('Thank you, $name. Your snacks are on the way!'),
                      actions: [
                        TextButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.popUntil(context, ModalRoute.withName('/'));
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
