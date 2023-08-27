import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:japanese_resturant/components/button.dart';
import 'package:provider/provider.dart';

import '../components/colors.dart';
import '../model/food.dart';
import '../model/shop.dart';

class DetiaslScreen extends StatefulWidget {
  final Items shop;

  const DetiaslScreen({super.key, required this.shop});

  @override
  State<DetiaslScreen> createState() => _DetiaslScreenState();
}

class _DetiaslScreenState extends State<DetiaslScreen> {
  int quantity = 0;

  void increaseQuan() {
    setState(() {
      quantity++;
    });
  }

  void decreaseQuan() {
    setState(() {
      if (quantity > 0) {
        quantity--;
      }
    });
  }

  void addToCartt(BuildContext context) {

    if(quantity > 0){
    final shop = context.read<Shop>();
    shop.addToCart(widget.shop, quantity);
    showDialog(
        context: context,
        builder: (BuildContext context) => const AlertDialog(
              content: Text('Added to cart'),
              
            ));}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        title: Text(
          widget.shop.name,
          style: GoogleFonts.raleway(
              color: Colors.black, fontWeight: FontWeight.w400),
        ),
        centerTitle: true,
        backgroundColor: scaffoldBgColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              children: [
                Image.asset(
                  widget.shop.imageUrl,
                  width: 170,
                  height: 170,
                  alignment: Alignment.topLeft,
                ),
                // SizedBox(height: 40,),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: starClr,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(widget.shop.rating)
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    widget.shop.name,
                    style: GoogleFonts.dmSerifDisplay(
                        fontSize: 28,
                        color: Colors.black,
                        fontWeight: FontWeight.w200),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Align(
                    alignment: Alignment.topLeft,
                    child: Text('Description',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15))),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  ' Made with seasoned rice and a variety of fillings,Delicious and filling rice balls are a Japanese favorite.Delicious and filling rice balls are a Japanese favorite. Made with seasoned rice and a variety of fillings, these handheld delights are perfect for snacking or a light meal. ',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Expanded(
            child: Container(
              height: 250,
              width: 400,
              decoration: const BoxDecoration(
                color: redColor,
              ),
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${widget.shop.price}',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Row(
                          children: [
                            Container(
                                height: 40,
                                width: 40,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle, color: trnsColor),
                                child: Center(
                                    child: IconButton(
                                        onPressed: () => decreaseQuan(),
                                        icon: const Center(
                                            child: Icon(
                                          Icons.remove,
                                          color: Colors.white,
                                        ))))),
                            SizedBox(
                              width: 40,
                              child: Center(
                                child: Text(
                                  quantity.toString(),
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                            Container(
                                height: 40,
                                width: 40,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle, color: trnsColor),
                                child: Center(
                                    child: IconButton(
                                        onPressed: () => increaseQuan(),
                                        icon: const Center(
                                            child: Icon(
                                          Icons.add,
                                          color: Colors.white,
                                        )))))
                          ],
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CustomButton(
                      text: 'Add To Cart',
                      onTap: () => addToCartt(context),
                      width: 300,
                      height: 50,
                      icon: Icons.arrow_right_alt,
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
