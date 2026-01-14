import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'homepage.dart';
import 'checkout.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List cartItems = [];
  bool loading = true;
  int userId = 0;

  final String cartUrl =
      "https://backend-mobile.mazdick.biz.id/cart.php";

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt("user_id") ?? 0;
    });
    fetchCart();
  }

  Future<void> fetchCart() async {
    try {
      final res = await http.post(
        Uri.parse(cartUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "action": "view",
          "user_id": userId,
        }),
      );

      final data = jsonDecode(res.body);
      setState(() {
        cartItems = data is List ? data : [];
        loading = false;
      });
    } catch (_) {
      setState(() => loading = false);
    }
  }

  Future<void> addQty(int productId) async {
    await http.post(
      Uri.parse(cartUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "action": "add",
        "user_id": userId,
        "product_id": productId,
      }),
    );
    fetchCart();
  }

  Future<void> decreaseQty(int cartId) async {
    await http.post(
      Uri.parse(cartUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "action": "decrease",
        "cart_id": cartId,
      }),
    );
    fetchCart();
  }

  Future<void> deleteItem(int cartId) async {
    await http.post(
      Uri.parse(cartUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "action": "delete",
        "cart_id": cartId,
      }),
    );
    fetchCart();
  }

  int get totalPrice {
    int total = 0;
    for (var item in cartItems) {
      final price = int.tryParse(item['price'].toString()) ?? 0;
      final qty = int.tryParse(item['quantity'].toString()) ?? 1;
      total += price * qty;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade400,
        title: const Text("Keranjang Belanja", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? const Center(child: Text("Keranjang kosong"))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, i) {
                          final item = cartItems[i];
                          final cartId =
                              int.tryParse(item['cart_id'].toString()) ?? 0;
                          final productId =
                              int.tryParse(item['product_id'].toString()) ?? 0;
                          final qty =
                              int.tryParse(item['quantity'].toString()) ?? 1;

                          return ListTile(
                            leading: Image.network(
                              item['images'],
                              width: 60,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.image),
                            ),
                            title: Text(item['name']),
                            subtitle:
                                Text("Rp ${item['price']} x $qty"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () => decreaseQty(cartId),
                                ),
                                Text(qty.toString()),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () => addQty(productId),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => deleteItem(cartId),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            "Total: Rp $totalPrice",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: cartItems.isEmpty
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CheckoutPage(
                                            totalPrice: totalPrice,
                                            cartItems: cartItems,
                                          ),
                                        ),
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Checkout',
                                style: TextStyle(
                                  fontSize: 18,
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
