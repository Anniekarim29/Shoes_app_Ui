import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;
import 'shoe_model.dart';
import 'dart:ui';

void main() {
  runApp(const ShoeShopApp());
}

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
  int _cartCount = 3;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!;
      });
    });

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
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
    final shoe = shoes[activeIndex];
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        decoration: BoxDecoration(
          // CLEAR VISIBLE GRADIENT
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              shoe.secondaryColor.withValues(alpha: 0.4),
              Colors.black,
              Colors.black,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Watermark (Nike Air) - Pure Dark Style
            Positioned(
              top: size.height * 0.12,
              left: -100 - (_currentPage * 70),
              child: Opacity(
                opacity: 0.04,
                child: Text(
                  'NIKE',
                  style: TextStyle(
                    fontSize: 250,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -10,
                  ),
                ),
              ),
            ),

            Column(
              children: [
                // Premium Header
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
                        
                        // Cart Indicator
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Row(
                            children: [
                              const Text('CART', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5)),
                              const SizedBox(width: 8),
                              CircleAvatar(
                                radius: 10,
                                backgroundColor: shoe.accentColor,
                                child: Text('$_cartCount', style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                        
                        const Icon(Icons.menu, color: Colors.white70),
                      ],
                    ),
                  ),
                ),

                // Main Slider Area
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: shoes.length,
                    itemBuilder: (context, index) {
                      double diff = index - _currentPage;
                      double absDiff = diff.abs();
                      
                      double scale = (1 - (absDiff * 0.2)).clamp(0.0, 1.2);
                      double opacity = (1 - (absDiff * 0.8)).clamp(0.0, 1.0);
                      double rotation = diff * 0.4;

                      return Opacity(
                        opacity: opacity,
                        child: AnimatedBuilder(
                          animation: _floatingController,
                          builder: (context, child) {
                            double floatY = 20 * math.sin(_floatingController.value * 2 * math.pi);
                            double floatRotate = 0.05 * math.cos(_floatingController.value * 2 * math.pi);

                            return Transform(
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001)
                                ..translate(0.0, floatY, 0)
                                ..scale(scale)
                                ..rotateZ(rotation + floatRotate),
                              alignment: Alignment.center,
                              child: Center(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // DARK MIX COLOR SHADOW
                                    Container(
                                      height: 250,
                                      width: 250,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: shoes[index].secondaryColor.withValues(alpha: 0.3),
                                            blurRadius: 80,
                                            spreadRadius: 10,
                                          ),
                                          BoxShadow(
                                            color: shoes[index].accentColor.withValues(alpha: 0.1),
                                            blurRadius: 100,
                                            spreadRadius: -10,
                                          ),
                                        ],
                                      ),
                                    ),
                                    // The Shoe
                                    Image.asset(
                                      shoes[index].imagePath,
                                      fit: BoxFit.contain,
                                      width: size.width * 0.95,
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

                // DOTS
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(shoes.length, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 3,
                      width: i == activeIndex ? 30 : 10,
                      decoration: BoxDecoration(
                        color: i == activeIndex ? shoe.accentColor : Colors.white12,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 30),

                // BOTTOM PANEL (Glassmorphism Style)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
                  child: Column(
                    children: [
                      Text(
                        shoe.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        shoe.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.4),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // SLEEK ADD TO CART BUTTON
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _cartCount++;
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          height: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white.withValues(alpha: 0.05),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 30),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'ADD TO CART',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    Container(
                                      height: 30,
                                      width: 1,
                                      color: Colors.white10,
                                    ),
                                    Text(
                                      shoe.price,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: shoe.accentColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
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
