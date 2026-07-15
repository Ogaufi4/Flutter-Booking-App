import 'package:flutter/material.dart';

class AppShadows {
  const AppShadows._();

  static const subtle = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  static const elevated = [
    BoxShadow(
      color: Color(0x10000000),
      blurRadius: 28,
      offset: Offset(0, 12),
    ),
  ];
}
