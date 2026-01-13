import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'payment_page.dart';

/// ===============================
/// CART SERVICE
/// ===============================
class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<Map<String, dynamic>> _cartItems = [];
  List<Map<String, dynamic>> get cartItems => _cartItems;

  final String cartUrl = "http://192.168.18.6/server_shopdhika/cart.php";

  /// Ambil user_id dari SharedPreferences
  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  /// Fetch cart dari server
  Future<void> fetchCart() async {
    final userId = await _getUserId();
    if (userId == null) return;

    try {
      final response =
          await http.get(Uri.parse("$cartUrl?user_id=$userId"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _cartItems.clear();

        if (data['value'] == 1 && data['cart'] != null) {
          _cartItems.addAll(
              List<Map<String, dynamic>>.from(data['cart']));
        }
      }
    } catch (e) {
      debugPrint("Fetch cart error: $e");
    }
  }

  Future<bool> addToCart(String productId) async {
    final userId = await _getUserId();
    print("DEBUG: addToCart userId: $userId, productId: $productId"); // Custom Debug
    if (userId == null) return false;

    try {
      final response = await http.post(
        Uri.parse(cartUrl),
        body: {
          "action": "add",
          "user_id": userId,
          "product_id": productId,
        },
      );
      
      print("DEBUG: addToCart response: ${response.statusCode} - ${response.body}"); // Custom Debug

      if (response.statusCode == 200) {
        // Try decoding to check if it's valid JSON
        try {
           final data = jsonDecode(response.body);
           // If backend returns { "value": 0, "message": "..." } handle it?
           // For now just assume success if no JSON error
        } catch (e) {
          print("CRITICAL SERVER ERROR: Response is not JSON. Likely a PHP Fatal Error.");
          print("Raw Body: ${response.body}");
          return false;
        }

        await fetchCart();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Add to cart error: $e");
      return false;
    }
  }

  /// Remove item
  Future<void> removeFromCart(String productId) async {
    final userId = await _getUserId();
    if (userId == null) return;

    try {
      await http.post(
        Uri.parse(cartUrl),
        body: {
          "action": "remove",
          "user_id": userId,
          "product_id": productId,
        },
      );
      await fetchCart();
    } catch (e) {
      debugPrint("Remove cart error: $e");
    }
  }

  double getTotalPrice() {
    double total = 0;
    for (var item in _cartItems) {
      final price =
          double.tryParse(item['price'].toString()) ?? 0;
      final qty =
          int.tryParse(item['quantity'].toString()) ?? 1;
      total += price * qty;
    }
    return total;
  }
}

/// ===============================
/// CART PAGE UI
/// ===============================
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartService _cartService = CartService();
  bool _loading = true;
  bool _isCheckingOut = false;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    await _cartService.fetchCart();
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  /// Checkout
  Future<void> _checkout() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login first")),
      );
      return;
    }

    setState(() => _isCheckingOut = true);

    try {
      final response = await http.post(
        Uri.parse("http://192.168.18.6/server_shopdhika/checkout.php"),
        body: {
          "user_id": userId,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['value'] == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  PaymentPage(paymentUrl: data['payment_url']),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _isCheckingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart"),
        backgroundColor: Colors.green,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _cartService.cartItems.isEmpty
              ? const Center(child: Text("Your cart is empty"))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _cartService.cartItems.length,
                        itemBuilder: (context, index) {
                          final item =
                              _cartService.cartItems[index];
                          return Card(
                            margin: const EdgeInsets.all(8),
                            child: ListTile(
                              title: Text(item['name']),
                              subtitle: Text(
                                  "Rp ${item['price']} x ${item['quantity']}"),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  await _cartService.removeFromCart(
                                      item['product_id'].toString());
                                  setState(() {});
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Total",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Rp ${_cartService.getTotalPrice().toStringAsFixed(0)}",
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isCheckingOut
                                  ? null
                                  : _checkout,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: _isCheckingOut
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Text(
                                      "Checkout",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white),
                                    ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
    );
  }
}
