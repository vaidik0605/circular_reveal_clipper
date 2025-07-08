import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Circular Reveal Clipper',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentIndex = 0;
  List<Map<String, dynamic>> boardingList = [
    {
      'image':
          'https://images.unsplash.com/photo-1526779259212-939e64788e3c?fm=jpg&q=60&w=3000&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OHx8dGhvdWdodHxlbnwwfHwwfHx8MA%3D%3D',
      'title': 'Title 1',
      'description': 'Description 1',
    },
    {
      'image':
          'https://static.vecteezy.com/system/resources/thumbnails/028/890/551/small_2x/generative-ai-zen-garden-hypnotic-simple-illustration-calm-relax-and-meditation-concept-photo.jpg',
      'title': 'Title 2',
      'description': 'Description 2',
    },
    {
      'image':
          'https://www.defencehealth.com.au/getmedia/150d9c9c-784f-4828-8996-96b6ccd93c1b/Tech-tips-for-feeling-zen.jpg',
      'title': 'Title 3',
      'description': 'Description 3',
    },
  ];
  double page = 0.0;
  double previousPage = 0.0;
  final PageController pageController = PageController();

  @override
  void initState() {
    pageController.addListener(() {
      setState(() {
        previousPage = page;
        page = pageController.page ?? 0.0;
      });
    });
    super.initState();
  }

  void onPageChanged(int value) {
    currentIndex = value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Stack(
              children:
                  boardingList.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> image = entry.value;
                    double progress = (index - page).clamp(0.0, 1.0);
                    bool isNext = page > previousPage;
                    return ClipPath(
                      clipper: CircularRevealClipper(progress: progress, isNext: isNext),
                      child: _pageView(image, index),
                    );
                  }).toList(),
            ),
          ),
          Positioned.fill(
            child: PageView.builder(
              onPageChanged: (value) => onPageChanged(value),
              controller: pageController,
              itemCount: boardingList.length,
              itemBuilder: (context, index) => Container(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pageView(Map<String, dynamic> boardingList, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      width: double.infinity,
      decoration: BoxDecoration(image: DecorationImage(image: NetworkImage(boardingList['image']), fit: BoxFit.cover)),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    boardingList['title'].toString(),
                    style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 32),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    boardingList['description'].toString(),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                  ),
                  const SizedBox(height: 33),
                  Container(
                    width: 40,
                    height: 8,
                    alignment:
                        (index == 0)
                            ? Alignment.centerLeft
                            : (index == 1)
                            ? Alignment.center
                            : Alignment.centerRight,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      width: 20,
                      height: 6,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                  const SizedBox(height: 33),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CircularRevealClipper extends CustomClipper<Path> {
  final double progress;
  final bool isNext;

  CircularRevealClipper({required this.progress, required this.isNext});

  @override
  Path getClip(Size size) {
    var path = Path();
    double startX = isNext ? size.width : 0;
    var center = Offset(startX, size.height / 2);
    var maxRadius = sqrt(size.width * size.width + size.height * size.height);
    var radius = maxRadius * (1.0 - progress);
    path.addOval(Rect.fromCircle(center: center, radius: radius));
    return path;
  }

  @override
  bool shouldReclip(CircularRevealClipper oldClipper) {
    return oldClipper.progress != progress || oldClipper.isNext != isNext;
  }
}
