import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:japanese_resturant/components/button.dart';
import 'package:japanese_resturant/components/colors.dart';
import 'package:japanese_resturant/screens/home_screen.dart';

class IntorScreen extends StatefulWidget {
  const IntorScreen({super.key});

  @override
  State<IntorScreen> createState() => _IntorScreenState();
}

class _IntorScreenState extends State<IntorScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: redColor,
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('SUSHIMAN' ,textAlign: TextAlign.left,style: GoogleFonts.dmSerifDisplay(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w300,),),
                const SizedBox(height: 20,),      
                const Center(child: Image( width: 270, height: 270,image: AssetImage('assets/images/sticks.png'))),
                const SizedBox(height: 20,),
                Text('THE TASTE OF JAPANESE FOOD', style: GoogleFonts.dmSerifDisplay(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w700, height: 1.2)),
                const SizedBox(height: 20,),
          const Text('Feel the taste of most popular Japanese food from anywhere and anytime', style: TextStyle(fontSize: 14, color: Colors.white, height: 1.5)),
          const SizedBox(height: 20,),
          CustomButton(
            icon: Icons.arrow_right_alt,
            width: 400, height:55,
            text: 'Get Started', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) =>  HomeScreen())),)
              ],
            ),
          ),
        ),
      ),
    );
  }
}