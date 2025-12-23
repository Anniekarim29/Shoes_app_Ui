import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;
import 'shoe_model.dart';

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
    final currentShoe = shoes[activeIndex];
    
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 1000),
        decoration: BoxDecoration(
          // PURE PREMIUM RADIAL GRADIENT
          gradient: RadialGradient(
            center: const Alignment(0.4, -0.3),
            radius: 1.5,
            colors: [
              currentShoe.secondaryColor.withValues(alpha: 0.4),
              currentShoe.primaryColor,
              Colors.black,
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Watermark (Nike Air)
            Positioned(
              top: size.height * 0.1,
              left: -120 - (_currentPage * 90),
              child: Opacity(
                opacity: 0.06,
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    'NIKE AIR',
                    style: TextStyle(
                      fontSize: 230,
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
                        const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                        // Cart Indicator
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Text('Cart', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              CircleAvatar(
                                radius: 10,
                                backgroundColor: currentShoe.accentColor,
                                child: Text('$_cartCount', 
                                  style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.menu, color: Colors.white),
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
                      
                      double scale = (1 - (absDiff * 0.18)).clamp(0.0, 1.2);
                      double opacity = (1 - (absDiff * 0.8)).clamp(0.0, 1.0);
                      double rotation = diff * 0.5;

                      return Opacity(
                        opacity: opacity,
                        child: AnimatedBuilder(
                          animation: _floatingController,
                          builder: (context, child) {
                            double floatY = 25 * math.sin(_floatingController.value * 2 * math.pi);
                            double floatX = 12 * math.cos(_floatingController.value * 2 * math.pi);
                            double floatRotate = 0.04 * math.sin(_floatingController.value * 2 * math.pi);

                            return Transform(
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001)
                                ..translate(floatX, floatY, 0)
                                ..scale(scale)
                                ..rotateZ(rotation + floatRotate),
                              alignment: Alignment.center,
                              child: Center(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // MULTI-LAYERED MIXED SHADOW
                                    Transform.translate(
                                      offset: const Offset(0, 40),
                                      child: Container(
                                        height: 300,
                                        width: 300,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(
                                            colors: [
                                              shoes[index].secondaryColor.withValues(alpha: 0.35),
                                              shoes[index].primaryColor.withValues(alpha: 0.1),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Actual Shoe
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

                // Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(shoes.length, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      height: 4,
                      width: i == activeIndex ? 25 : 8,
                      decoration: BoxDecoration(
                        color: i == activeIndex ? currentShoe.accentColor : Colors.white12,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 25),

                // Details Content
                Container(
                  padding: const EdgeInsets.fromLTRB(40, 0, 40, 40),
                  child: Column(
                    children: [
                      Text(
                        currentShoe.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        currentShoe.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.4),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // PREMIUM ADD TO CART RE-DESIGN
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _cartCount++;
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          height: 75,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                currentShoe.secondaryColor.withValues(alpha: 0.8),
                                currentShoe.primaryColor,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white10),
                            boxShadow: [
                              BoxShadow(
                                color: currentShoe.secondaryColor.withValues(alpha: 0.3),
                                blurRadius: 25,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'ADD TO CART',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Container(
                                  height: 1,
                                  width: 40,
                                  color: Colors.white54,
                                ),
                                const SizedBox(width: 20),
                                Text(
                                  currentShoe.price,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
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
