import 'package:flutter/material.dart';

class Priority {
  final String dbPriority = 'priority';
}

enum Status {
  PRIORITY_1,
  PRIORITY_2,
  PRIORITY_3,
  PRIORITY_4,
}

var priorityColor = [Colors.red, Colors.orange, Colors.yellow, Colors.black];

var priorityText = ["Priority 1", "Priority 2", "Priority 3", "Priority 4"];
