import 'package:flutter/material.dart';

/// Maps a string key (stored in the database) to an icon.
/// Storing a key instead of an IconData keeps Firestore compatibility.
class CategoryIcons {
  CategoryIcons._();

  static const Map<String, IconData> icons = {
    'coffee': Icons.local_cafe_outlined,
    'drink': Icons.local_drink_outlined,
    'fastfood': Icons.fastfood_outlined,
    'dish': Icons.restaurant_outlined,
    'dessert': Icons.cake_outlined,
  };

  static IconData byKey(String key) => icons[key] ?? Icons.category_outlined;
}