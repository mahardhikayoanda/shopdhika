import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_pal/onboardingpage.dart';
import 'cartpage.dart';
import 'gridelectronic.dart';
import 'gridbajupria.dart';
import 'gridbajuwanita.dart';
import 'gridsepatupria.dart';
import 'gridsepatuwanita.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> allProductItem = [];
  String? errorMessage;
  TextEditingController searchProduct = TextEditingController();
  PageController bannerController = PageController();
  Timer? banner;
  int indexBanner = 0;

  Future<void> getAllProduct() async {
    String urlProductItem = "https://backend-mobile.drenzzz.dev/allproduct.php";
    try {
      var response = await http.get(Uri.parse(urlProductItem));
      if (response.statusCode == 200) {
        setState(() {
          allProductItem = json.decode(response.body);
          errorMessage = null;
        });
      } else {
        setState(() {
          errorMessage = "Error: ${response.statusCode}";
        });
      }
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
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeIn,
        );
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
    getAllProduct();
  }

  @override
  Widget build(BuildContext context) {
    List<String> bannerImage = [
      "./lib/images/banner.jpeg",
      "./lib/images/banner1.png",
      "./lib/images/banner2.jpg",
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
              TextField(
                controller: searchProduct,
                decoration: const InputDecoration(
                  hintText: 'Search Product',
                  hintStyle: TextStyle(
                      fontSize: 13,
                      color: Colors.black,
                      fontWeight: FontWeight.normal),
                  labelText: 'Search Product',
                  labelStyle: TextStyle(
                      fontSize: 13,
                      color: Colors.black,
                      fontWeight: FontWeight.normal),
                  suffixIcon: Align(
                    widthFactor: 1.0,
                    heightFactor: 1.0,
                    child: Icon(
                      Icons.filter_list,
                      color: Colors.black,
                    ),
                  ),
                  prefixIcon: Align(
                    widthFactor: 1.0,
                    heightFactor: 1.0,
                    child: Icon(
                      Icons.search,
                      color: Colors.black,
                    ),
                  ),
                  filled: true,
                  fillColor: Color.fromARGB(255, 203, 224, 204),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                        width: 2,
                        color: Colors.black,
                        style: BorderStyle.solid),
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              SizedBox(
                height: 150,
                child: PageView.builder(
                  controller: bannerController,
                  itemCount: bannerImage.length,
                  itemBuilder: (context, index) {
                    return Image.asset(bannerImage[index], fit: BoxFit.cover);
                  },
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
                                    "./lib/images/icons8-electronics-96.png",
                                    width: 45,
                                    height: 45,
                                  ),
                                  const Text(
                                    "Electronics",
                                    style: TextStyle(
                                        fontSize: 7,
                                        fontWeight: FontWeight.bold),
                                  ),
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
                                  builder: (context) => GridBajuPria(),
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
                                    "./lib/images/icons8-t-shirt-64.png",
                                    width: 45,
                                    height: 45,
                                  ),
                                  const Text(
                                    "Men's Shirt",
                                    style: TextStyle(
                                        fontSize: 7,
                                        fontWeight: FontWeight.bold),
                                  ),
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
                                  builder: (context) => GridSepatuPria(),
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
                                  const Text(
                                    "Sneakers",
                                    style: TextStyle(
                                        fontSize: 7,
                                        fontWeight: FontWeight.bold),
                                  ),
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
                                  builder: (context) => GridBajuWanita(),
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
                                    "./lib/images/icons8-undershirt-96.png",
                                    width: 45,
                                    height: 45,
                                  ),
                                  const Text(
                                    "Woman Dress",
                                    style: TextStyle(
                                        fontSize: 7,
                                        fontWeight: FontWeight.bold),
                                  ),
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
                                  builder: (context) => GridSepatuWanita(),
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
                                    "./lib/images/icons8-heels-64.png",
                                    width: 45,
                                    height: 45,
                                  ),
                                  const Text(
                                    "Women's Heels",
                                    style: TextStyle(
                                        fontSize: 7,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            )),
                      ),
                    ],
                  )),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                  children: <Widget>[
                    const Text(
                      "Or Product List",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    const SizedBox(height: 5),
                    if (allProductItem.isEmpty) ...[
                      const Center(
                        child: Text(
                          "No Product Found",
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ),
                    ] else ...{
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 0.65,
                        ),
                        itemCount: allProductItem.length,
                        itemBuilder: (context, int index) {
                          final product = allProductItem[index];
                          return GestureDetector(
                            onTap: () {},
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
                                        const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Rp ${product['price']}",
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                        GestureDetector(
                                          onTap: () {},
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
                        },
                      ),
                    },
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
