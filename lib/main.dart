import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/pages/home_page.dart';
import 'package:todo/provider/task_provider.dart';

void main() {
  runApp(MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => TaskProvider())],
      child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            accentColor: Colors.orange, primaryColor: const Color(0xFFDE4435)),
        home: HomePage());
  }
}
