import 'package:flutter/material.dart';
import '../model/food.dart';
import 'food_tile.dart';

class FoodList extends StatelessWidget {
  final List<Items> items;

  const FoodList({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return FoodTile(product: items[index]);
      },
    );
  }
}
