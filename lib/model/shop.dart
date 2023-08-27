import 'package:flutter/material.dart';

import 'food.dart';

class Shop extends ChangeNotifier{

final List<Items> _foodMenu = [
    Items(
        name: 'Sushi',
        price: '20.0',
        imageUrl: 'assets/images/sushi.png',
        rating: '4.9'),
    Items(
        name: 'Ramen',
        price: '26.0',
        imageUrl: 'assets/images/ramen.png',
        rating: '5.0'),
    Items(
        name: 'Rice Ball',
        price: '17.0',
        imageUrl: 'assets/images/rice.png',
        rating: '5.0'),
    Items(
        name: 'Salmon',
        price: '30.0',
        imageUrl: 'assets/images/salmon.png',
        rating: '4.9'),
    Items(
        name: 'Sashimi',
        price: '23.0',
        imageUrl: 'assets/images/sashimi.png',
        rating: '4.7'),
    Items(
        name: 'Tempura',
        price: '20.0',
        imageUrl: 'assets/images/tempura.png',
        rating: '4.3'),
    Items(
        name: 'Tofu',
        price: '27.0',
        imageUrl: 'assets/images/tofu.png',
        rating: '4.8'),
    Items(
        name: 'Yakitori',
        price: '29.0',
        imageUrl: 'assets/images/yakitori.png',
        rating: '4.6'),
  ];


  final List<Items> _cart = [];


  List<Items> get foodMenu => _foodMenu;
  List<Items> get cart => _cart;


  void addToCart(Items foodItem, int quantity){
    for(int i = 0; i < quantity; i++ ){
    _cart.add(foodItem);}
    notifyListeners();
  }


void removeCart(Items food){
  _cart.remove(food);
  notifyListeners();
}




}