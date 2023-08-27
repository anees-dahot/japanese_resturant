import 'package:flutter/material.dart';
import 'package:japanese_resturant/model/shop.dart';
import 'package:japanese_resturant/screens/intro_screen.dart';
import 'package:provider/provider.dart';

import 'components/colors.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => Shop(),
    child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      theme: ThemeData(
  colorScheme: ThemeData().colorScheme.copyWith(
    primary: redColor,
  ),
),
      debugShowCheckedModeBanner: false,
      home: const IntorScreen(),
  );
  
  }}