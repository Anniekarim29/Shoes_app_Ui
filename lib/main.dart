import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'shoe_model.dart';

void main() {
  runApp(const ShoeShopApp());
}

class ShoeShopApp extends StatelessWidget {
  const ShoeShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
  late AnimationController _detailsController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.82);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!;
      });
    });

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _detailsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _detailsController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatingController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int activeIndex = _currentPage.round();
    
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
            // Parallax Background Text
            Positioned(
              top: 100,
              left: -50 - (_currentPage * 30), // Parallax move
              child: Opacity(
                opacity: 0.08,
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    'NIKE AIR',
                    style: TextStyle(
                      fontSize: 180,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            
            // Header
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                    Row(
                      children: [
                        const Text(
                          'Cart',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: shoes[activeIndex].accentColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Text(
                            '3',
                            style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.menu, color: Colors.white),
                  ],
                ),
              ),
            ),

            // 3D Swiping PageView
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              height: 450,
              child: PageView.builder(
                controller: _pageController,
                itemCount: shoes.length,
                onPageChanged: (index) {
                  _detailsController.reset();
                  _detailsController.forward();
                },
                itemBuilder: (context, index) {
                  double difference = index - _currentPage;
                  
                  // 3D Perspective Transform
                  Matrix4 matrix = Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // perspective
                    ..rotateY(difference * 0.4)
                    ..scale(1 - (difference.abs() * 0.2));

                  double opacity = (1 - (difference.abs() * 0.6)).clamp(0.0, 1.0);

                  return Opacity(
                    opacity: opacity,
                    child: Transform(
                      transform: matrix,
                      alignment: Alignment.center,
                      child: ShoeCard(
                        shoe: shoes[index],
                        floatingAnimation: _floatingController,
                        offset: difference,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Detailed Content at Bottom
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _detailsController,
                child: ShoeDetailsSection(
                  shoe: shoes[activeIndex],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShoeCard extends StatelessWidget {
  final Shoe shoe;
  final Animation<double> floatingAnimation;
  final double offset;

  const ShoeCard({
    super.key, 
    required this.shoe, 
    required this.floatingAnimation,
    required this.offset,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: floatingAnimation,
        builder: (context, child) {
          // Floating + slight parallax offset
          double floatY = 15 * math.sin(floatingAnimation.value * 2 * math.pi);
          
          return Transform.translate(
            offset: Offset(offset * 20, floatY),
            child: Container(
              height: 320,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 60,
                    spreadRadius: -25,
                    offset: const Offset(0, 60),
                  ),
                ],
              ),
              child: Image.asset(
                shoe.imagePath,
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }
}

class ShoeDetailsSection extends StatelessWidget {
  final Shoe shoe;

  const ShoeDetailsSection({super.key, required this.shoe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        children: [
          // Animated name change effect could be added here
          Text(
            shoe.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            shoe.description,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
              const Text(
                'Share',
                style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1),
              ),
              Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                ),
                child: const Icon(Icons.add, size: 32, color: Colors.white),
              ),
              Text(
                shoe.price,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
