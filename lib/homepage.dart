import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopdhika/cart.dart';
import 'package:shopdhika/gridbajupria.dart';
import 'package:shopdhika/gridbajuwanita.dart';
import 'package:shopdhika/gridelectronic.dart';
import 'package:shopdhika/gridsepatupria.dart';
import 'package:shopdhika/gridsepatuwanita.dart';
import 'onboardingpage.dart';
import 'productdetail.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> allProductList = [];
  List<dynamic> filteredProductList = [];
  String? username;
  TextEditingController searchProduct = TextEditingController();
  PageController bannerController = PageController();
  Timer? bannerTimer;
  int indexBanner = 0;

  Future<void> getAllProductItem() async {
    String urlProductItem = "https://10.0.3.2/server_shop_vanzi/allproductitem.php";
    try {
      var response = await http.get(Uri.parse(urlProductItem));
      setState(() {
        allProductList = jsonDecode(response.body);
        filteredProductList = allProductList;
      });
    } catch (exc) {
      if (kDebugMode) {
        print(exc);
      }
    }
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username");
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingPage()),
      );
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      filteredProductList = allProductList
          .where((product) =>
              product['name'].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    bannerController.dispose();
    bannerTimer?.cancel();
    super.dispose();
  }

  void bannerOnBoarding() {
    bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (indexBanner < 2) {
        indexBanner++;
      } else {
        indexBanner = 0;
      }
      if (bannerController.hasClients) {
        bannerController.animateToPage(indexBanner,
            duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    bannerController.addListener(() {
      setState(() {
        indexBanner = bannerController.page?.round() ?? 0;
      });
    });
    bannerOnBoarding();
    getAllProductItem();
    _loadUsername();
  }

  @override
  Widget build(BuildContext context) {
    List<String> bannerImage = [
      "lib/image/ecommerce1.png",
      "lib/image/ecommerce2.png",
      "lib/image/ecommerce3.png"
    ];
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const OnboardingPage(),
              ),
            );
          },
          icon: const Icon(Icons.arrow_back, size: 25, color: Colors.white),
        ),
        title: Text(
          username ?? "Vanzi Online Shop",
          style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade400,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, size: 25, color: Colors.white),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CartPage(),
                ),
              );
            },
            icon: const Icon(Icons.shopping_cart, size: 25, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            TextField(
              controller: searchProduct,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: "Search Product",
                hintStyle: TextStyle(
                    fontSize: 13, color: Colors.black, fontWeight: FontWeight.bold),
                suffixIcon: Align(
                  widthFactor: 1.0,
                  heightFactor: 1.0,
                  child: Icon(Icons.filter_list, color: Colors.green),
                ),
                prefixIcon: Align(
                  widthFactor: 1.0,
                  heightFactor: 1.0,
                  child: Icon(Icons.search, color: Colors.green),
                ),
                filled: true,
                fillColor: Color.fromARGB(255, 236, 255, 236),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                      width: 3, color: Colors.red, style: BorderStyle.solid),
                  borderRadius: BorderRadius.all(
                    Radius.circular(25),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              height: 150,
              child: PageView.builder(
                  controller: bannerController,
                  itemCount: bannerImage.length,
                  itemBuilder: (context, index) {
                    return Image.asset(bannerImage[index], fit: BoxFit.cover);
                  }),
            ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: SizedBox(
                height: 100,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Card(
                      elevation: 5,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GridElektronik(),
                            ),
                          );
                        },
                        child: SizedBox(
                          height: 80,
                          width: 60,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Image.asset('lib/image/elektronik.png',
                                  width: 45, height: 45),
                              const Text(
                                "Electronics",
                                style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Card(
                      elevation: 5,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GridSepatuPria(),
                            ),
                          );
                        },
                        child: SizedBox(
                          height: 80,
                          width: 60,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Image.asset('lib/image/sepatupria.png',
                                  width: 45, height: 45),
                              const Text(
                                "Men's Shoe",
                                style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Card(
                      elevation: 5,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GridBajuPria(),
                            ),
                          );
                        },
                        child: SizedBox(
                          height: 80,
                          width: 60,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Image.asset('lib/image/bajupria.png',
                                  width: 45, height: 45),
                              const Text(
                                "Men's Shirt",
                                style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Card(
                      elevation: 5,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GridSepatuWanita(),
                            ),
                          );
                        },
                        child: SizedBox(
                          height: 80,
                          width: 60,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Image.asset('lib/image/sepatuwanita.png',
                                  width: 45, height: 45),
                              const Text(
                                "Women's Shoe",
                                style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Card(
                      elevation: 5,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GridBajuWanita(),
                            ),
                          );
                        },
                        child: SizedBox(
                          height: 80,
                          width: 60,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Image.asset('lib/image/bajuwanita.png',
                                  width: 45, height: 45),
                              const Text(
                                "Women's Dress",
                                style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                children: <Widget>[
                  const Text(
                    "Our Product List",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 5),
                  if (filteredProductList.isEmpty) ...[
                    const Center(
                      child: Text(
                        "Product Not Found",
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ),
                  ] else ...[
                    GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 5,
                          crossAxisSpacing: 5,
                        ),
                        itemCount: filteredProductList.length,
                        itemBuilder: (context, int index) {
                          final itemProduct = filteredProductList[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProductDetailPage(item: itemProduct),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(8),
                                          topRight: Radius.circular(8),
                                        ),
                                        color: Colors.grey[100],
                                      ),
                                      child: Image.network(
                                        itemProduct['images'],
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Center(
                                            child: Icon(
                                              Icons.image_not_supported,
                                              color: Colors.grey,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                                    child: Text(
                                      itemProduct['name'],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          "Rp ${itemProduct['price']}",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            // Logika favorit
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.grey[100],
                                            ),
                                            child: const Icon(
                                              Icons.favorite_border,
                                              color: Colors.red,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}