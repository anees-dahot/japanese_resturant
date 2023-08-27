import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:japanese_resturant/components/colors.dart';
import 'package:provider/provider.dart';

import '../components/button.dart';
import '../model/food.dart';
import '../model/shop.dart';
import 'home_screen.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}


void removeCart(Items food, BuildContext context){
final shop = context.read<Shop>();

shop.removeCart(food);
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<Shop>(
      builder: (context, shop, child) {
        return Scaffold(
          backgroundColor: redColor,
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              'Cart Page',
              style: GoogleFonts.raleway(
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
            elevation: 0,
          ),
          body: Column(
            children: [
              Expanded(
                flex: 7,
                  child: ListView.builder(
                      shrinkWrap: true,
                      
                      itemCount: shop.cart.length,
                      itemBuilder: (context, index) {
                        final food = shop.cart[index];
                        final foodName = food.name;
                        final price = food.price;
                        final image = food.imageUrl;
          
                        return Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Container(
                              height: 80,
                              width: 400,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Image.asset(
                                    image,
                                    width: 60,
                                    height: 60,
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        foodName,
                                        style: GoogleFonts.dmSerifDisplay(
                                          fontSize: 18,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 100,
                                  ),
                                  Text(
                                    "\$$price",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(onPressed:()=> removeCart(food, context), icon: const Icon(Icons.delete))
                                ],
                              ),
                            ));
                      }
                      )
                      ),
                      Expanded(
                        flex: 1,
                        child:  Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                          child: CustomButton(
                                    icon: Icons.arrow_right_alt,
                                    width: 350, height:55,
                                    text: 'Get Started', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) =>  const HomeScreen())),),
                        ))
            ],
          ),
        );
      },
    );
  }
}
