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
                Image.asset(height: 80, width: 80, product.imageUrl),
                SizedBox(height: 10,),
                Text(
                  product.name,
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w200
                  ),
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("\$" + product.price, style: TextStyle(fontWeight: FontWeight.bold),),
                    Row(children: [
                      Icon(Icons.star, color: starClr, size: 18,),
                      SizedBox(width: 5,),
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
