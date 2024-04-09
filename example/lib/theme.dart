import 'package:flutter/material.dart';

final roundedRectangleShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(60),
);

final appTheme = ThemeData(
  colorSchemeSeed: Colors.blue,
  brightness: Brightness.light,
  chipTheme: ChipThemeData(
    shape: roundedRectangleShape,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(shape: roundedRectangleShape),
  ),
  cardTheme: CardTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(32),
    ),
  ),
);
