import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopdhika/cart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:shopdhika/homepage.dart';

class GridBajuPria extends StatefulWidget {
  const GridBajuPria({super.key});

  @override
  State<GridBajuPria> createState() => _GridBajuPriaState();
}

class _GridBajuPriaState extends State<GridBajuPria> {
  List<dynamic> products = [];
  bool isLoading = true;

  String getImageUrl(String? url) {
    if (url == null || url.isEmpty) return "";
    
    if (url.contains('localhost')) {
      return url.replaceAll('localhost', '192.168.18.6');
    }

    if (url.startsWith('http')) return url;
    
    return "https://backend-mobile.mazdick.biz.id/$url";
  }

  Future<void> getAllProducts() async {
    const String url = "https://backend-mobile.mazdick.biz.id/gridbajupria.php";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          products = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) print(e);
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    getAllProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green.shade400,
        centerTitle: true,
        title: const Text("Baju Pria", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7, // Sedikit lebih tinggi untuk layout harga
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final item = products[index];
                return _buildProductCard(item);
              },
            ),
    );
  }

  Widget _buildProductCard(dynamic item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailBajuPria(item: item),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE & FAVORITE ICON (STACK)
            Expanded(
              child: Stack(
                children: [
                  // Gambar Produk
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    child: Image.network(
                      getImageUrl(item['images']),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        if (kDebugMode) {
                          print("Failed to load grid image: ${getImageUrl(item['images'])}");
                          print("Error: $error");
                        }
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(child: Icon(Icons.image_not_supported)),
                        );
                      },
                    ),
                  ),
                  // Icon Favorit (Floating Top Right)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// CONTENT
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Produk
                  Text(
                    item['name'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Harga Kiri & Promo Kanan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Sisi Kiri: Harga Asli (Coret)
                      Expanded(
                        child: Text(
                          "Rp ${item['price']}",
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ),
                      // Sisi Kanan: Harga Promo (Bold/Biru)
                      Text(
                        "Rp ${item['promo']}",
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// =================================================
/// DETAIL BAJU PRIA
/// =================================================

class DetailBajuPria extends StatelessWidget {
  final Map<String, dynamic> item;

  const DetailBajuPria({super.key, required this.item});

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
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          item['name'],
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.favorite, color: Colors.red),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Besar
            Image.network(
              getImageUrl(item['images']),
              width: double.infinity,
              height: 350,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                  height: 350,
                  color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.broken_image, size: 50))),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Produk
                  Text(
                    item['name'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Harga dan Promo Sejajar (Kiri & Kanan)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Harga Asli", style: TextStyle(fontSize: 10, color: Colors.grey)),
                            Text(
                              "Rp ${item['price']}",
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text("Harga Promo", style: TextStyle(fontSize: 10, color: Colors.blueAccent)),
                            Text(
                              "Rp ${item['promo']}",
                              style: const TextStyle(
                                fontSize: 22,
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 40),
                  
                  const Text(
                    "Deskripsi Produk",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item['description'],
                    style: TextStyle(color: Colors.grey[700], height: 1.6, fontSize: 15),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade400,
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 5,
          ),
          onPressed: () async {
            // ... (Logika Add to Cart Kamu Tetap Sama)
            final prefs = await SharedPreferences.getInstance();
            final userId = prefs.getInt("user_id") ?? 0;

            final res = await http.post(
              Uri.parse("https://backend-mobile.mazdick.biz.id/cart.php"),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({
                "action": "add",
                "user_id": userId,
                "product_id": item['id'],
              }),
            );

            if (res.body.isEmpty) return;

            dynamic data;
            try {
              data = jsonDecode(res.body);
            } catch (e) {
               ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error: ${e.toString()}")),
              );
              return;
            }

            if (data['success'] == true) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartPage()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(data['message'] ?? "Failed")),
              );
            }
          },
          child: const Text(
            "Add to Cart",
            style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}