import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;
import 'shoe_model.dart';

void main() {
  runApp(const ShoeShopApp());
}

// Enable Mouse Dragging for PageView on Web
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

class ShoeShopApp extends StatelessWidget {
  const ShoeShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scrollBehavior: MyCustomScrollBehavior(),
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Inter',
      ),
      home: const ShoeShowcaseScreen(),
    );
  }
}

class ShoeShowcaseScreen extends StatefulWidget {
  const ShoeShowcaseScreen({super.key});

  @override
  State<ShoeShowcaseScreen> createState() => _ShoeShowcaseScreenState();
}

class _ShoeShowcaseScreenState extends State<ShoeShowcaseScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  double _currentPage = 0.0;
  late AnimationController _floatingController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!;
      });
    });

    // Slower, smoother cycle for a premium float
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int activeIndex = _currentPage.round().clamp(0, shoes.length - 1);
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              shoes[activeIndex].backgroundColor,
              shoes[activeIndex].backgroundColor.withValues(alpha: 0.6),
              Colors.black,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Watermark Text (Parallax)
            Positioned(
              top: size.height * 0.1,
              left: -100 - (_currentPage * 100),
              child: Opacity(
                opacity: 0.1,
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    'NIKE AIR',
                    style: TextStyle(
                      fontSize: 220,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 10,
                    ),
                  ),
                ),
              ),
            ),

            Column(
              children: [
                // Header
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 28),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Text('Cart', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              CircleAvatar(
                                radius: 10,
                                backgroundColor: shoes[activeIndex].accentColor,
                                child: Text('3', style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.menu_open, color: Colors.white, size: 28),
                      ],
                    ),
                  ),
                ),

                // Main Area (Shoes)
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: shoes.length,
                    itemBuilder: (context, index) {
                      double diff = index - _currentPage;
                      double absDiff = diff.abs();
                      
                      // Elastic Scale & Dynamic Rotation
                      double scale = (1 - (absDiff * 0.18)).clamp(0.0, 1.2);
                      double opacity = (1 - (absDiff * 0.7)).clamp(0.0, 1.0);
                      double slideRotation = diff * 0.5;

                      return Opacity(
                        opacity: opacity,
                        child: AnimatedBuilder(
                          animation: _floatingController,
                          builder: (context, child) {
                            // UNIQUE MULTI-AXIS FLOAT
                            // Combines vertical sine and horizontal cosine for a circular/orbital float
                            double floatY = 25 * math.sin(_floatingController.value * 2 * math.pi);
                            double floatX = 10 * math.cos(_floatingController.value * 2 * math.pi);
                            double floatRotate = 0.05 * math.sin(_floatingController.value * 2 * math.pi);

                            return Transform(
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001)
                                ..translate(floatX, floatY, 0) // Multi-axis translation
                                ..scale(scale)
                                ..rotateZ(slideRotation + floatRotate), // Slide + Float rotation
                              alignment: Alignment.center,
                              child: Center(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Dynamic Shadow that reacts to FLOAT
                                    Transform.translate(
                                      offset: const Offset(0, 80),
                                      child: Container(
                                        height: 30,
                                        width: 200 * (1 - (floatY.abs() / 150)),
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.3),
                                              blurRadius: 50 + floatY.abs(),
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // The Shoe
                                    Image.asset(
                                      shoes[index].imagePath,
                                      fit: BoxFit.contain,
                                      width: size.width * 0.9,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),

                // Dots indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(shoes.length, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      height: 5,
                      width: i == activeIndex ? 25 : 10,
                      decoration: BoxDecoration(
                        color: i == activeIndex ? shoes[activeIndex].accentColor : Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 20),

                // Bottom Content
                Container(
                  padding: const EdgeInsets.fromLTRB(40, 20, 40, 40),
                  child: Column(
                    children: [
                      Text(
                        shoes[activeIndex].name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        shoes[activeIndex].description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.6),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Share', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Container(
                            height: 75,
                            width: 75,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: Colors.white12),
                              boxShadow: [
                                BoxShadow(
                                  color: shoes[activeIndex].accentColor.withValues(alpha: 0.25),
                                  blurRadius: 25,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.add_shopping_cart, size: 32, color: Colors.white),
                          ),
                          Text(
                            shoes[activeIndex].price,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
