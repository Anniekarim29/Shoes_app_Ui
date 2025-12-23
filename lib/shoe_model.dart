import 'package:flutter/material.dart';

class Shoe {
  final String name;
  final String description;
  final String price;
  final String imagePath;
  final Color backgroundColor;
  final Color accentColor;

  Shoe({
    required this.name,
    required this.description,
    required this.price,
    required this.imagePath,
    required this.backgroundColor,
    required this.accentColor,
  });
}

final List<Shoe> shoes = [
  Shoe(
    name: 'NIKE AIR MAX 270',
    description: 'The Nike Air Max 270 delivers visible cushioning under every step.',
    price: '\$150.00',
    imagePath: 'assets/shoes1.png',
    backgroundColor: const Color(0xFF0A1F1A), // Dark Green
    accentColor: const Color(0xFFCCFF00), // Volt
  ),
  Shoe(
    name: 'NIKE REACT ELEMENT',
    description: 'Experience the next level of comfort with React foam technology.',
    price: '\$130.00',
    imagePath: 'assets/shoes2.png',
    backgroundColor: const Color(0xFF140C21), // Dark Purple
    accentColor: const Color(0xFFFFD700), // Gold
  ),
  Shoe(
    name: 'NIKE ZOOM FLY 3',
    description: 'Built for speed and comfort during your long runs.',
    price: '\$160.00',
    imagePath: 'assets/shoes3.png',
    backgroundColor: const Color(0xFF081426), // Dark Blue
    accentColor: const Color(0xFFFF4500), // Orange Red
  ),
  Shoe(
    name: 'NIKE AIR FORCE 1',
    description: 'The legend lives on in the Nike Air Force 1.',
    price: '\$100.00',
    imagePath: 'assets/shoes4.png',
    backgroundColor: const Color(0xFF1B1B1B), // Dark Gray
    accentColor: const Color(0xFF00FFFF), // Cyan
  ),
  Shoe(
    name: 'NIKE JOYRIDE RUN',
    description: 'Tiny foam beads underfoot provide personalized cushioning.',
    price: '\$180.00',
    imagePath: 'assets/shoes5.png',
    backgroundColor: const Color(0xFF1B0A0A), // Dark Maroon
    accentColor: const Color(0xFFFF69B4), // Hot Pink
  ),
  Shoe(
    name: 'NIKE PEGASUS 37',
    description: 'The trusted favorite returns with updated cushioning.',
    price: '\$120.00',
    imagePath: 'assets/shoes6.png',
    backgroundColor: const Color(0xFF0F121C), // Midnight
    accentColor: const Color(0xFF7FFF00), // Chartreuse
  ),
];
