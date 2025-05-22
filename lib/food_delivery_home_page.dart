import 'package:flutter/material.dart';
import 'login_page.dart';

class FoodDeliveryHomePage extends StatefulWidget {
  final String userEmail;

  const FoodDeliveryHomePage({super.key, required this.userEmail});

  @override
  State<FoodDeliveryHomePage> createState() => _FoodDeliveryHomePageState();
}

class _FoodDeliveryHomePageState extends State<FoodDeliveryHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final Map<String, List<Map<String, dynamic>>> categorizedFoodItems = {
    'Veg': [
      {'name': 'Veg Pizza', 'price': 9.99,  'rating': 4.5},
      {'name': 'Salad', 'price': 4.99,  'rating': 4.0},
      {'name': 'Paneer Tikka', 'price': 7.99,  'rating': 4.6},
      {'name': 'Veg Biryani', 'price': 8.50,  'rating': 4.2},
      {'name': 'Mixed Veg Curry', 'price': 6.99,  'rating': 4.1},
    ],
    'Non-Veg': [
      {'name': 'Chicken Burger', 'price': 6.99,  'rating': 4.3},
      {'name': 'Grilled Fish', 'price': 11.99,  'rating': 4.7},
      {'name': 'Chicken Curry', 'price': 10.50,  'rating': 4.4},
      {'name': 'Mutton Biryani', 'price': 13.99,  'rating': 4.5},
      {'name': 'Fish Fry', 'price': 12.99,   'rating': 4.6},
    ],
    'Desserts': [
      {'name': 'Chocolate Cake', 'price': 5.50,  'rating': 4.8},
      {'name': 'Ice Cream', 'price': 3.99,  'rating': 4.7},
      {'name': 'Gulab Jamun', 'price': 4.50, 'rating': 4.6},
      {'name': 'Fruit Salad', 'price': 4.00,  'rating': 4.3},
      {'name': 'Cupcake', 'price': 3.75,  'rating': 4.4},
    ],
  };

  final Map<String, int> cart = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categorizedFoodItems.keys.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void addToCart(String foodName) {
    setState(() {
      cart.update(foodName, (qty) => qty + 1, ifAbsent: () => 1);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$foodName added to cart')),
    );
  }

  void navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(
          cart: cart,
          foodItems: categorizedFoodItems.values.expand((list) => list).toList(),
          onCartUpdated: (updatedCart) {
            setState(() {
              cart.clear();
              cart.addAll(updatedCart);
            });
          },
        ),
      ),
    );
  }

  Widget buildRatingStars(double rating) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool halfStar = (rating - fullStars) >= 0.5;

    for (int i = 0; i < fullStars; i++) {
      stars.add(const Icon(Icons.star, color: Colors.amber, size: 16));
    }
    if (halfStar) {
      stars.add(const Icon(Icons.star_half, color: Colors.amber, size: 16));
    }
    while (stars.length < 5) {
      stars.add(const Icon(Icons.star_border, color: Colors.amber, size: 16));
    }
    return Row(children: stars);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${widget.userEmail}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: categorizedFoodItems.keys.map((category) => Tab(text: category)).toList(),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Profile') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile clicked')),
                );
              } else if (value == 'Cart') {
                navigateToCart();
              } else if (value == 'Logout') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'Profile', child: Text('Profile')),
              PopupMenuItem(value: 'Cart', child: Text('Cart')),
              PopupMenuItem(value: 'Logout', child: Text('Logout')),
            ],
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.orange[100],
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            child: const Text(
              'Estimated delivery in 20 to 30 min',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepOrange),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: categorizedFoodItems.keys.map((category) {
                final foodList = categorizedFoodItems[category]!;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: foodList.length,
                  itemBuilder: (context, index) {
                    final food = foodList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.fastfood, color: Colors.deepOrange),
                        title: Text(food['name']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('\$${food['price'].toStringAsFixed(2)}'),
                            const SizedBox(height: 4),
                            buildRatingStars(food['rating']),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => addToCart(food['name']),
                          child: const Text('Add to Cart'),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class CartPage extends StatefulWidget {
  final Map<String, int> cart;
  final List<Map<String, dynamic>> foodItems;
  final Function(Map<String, int>) onCartUpdated;

  const CartPage({
    super.key,
    required this.cart,
    required this.foodItems,
    required this.onCartUpdated,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Map<String, int> cart;

  @override
  void initState() {
    super.initState();
    cart = Map.from(widget.cart);
  }

  double getTotalPrice() {
    double total = 0;
    for (var entry in cart.entries) {
      final food = widget.foodItems.firstWhere((f) => f['name'] == entry.key);
      total += food['price'] * entry.value;
    }
    return total;
  }

  void removeFromCart(String foodName) {
    setState(() {
      if (cart.containsKey(foodName)) {
        if (cart[foodName]! > 1) {
          cart[foodName] = cart[foodName]! - 1;
        } else {
          cart.remove(foodName);
        }
      }
    });
    widget.onCartUpdated(cart);
  }

  void proceedToCheckout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(totalAmount: getTotalPrice()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (cart.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cart')),
        body: const Center(child: Text('Your cart is empty')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: cart.entries.map((entry) {
                final food = widget.foodItems.firstWhere((f) => f['name'] == entry.key);
                return ListTile(
                  leading: const Icon(Icons.shopping_cart, color: Colors.green),
                  title: Text(food['name']),
                  subtitle: Text('Quantity: ${entry.value}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle),
                    onPressed: () => removeFromCart(entry.key),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Total: \$${getTotalPrice().toStringAsFixed(2)}', style: const TextStyle(fontSize: 18)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              onPressed: proceedToCheckout,
              child: const Text('Checkout'),
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentPage extends StatefulWidget {
  final double totalAmount;

  const PaymentPage({super.key, required this.totalAmount});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String selectedPaymentMethod = 'UPI';
  String selectedUpiApp = 'PhonePe';

  final List<String> upiApps = ['PhonePe', 'Google Pay', 'Paytm'];

  void confirmPayment() {
    String paymentDetails;
    if (selectedPaymentMethod == 'UPI') {
      paymentDetails = 'Paid \$${widget.totalAmount.toStringAsFixed(2)} using $selectedUpiApp (UPI)';
    } else {
      paymentDetails = 'Cash payment of \$${widget.totalAmount.toStringAsFixed(2)} on delivery';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Confirmation'),
        content: Text(paymentDetails),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  Widget upiDropdown() {
    return DropdownButton<String>(
      value: selectedUpiApp,
      items: upiApps.map((app) => DropdownMenuItem(value: app, child: Text(app))).toList(),
      onChanged: (val) {
        if (val != null) {
          setState(() {
            selectedUpiApp = val;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Amount: \$${widget.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            const Text('Select Payment Method:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ListTile(
              title: const Text('UPI'),
              leading: Radio<String>(
                value: 'UPI',
                groupValue: selectedPaymentMethod,
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      selectedPaymentMethod = val;
                    });
                  }
                },
              ),
            ),
            if (selectedPaymentMethod == 'UPI')
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: upiDropdown(),
              ),
            ListTile(
              title: const Text('Cash on Delivery'),
              leading: Radio<String>(
                value: 'Cash',
                groupValue: selectedPaymentMethod,
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      selectedPaymentMethod = val;
                    });
                  }
                },
              ),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: confirmPayment,
                child: const Text('Confirm Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
