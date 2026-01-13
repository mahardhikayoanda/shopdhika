import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopdhika/cart.dart';

class ProductDetailPage extends StatelessWidget {
  final Map<String, dynamic> item;

  const ProductDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green.shade400,
        title: const Text("Detail Produk", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              item['images'] ?? '',
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(height: 300, child: Center(child: Icon(Icons.image, size: 100))),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'] ?? '',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Rp ${item['promo'] ?? item['price'] ?? '0'}",
                    style: TextStyle(fontSize: 18, color: Colors.green.shade400, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  const Text("Deskripsi:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(item['description'] ?? ''),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade400,
            minimumSize: const Size(double.infinity, 50),
          ),
          onPressed: () async {
            final res = await http.post(
              Uri.parse("https://10.0.3.2/server_shop_vanzi/cart.php"),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({
                "action": "add",
                "user_id": 1,
                "product_id": item['id'],
              }),
            );

            if (res.body.isNotEmpty) {
              final data = jsonDecode(res.body);
              if (data['success'] == true) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage()));
              }
            }
          },
          child: const Text("Masukkan ke Keranjang", style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ),
    );
  }
}
