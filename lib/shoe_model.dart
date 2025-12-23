import 'package:flutter/material.dart';

class Shoe {
  final String name;
  final String description;
  final String price;
  final String imagePath;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;

  Shoe({
    required this.name,
    required this.description,
    required this.price,
    required this.imagePath,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
  });
}

final List<Shoe> shoes = [
  Shoe(
    name: 'NIKE AIR MAX 270',
    description: 'The Nike Air Max 270 delivers visible cushioning under every step.',
    price: '\$150.00',
    imagePath: 'assets/shoes1.png',
    primaryColor: const Color(0xFF00120E), // Ultra Dark Teal
    secondaryColor: const Color(0xFF004D40), // Rich Forest Green
    accentColor: const Color(0xFFCCFF00), // Volt
  ),
  Shoe(
    name: 'NIKE REACT ELEMENT',
    description: 'Experience the next level of comfort with React foam technology.',
    price: '\$130.00',
    imagePath: 'assets/shoes2.png',
    primaryColor: const Color(0xFF0A040F), // Ultra Dark Purple
    secondaryColor: const Color(0xFF311B92), // Deep Royale
    accentColor: const Color(0xFFFFD700), // Gold
  ),
  Shoe(
    name: 'NIKE ZOOM FLY 3',
    description: 'Built for speed and comfort during your long runs.',
    price: '\$160.00',
    imagePath: 'assets/shoes3.png',
    primaryColor: const Color(0xFF040A1A), // Ultra Dark Blue
    secondaryColor: const Color(0xFF01579B), // Electric Navy
    accentColor: const Color(0xFFFF4500), // Lava
  ),
  Shoe(
    name: 'NIKE AIR FORCE 1',
    description: 'The legend lives on in the Nike Air Force 1.',
    price: '\$100.00',
    imagePath: 'assets/shoes4.png',
    primaryColor: const Color(0xFF121212), // Jet Black
    secondaryColor: const Color(0xFF424242), // Steel Gray
    accentColor: const Color(0xFF00FFFF), // Cyber Cyan
  ),
  Shoe(
    name: 'NIKE JOYRIDE RUN',
    description: 'Tiny foam beads underfoot provide personalized cushioning.',
    price: '\$180.00',
    imagePath: 'assets/shoes5.png',
    primaryColor: const Color(0xFF1A0505), // Ultra Dark Maroon
    secondaryColor: const Color(0xFFB71C1C), // Blood Red
    accentColor: const Color(0xFFFF69B4), // Neon Pink
  ),
  Shoe(
    name: 'NIKE PEGASUS 37',
    description: 'The trusted favorite returns with updated cushioning.',
    price: '\$120.00',
    imagePath: 'assets/shoes6.png',
    primaryColor: const Color(0xFF05081A), // Ultra Dark Navy
    secondaryColor: const Color(0xFF1A237E), // Deep Space Blue
    accentColor: const Color(0xFF7FFF00), // Lime Glow
  ),
];
