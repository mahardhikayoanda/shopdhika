import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopdhika/cart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetailPage extends StatelessWidget {
  final Map<String, dynamic> item;

  const ProductDetailPage({super.key, required this.item});

  String getImageUrl(String? url) {
    if (url == null || url.isEmpty) return "";
    
    if (url.contains('localhost')) {
      return url.replaceAll('localhost', '192.168.18.6');
    }

    if (url.startsWith('http')) return url;
    
    return "https://backend-mobile.mazdick.biz.id/$url";
  }

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
              getImageUrl(item['images']),
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
              errorBuilder: (_, error, __) {
                if (kDebugMode) {
                  print("Failed to load detail image: ${getImageUrl(item['images'])}");
                  print("Error: $error");
                }
                return const SizedBox(height: 300, child: Center(child: Icon(Icons.image, size: 100)));
              },
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
            try {
              final prefs = await SharedPreferences.getInstance();
              final userId = prefs.getInt("user_id") ?? 0;

              // Check Login First
              if (userId == 0) {
                 ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Silakan Login terlebih dahulu")),
                );
                return;
              }

              final res = await http.post(
                Uri.parse("https://backend-mobile.mazdick.biz.id/cart.php"),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode({
                  "action": "add",
                  "user_id": userId,
                  "product_id": item['id'],
                }),
              );

              if (res.statusCode != 200) {
                 throw Exception("Server Error: ${res.statusCode}");
              }
              
              if (res.body.isEmpty) {
                 throw Exception("Server returned empty response");
              }

              final data = jsonDecode(res.body);
              if (data['success'] == true) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage()));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(data['message'] ?? "Gagal menambahkan ke keranjang")),
                );
              }
            } catch (e) {
               ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: $e")),
                );
            }
          },
          child: const Text("Masukkan ke Keranjang", style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ),
    );
  }
}
