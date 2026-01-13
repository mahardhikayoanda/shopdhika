import 'package:flutter/material.dart';

import 'loginpage.dart';

class OnboardingPage extends StatefulWidget {
  OnboardingPage({Key? key}) : super(key: key);

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
          "https://img.freepik.com/free-vector/screens-isometric-electronic-devices_23-2147647441.jpg?semt=ais_hybrid&w=740&q=80",
    },
    {
      "title": "Men's Fashion",
      "subtitle":
          "Discover the latest men's clothing collection for your daily style",
      "image":
          "https://p19-images-common-sign-sg.tokopedia-static.net/tos-maliva-i-o3syd03w52-us/18627d18a7764641ac8d09dbdceee222~tplv-o3syd03w52-resize-jpeg:1600:1600.jpeg?lk3s=0ccea506&x-expires=1766557108&x-signature=eTuhuInqzbxc5IXdqdAgMkzzMHc%3D&x-signature-webp=Hd38DhH63NzCt%2FeGLaZJ6Qpf9Lk%3D",
    },
    {
      "title": "Women's Fashion",
      "subtitle":
          "Look beautiful and elegant with our women's clothing collection",
      "image":
          "https://img.pikbest.com/png-images/20240801/womens-shirt-template-stock_10691737.png!w700wp",
    },
    {
      "title": "Sporty Shoes",
      "subtitle": "Comfortable for sports and everyday activities",
      "image":
          "https://i.pinimg.com/736x/0d/7e/48/0d7e486b3caf7284693b8607f46f0dd7.jpg",
    },
    {
      "title": "Women's Heels",
      "subtitle": "Complete your look with our best heels collection",
      "image":
          "https://pics.clipartpng.com/Black_High_Heels_PNG_Clipart-3139.png",
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
                              ? Colors.blueAccent
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
