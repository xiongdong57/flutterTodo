import 'package:flutter/material.dart';

class Project {
  static final tblProject = 'projects';
  static final dbID = 'id';
  static final dbName = 'name';
  static final dbColorCode = 'colorCode';
  static final dbColorName = 'colorName';

  int id, colorCode;
  String name, colorName;

  Project({this.id, this.name, this.colorName, this.colorCode});

  Project.create(this.name, this.colorName, this.colorCode);

  Project.update({@required this.id, name, colorCode = '', colorName = ''}) {
    if (name != '') {
      this.name = name;
    }

    if (colorCode != '') {
      this.colorCode = colorCode;
    }

    if (colorName != '') {
      this.colorName = colorName;
    }
  }

  Project.fromMap(Map<String, dynamic> map)
      : this.update(
            id: map[dbID],
            name: map[dbName],
            colorCode: map[dbColorCode],
            colorName: map[dbColorName]);

  Project.getInbox()
      : this.update(
            id: 1,
            name: 'Inbox',
            colorName: 'Grey',
            colorCode: Colors.grey.value);
}
