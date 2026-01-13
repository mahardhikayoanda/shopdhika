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
      "title": "Vanzi Store",
      "subtitle": "Welcome to our Shop!",
      "image":
          "https://atlantaelectronics.co.id/assets/public/images/product/240109012132GCX257CQEW.png",
    },
    {
      "title": "Men's Fashion",
      "subtitle":
          "Discover the latest men's clothing collection for your daily style",
      "image":
          "https://edit.voila.id/wp-content/uploads/2025/01/1.-Jenis-baju-pria.jpg",
    },
    {
      "title": "Women's Fashion",
      "subtitle":
          "Look beautiful and elegant with our women's clothing collection",
      "image":
          "https://edit.voila.id/wp-content/uploads/2025/12/12-1.jpg",
    },
    {
      "title": "Men's Shoes",
      "subtitle": "Comfortable for sports and everyday activities",
      "image":
          "https://static.nike.com/a/images/t_web_pdp_535_v2/f_auto/772b77e2-2baf-4b44-ab4e-d767b038b105/NIKE+P-6000+PRM.png",
    },
    {
      "title": "Women's Heels",
      "subtitle": "Complete your look with our best heels collection",
      "image":
          "https://www.static-src.com/wcsstore/Indraprastha/images/catalog/full/catalog-image/109/MTA-172888543/brd-44261_garage-sepatu-high-heels-wanita-h-3974-wanita-kasual-kerja-kantor-trendi-berkualitas-hitam_full01-6911313f.jpg",
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
