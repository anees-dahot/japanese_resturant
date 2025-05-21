import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:japanese_resturant/components/colors.dart';

import '../model/food.dart';

class FoodTile extends StatelessWidget {
  final Items product;

  const FoodTile({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          height: 200,
          width: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Updated Image handling
                SizedBox( // Constrain image size
                  height: 80,
                  width: 80,
                  child: product.imageUrl.startsWith('http')
                      ? Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset('assets/images/default.png', fit: BoxFit.cover), // Fallback
                        )
                      : Image.asset(
                          product.imageUrl, // Assuming it could be a local asset path
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset('assets/images/default.png', fit: BoxFit.cover), // Fallback
                        ),
                ),
                const SizedBox(height: 10,),
                Text(
                  product.name,
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w200
                  ),
                  maxLines: 1, // Prevent long names from breaking layout
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("\$${product.price.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold),), // Updated price
                    Row(children: [
                      const Icon(Icons.star, color: starClr, size: 18,),
                      const SizedBox(width: 5,),
                      Text(product.rating)
                    ],)
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
