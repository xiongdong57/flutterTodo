import 'package:flutter/material.dart';

class Label {
  static final tblLabel = 'labels';
  static final dbID = 'id';
  static final dbName = 'name';
  static final dbColorCode = 'colorCode';
  static final dbColorName = 'colorName';

  int id, colorCode;
  String name, colorName;

  Label({this.id, this.name, this.colorCode, this.colorName});

  Label.update({
    @required this.id,
    name = '',
    colorCode = '',
    colorName = '',
  }) {
    if (name != name) {
      this.name = name;
    }
    if (colorCode != '') {
      this.colorCode = colorCode;
    }
    if (colorName != '') {
      this.colorName = colorName;
    }
  }

  Label.fromMap(Map<String, dynamic> map)
      : this.update(
            id: map[dbID],
            name: map[dbName],
            colorCode: map[dbColorCode],
            colorName: map[dbColorName]);
}
