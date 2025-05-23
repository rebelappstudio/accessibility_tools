import 'package:flutter/material.dart';

final roundedRectangleShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(60),
);

ThemeData get lightTheme => ThemeData(
  colorSchemeSeed: Colors.blue,
  brightness: Brightness.light,
  chipTheme: ChipThemeData(shape: roundedRectangleShape),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(shape: roundedRectangleShape),
  ),
  cardTheme: CardThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
  ),
);

ThemeData get darkTheme => ThemeData(
  colorSchemeSeed: Colors.blue,
  brightness: Brightness.dark,
  chipTheme: ChipThemeData(shape: roundedRectangleShape),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(shape: roundedRectangleShape),
  ),
  cardTheme: CardThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
  ),
);
