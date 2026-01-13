import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'checkout.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<dynamic> cartItems = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _totalPrice = 0;

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  Future<void> _fetchCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Silahkan login untuk melihat keranjang";
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("https://backend-mobile.drenzzz.dev/cart.php"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode({
          "action": "view",
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          cartItems = jsonDecode(response.body);
          _calculateTotal();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Gagal memuat keranjang";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error: $e";
        _isLoading = false;
      });
    }
  }

  void _calculateTotal() {
    int total = 0;
    for (var item in cartItems) {
      int price = int.tryParse(
              item['price'].toString().replaceAll(RegExp(r'[^0-9]'), '')) ??
          0;
      int promo = int.tryParse(
              item['promo'].toString().replaceAll(RegExp(r'[^0-9]'), '')) ??
          0;
      int effectivePrice = (promo > 0) ? promo : price;
      int qty = int.tryParse(item['quantity'].toString()) ?? 0;
      total += effectivePrice * qty;
    }
    setState(() {
      _totalPrice = total;
    });
  }

  Future<void> _updateQuantity(int cartId, int newQty) async {
    if (newQty < 1) return;

    final index = cartItems.indexWhere((item) => item['id'] == cartId);
    if (index == -1) return;

    final oldQty = int.tryParse(cartItems[index]['quantity'].toString()) ?? 1;

    setState(() {
      cartItems[index]['quantity'] = newQty;
      _calculateTotal();
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.post(
        Uri.parse("https://backend-mobile.drenzzz.dev/cart.php"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode({
          "action": "update",
          "cart_id": cartId,
          "quantity": newQty,
        }),
      );

      final data = jsonDecode(response.body);
      if (!data['success']) {
        setState(() {
          cartItems[index]['quantity'] = oldQty;
          _calculateTotal();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Gagal update quantity")),
        );
      }
    } catch (e) {
      setState(() {
        cartItems[index]['quantity'] = oldQty;
        _calculateTotal();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _deleteItem(int cartId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    try {
      final response = await http.post(
        Uri.parse("https://backend-mobile.drenzzz.dev/cart.php"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode({
          "action": "delete",
          "cart_id": cartId,
        }),
      );

      final data = jsonDecode(response.body);
      if (data['success']) {
        _fetchCartItems();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Item berhasil dihapus")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal menghapus item")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _checkout() async {
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Keranjang kosong"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    await Checkout.checkout(
      context,
      onSuccess: () {
        setState(() {
          cartItems = [];
          _totalPrice = 0;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 25,
            color: Colors.white,
          ),
        ),
        title: const Text(
          "Shopping Cart",
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!))
                    : cartItems.isEmpty
                        ? const Center(child: Text("Keranjangmu kosong"))
                        : ListView.builder(
                            padding: const EdgeInsets.all(10),
                            itemCount: cartItems.length,
                            itemBuilder: (context, index) {
                              final item = cartItems[index];
                              int price = int.tryParse(item['price']
                                      .toString()
                                      .replaceAll(RegExp(r'[^0-9]'), '')) ??
                                  0;
                              int promo = int.tryParse(item['promo']
                                      .toString()
                                      .replaceAll(RegExp(r'[^0-9]'), '')) ??
                                  0;
                              bool hasPromo = promo > 0;

                              return Card(
                                elevation: 3,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Image.network(
                                          item['images'],
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stack) {
                                            return const Icon(
                                                Icons.image_not_supported,
                                                color: Colors.grey);
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['name'],
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 5),
                                            Row(
                                              children: [
                                                if (hasPromo) ...[
                                                  Text(
                                                    "Rp $price",
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.red,
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    "Rp $promo",
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ] else ...[
                                                  Text(
                                                    "Rp $price",
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 5),
                                            Row(
                                              children: [
                                                Container(
                                                  width: 30,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.grey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child: IconButton(
                                                    icon: const Icon(
                                                        Icons.remove,
                                                        size: 14),
                                                    onPressed: () {
                                                      int currentQty =
                                                          int.tryParse(item[
                                                                      'quantity']
                                                                  .toString()) ??
                                                              1;
                                                      _updateQuantity(
                                                          item['id'],
                                                          currentQty - 1);
                                                    },
                                                    padding: EdgeInsets.zero,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10),
                                                  child: Text(
                                                    "${item['quantity']}",
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                Container(
                                                  width: 30,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.green),
                                                    color: Colors.green,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child: IconButton(
                                                    icon: const Icon(Icons.add,
                                                        size: 14,
                                                        color: Colors.white),
                                                    onPressed: () {
                                                      int currentQty =
                                                          int.tryParse(item[
                                                                      'quantity']
                                                                  .toString()) ??
                                                              1;
                                                      _updateQuantity(
                                                          item['id'],
                                                          currentQty + 1);
                                                    },
                                                    padding: EdgeInsets.zero,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () =>
                                            _deleteItem(item['id']),
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Price",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "Rp $_totalPrice",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: cartItems.isEmpty ? null : _checkout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.green,
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Checkout",
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
