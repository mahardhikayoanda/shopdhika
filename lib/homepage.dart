import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopdhika/onboardingpage.dart';
import 'package:shopdhika/checkout.dart';
import 'cart_page.dart';
import 'gridelectronic.dart';
import 'gridbajupria.dart';
import 'gridbajuwanita.dart';
import 'gridsepatupria.dart';
import 'gridsepatuwanita.dart';
import 'detail_product.dart';
import 'dart:convert';
import 'dart:math';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> allProductItem = [];
  String? errorMessage;
  int indexBanner = 0;
  Timer? banner;
  PageController bannerController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    bannerOnBoarding();
    getAllProduct();
  }

  Future<void> getAllProduct() async {
    // List of all category URLs (using the working external source for images)
    List<String> urls = [
      "https://backend-mobile.drenzzz.dev/gridelektronik.php",
      "https://backend-mobile.drenzzz.dev/gridbajupria.php",
      "https://backend-mobile.drenzzz.dev/gridbajuwanita.php",
      "https://backend-mobile.drenzzz.dev/gridsepatupria.php",
      "https://backend-mobile.drenzzz.dev/gridsepatuwanita.php",
    ];

    List<dynamic> combinedProducts = [];

    try {
      for (String url in urls) {
        try {
          var response = await http.get(Uri.parse(url));
          if (response.statusCode == 200) {
            List<dynamic> products = json.decode(response.body);
            combinedProducts.addAll(products);
          }
        } catch (e) {
          debugPrint("Error fetching $url: $e");
        }
      }

      // Randomize the list
      combinedProducts.shuffle(Random());

      setState(() {
        allProductItem = combinedProducts;
        errorMessage = null;
      });
    } catch (exec) {
      if (kDebugMode) {
        print(exec);
      }
      setState(() {
        errorMessage = "Exception: $exec";
      });
    }
  }

  @override
  void dispose() {
    banner?.cancel();
    bannerController.dispose();
    super.dispose();
  }

  void bannerOnBoarding() {
    banner = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (indexBanner < 2) {
        indexBanner++;
      } else {
        indexBanner = 0;
      }
      if (bannerController.hasClients) {
        bannerController.animateToPage(
          indexBanner,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeIn,
        );
      }
    });
  }

  // Helper to add item to cart
  Future<void> _addToCart(Map<String, dynamic> product) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please login first")));
      return;
    }

    bool success = await CartService().addToCart(product['id'].toString());
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Added to cart")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to add - Try Relogin")));
    }
  }

  // Helper for checkout
  Future<void> _checkoutNow(Map<String, dynamic> product) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please login first")));
      return;
    }

    // Add to cart first
    bool success = await CartService().addToCart(product['id'].toString());
    if (success) {
      // Then proceed to checkout
      if (mounted) {
        Checkout.checkout(context);
      }
    } else {
      print("DEBUG: _checkoutNow failed to add to cart");
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to process - Try Relogin or Check Server")));
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> bannerImage = [
      "./lib/images/banner1.jpg",
      "./lib/images/banner2.jpg",
      "./lib/images/banner3.jpg",
    ];

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => OnboardingPage()));
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 22,
              )),
          title: const Text(
            "Pal Store",
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.green,
          actions: [
            IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.search_outlined,
                  color: Colors.white,
                  size: 22,
                )),
            IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CartPage()),
                  );
                },
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                  size: 22,
                )),
          ],
        ),
        body: SingleChildScrollView(
            child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(5),
              child: SizedBox(
                height: 150,
                width: double.infinity,
                child: PageView.builder(
                  controller: bannerController,
                  itemCount: bannerImage.length,
                  itemBuilder: (context, index) {
                    return Image.asset(bannerImage[index], fit: BoxFit.cover);
                  },
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.all(5)),
            SizedBox(
                height: 100,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Card(
                      elevation: 5,
                      child: InkWell(
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => GridElectronic(),
                              ),
                            );
                          },
                          child: SizedBox(
                            height: 80,
                            width: 60,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                  "./lib/images/icons8-electronics-64.png",
                                  width: 45,
                                  height: 45,
                                ),
                                const Text(
                                  "Electronic",
                                  style: TextStyle(fontSize: 10),
                                )
                              ],
                            ),
                          )),
                    ),
                    Card(
                        elevation: 5,
                        child: InkWell(
                            onTap: () {
                              Navigator.of(context).pushReplacement(
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
                                  Image.asset(
                                    "./lib/images/icons8-t-shirt-50.png",
                                    width: 45,
                                    height: 45,
                                  ),
                                  const Text("Baju Pria",
                                      style: TextStyle(fontSize: 10))
                                ],
                              ),
                            ))),
                    Card(
                        elevation: 5,
                        child: InkWell(
                            onTap: () {
                              Navigator.of(context).pushReplacement(
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
                                  Image.asset(
                                    "./lib/images/icons8-undershirt-32.png",
                                    width: 45,
                                    height: 45,
                                  ),
                                  const Text("Baju Wanita",
                                      style: TextStyle(fontSize: 10))
                                ],
                              ),
                            ))),
                    Card(
                        elevation: 5,
                        child: InkWell(
                            onTap: () {
                              Navigator.of(context).pushReplacement(
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
                                  Image.asset(
                                    "./lib/images/icons8-sneaker-64.png",
                                    width: 45,
                                    height: 45,
                                  ),
                                  const Text("Sepatu Pria",
                                      style: TextStyle(fontSize: 10))
                                ],
                              ),
                            ))),
                    Card(
                        elevation: 5,
                        child: InkWell(
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const GridSepatuWanita(),
                                ),
                              );
                            },
                            child: SizedBox(
                              height: 80,
                              width: 60,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset(
                                    "./lib/images/icons8-heels-32.png",
                                    width: 50,
                                    height: 50,
                                  ),
                                  const Text("Sepatu Wanita",
                                      style: TextStyle(fontSize: 10))
                                ],
                              ),
                            ))),
                  ],
                )),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                children: <Widget>[
                  const Text(
                    "Recommendation For You",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 5),
                  if (allProductItem.isEmpty) ...[
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  ] else ...{
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 0.60,
                      ),
                      itemCount: allProductItem.length,
                      itemBuilder: (context, int index) {
                        final product = allProductItem[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => DetailProduct(item: product),
                            ));
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
                                    product['images'],
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (context, error, stackTrace) {
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
                                padding:
                                    const EdgeInsets.fromLTRB(8, 8, 8, 4),
                                child: Text(
                                  product['name'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(8, 0, 8, 4),
                                child: Text(
                                  "Rp ${product['price']}",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                          padding: EdgeInsets.zero,
                                          minimumSize: Size(0, 30),
                                        ),
                                        onPressed: () => _addToCart(product),
                                        child: const Icon(Icons.add_shopping_cart, size: 16, color: Colors.white),
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          padding: EdgeInsets.zero,
                                          minimumSize: Size(0, 30),
                                        ),
                                        onPressed: () => _checkoutNow(product),
                                        child: const Text("Buy", style: TextStyle(fontSize: 10, color: Colors.white)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 4),
                            ],
                          ),
                        ),
                        );
                      },
                    ),
                  }
                ],
              ),
            ),
          ],
        )));
  }
}
