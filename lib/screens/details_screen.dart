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

  void addToCartt(BuildContext context) async { // Made async
    if (quantity > 0) {
      final shop = context.read<Shop>();
      try {
        // Ensure widget.shop.id is not null before calling addToCart
        if (widget.shop.id == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Product ID is missing.')),
          );
          return;
        }
        await shop.addToCart(widget.shop, quantity); // Use await
        showDialog(
          context: context,
          barrierDismissible: false, // User must tap button!
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Success!'),
            content: const Text('Item added to your cart.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          ),
        );
      } catch (e) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to add item to cart: ${e.toString()}'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a quantity.')),
      );
    }
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
                // Updated Image handling
                widget.shop.imageUrl.startsWith('http')
                    ? Image.network(
                        widget.shop.imageUrl,
                        width: 170,
                        height: 170,
                        fit: BoxFit.contain, // Use contain to see the whole image
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset('assets/images/default.png', width: 170, height: 170, fit: BoxFit.contain),
                      )
                    : Image.asset(
                        widget.shop.imageUrl, // Assuming it could be a local asset path
                        width: 170,
                        height: 170,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset('assets/images/default.png', width: 170, height: 170, fit: BoxFit.contain),
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
                Text(
                  widget.shop.description ?? 'No description available.', // Use actual description
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.justify,
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
                          '\$${widget.shop.price.toStringAsFixed(2)}', // Updated price display
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
                            Container( // Ensure quantity is at least 1 for addToCart logic
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
                      onTap: () => addToCartt(context), // Calls the updated function
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
