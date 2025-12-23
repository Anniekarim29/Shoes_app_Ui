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
  
  // LIVE CART STATE
  int _cartCount = 3;
  late AnimationController _cartAnimationController;
  late Animation<double> _cartScaleAnimation;

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

    // Cart Animation
    _cartAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _cartScaleAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _cartAnimationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatingController.dispose();
    _cartAnimationController.dispose();
    super.dispose();
  }

  void _addToCart() {
    setState(() {
      _cartCount++;
    });
    _cartAnimationController.forward().then((_) => _cartAnimationController.reverse());
    
    // Show a quick snackbar/feedback
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${shoes[_currentPage.round()].name} to cart!', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: shoes[_currentPage.round()].accentColor.withValues(alpha: 0.9),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int activeIndex = _currentPage.round().clamp(0, shoes.length - 1);
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
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
            // Watermark (Nike Air) - Parallax
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
                        const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 28),
                        
                        // LIVE CART INDICATOR
                        ScaleTransition(
                          scale: _cartScaleAnimation,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.shopping_bag_outlined, size: 18),
                                const SizedBox(width: 8),
                                const Text('Cart', style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  transitionBuilder: (Widget child, Animation<double> animation) {
                                    return ScaleTransition(scale: animation, child: child);
                                  },
                                  child: Container(
                                    key: ValueKey<int>(_cartCount),
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: shoes[activeIndex].accentColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '$_cartCount',
                                      style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
                                    // Reactive Shadow
                                    Transform.translate(
                                      offset: const Offset(0, 80),
                                      child: Container(
                                        height: 35,
                                        width: 210 * (1 - (floatY.abs() / 140)),
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.35),
                                              blurRadius: 60 + floatY.abs(),
                                              spreadRadius: 3,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Image.asset(
                                      shoes[index].imagePath,
                                      fit: BoxFit.contain,
                                      width: size.width * 0.92,
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
                      height: 5,
                      width: i == activeIndex ? 28 : 10,
                      decoration: BoxDecoration(
                        color: i == activeIndex ? shoes[activeIndex].accentColor : Colors.white12,
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
                        shoes[activeIndex].name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        shoes[activeIndex].description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.5),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 45),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Share', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
                          
                          // LIVR ADD TO CART BUTTON
                          GestureDetector(
                            onTap: _addToCart,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                color: shoes[activeIndex].backgroundColor.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: shoes[activeIndex].accentColor.withValues(alpha: 0.3), width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: shoes[activeIndex].accentColor.withValues(alpha: 0.3),
                                    blurRadius: 30,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Icon(Icons.add_shopping_cart_rounded, size: 34, color: shoes[activeIndex].accentColor),
                            ),
                          ),
                          
                          Text(
                            shoes[activeIndex].price,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
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
