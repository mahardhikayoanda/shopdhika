import 'package:flutter/material.dart';
import 'package:shopdhika/homepage.dart';
import 'package:shopdhika/login.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  PageController page = PageController();
  int indexPage = 0;
  List<Map<String, String>> onBoardData = [
    {
      "title": "Dhika Store",
      "subtitle": "Welcome to our Shop!",
      "image":
          "https://komerce.id/blog/wp-content/uploads/2021/11/daftar-produk-elektronik-terlaris.jpg",
    },
    {
      "title": "Men's Fashion",
      "subtitle":
          "Discover the latest men's clothing collection for your daily style",
      "image":
          "https://shopee.co.id/inspirasi-shopee/wp-content/uploads/2019/04/0df807107543c82a2afbc782df35bcba.jpg",
    },
    {
      "title": "Women's Fashion",
      "subtitle":
          "Look beautiful and elegant with our women's clothing collection",
      "image":
          "https://www.hijup.com/magazine/wp-content/uploads/2022/12/b99e37ba-baju-setelan-garis-vertikal.jpeg",
    },
    {
      "title": "Men's Shoes",
      "subtitle": "Comfortable for sports and everyday activities",
      "image":
          "https://www.skechers.id/media/catalog/product/cache/4cd1b9859276d7e49e0c5f4dfaae81a4/0/8/0888-SKE237301BKN00511H-1.jpg",
    },
    {
      "title": "Women's Heels",
      "subtitle": "Complete your look with our best heels collection",
      "image":
          "https://www.tas.id/wp-content/uploads/JSH772-IDR.200.000-MATERIAL-PU-COLOR-BLACK-HEEL-8CM-WEIGHT-700GR-SIZE-3536373839.jpg",
    },
  ];

  @override
  void initState() {
    super.initState();
    page = PageController();
    page.addListener(() {
      setState(() {
        indexPage = page.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: PageView.builder(
                controller: page,
                itemCount: onBoardData.length,
                itemBuilder: (context, index) {
                  return onBoardingLayout(
                      title: "${onBoardData[index]["title"]}",
                      subTitle: "${onBoardData[index]["subtitle"]}",
                      image: "${onBoardData[index]["image"]}");
                }),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: indexPage == onBoardData.length - 1
                        ? TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) => const LoginPage()));
                            },
                            child: Text(
                              "Get Started",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    onBoardData.length,
                    (index) => Container(
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: indexPage == index
                              ? Colors.blue
                              : Colors.grey.shade300),
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () {
                        if (indexPage == onBoardData.length - 1) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        } else {
                          page.nextPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeIn);
                        }
                      },
                      icon: Icon(Icons.arrow_forward_ios),
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

class onBoardingLayout extends StatelessWidget {
  const onBoardingLayout(
      {required this.title, required this.subTitle, required this.image});
  final String title;
  final String subTitle;
  final String image;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.network(
          image,
          height: 350,
          width: 300,
          fit: BoxFit.fill,
        ),
        const SizedBox(
          height: 20,
        ),
        Text(
          title,
          style: const TextStyle(
              fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            subTitle,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
