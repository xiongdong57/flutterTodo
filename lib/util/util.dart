import 'package:flutter/material.dart';

var monthNames = [
  "Jan",
  "Feb",
  "Mar",
  "Apr",
  "May",
  "Jun",
  "July",
  "Aug",
  "Sep",
  "Oct",
  "Nov",
  "Dec"
];

String getFormattedDate(int dueDate) {
  DateTime date = DateTime.fromMillisecondsSinceEpoch(dueDate);
  return '${monthNames[date.month - 1]} ${date.day}';
}

class ColorPalette {
  final String colorName;
  final int colorValue;
  bool isExpanded = false;

  ColorPalette(this.colorName, this.colorValue);

  bool operator ==(o) =>
      o is ColorPalette &&
      o.colorValue == colorValue &&
      o.colorName == colorName;
}

var colorsPalettes = <ColorPalette>[
  ColorPalette("Red", Colors.red.value),
  ColorPalette("Pink", Colors.pink.value),
  ColorPalette("Purple", Colors.purple.value),
  ColorPalette("Deep Purple", Colors.deepPurple.value),
  ColorPalette("Indigo", Colors.indigo.value),
  ColorPalette("Blue", Colors.blue.value),
  ColorPalette("Lightblue", Colors.lightBlue.value),
  ColorPalette("Cyan", Colors.cyan.value),
  ColorPalette("Teal", Colors.teal.value),
  ColorPalette("Green", Colors.green.value),
  ColorPalette("Lightgreen", Colors.lightGreen.value),
  ColorPalette("Lime", Colors.lime.value),
  ColorPalette("Yellow", Colors.yellow.value),
  ColorPalette("Amber", Colors.amber.value),
  ColorPalette("Orange", Colors.orange.value),
  ColorPalette("Deeporange", Colors.deepOrange.value),
  ColorPalette("Brown", Colors.brown.value),
  ColorPalette("Black", Colors.black.value),
  ColorPalette("Grey", Colors.grey.value),
];
