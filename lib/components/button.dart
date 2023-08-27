import 'package:flutter/material.dart';
import 'package:japanese_resturant/components/colors.dart';

class CustomButton extends StatelessWidget {

  String text;
  double width;
  double height;
  IconData? icon;

  void Function()? onTap;
   CustomButton({super.key, required this.text, required this.onTap, required this.width, required this.height, this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
      
        height: height,
        width:width,
        decoration: BoxDecoration(
          color: trnsColor,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(text, style: TextStyle(fontSize: 16, color: Colors.white),),
            SizedBox(width: 10,),
            Icon(icon, color: Colors.white,)
          ],
        ),
      ),
    );
  }
}