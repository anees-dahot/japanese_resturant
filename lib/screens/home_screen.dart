import 'package:japanese_resturant/screens/cart_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:japanese_resturant/components/colors.dart';
import 'package:japanese_resturant/components/food_tile.dart';
import 'package:japanese_resturant/screens/details_screen.dart';

import '../model/shop.dart';

class HomeScreen extends StatefulWidget {



   const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch initial data when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<Shop>(context, listen: false).fetchProducts();
      Provider.of<Shop>(context, listen: false).fetchCart(); // Also fetch cart
    });
  }

  void navigateToDetails(BuildContext context, Items foodItem) { // Changed to pass Items object
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetiaslScreen(shop: foodItem)),
    );
  }

  void navigateToCartPage() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const CartPage()));
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer for better reactivity and to access Shop instance
    return Consumer<Shop>(
      builder: (context, shop, child) {
        final foodMenu = shop.foodMenu; // Get foodMenu from shop

        return Scaffold(
          backgroundColor: scaffoldBgColor,
          appBar: AppBar(
        title: Text(
          'Tokyo',
          style: GoogleFonts.raleway(
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
        ),
        centerTitle: true,
        backgroundColor: scaffoldBgColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
         
          IconButton(onPressed:   navigateToCartPage, icon: const Icon(Icons.shopping_bag)),
           const SizedBox(width: 20,),
        ],
        leading: const Icon(Icons.menu),
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              width: 400,
              decoration: BoxDecoration(
                color: redColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(13.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Get 32% promo',
                            style: GoogleFonts.dmSerifDisplay(
                                fontSize: 22, color: Colors.white)),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          height: 40,
                          width: 140,
                          decoration: BoxDecoration(
                            color: trnsColor,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Center(
                              child: Text(
                            'Buy Food',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          )),
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                    const Center(
                      child: Image(
                          height: 100,
                          width: 100,
                          image: AssetImage('assets/images/ramen.png')),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Container(
              height: 50,
              width: 400,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Search Here',
                  prefixIcon: Icon(Icons.search),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromARGB(0, 255, 255, 255),
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromARGB(0, 255, 255, 255),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            const Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Food Menu',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            shop.isLoadingProducts
                ? const Center(child: CircularProgressIndicator())
                : shop.productError != null
                    ? Center(child: Text('Error: ${shop.productError}'))
                    : SizedBox(
                        height: 200, // You can adjust the height as needed
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: foodMenu.length,
                          itemBuilder: (context, index) {
                            final foodItem = foodMenu[index];
                            return GestureDetector(
                              onTap: () {
                                navigateToDetails(context, foodItem); // Pass Items object
                              },
                              child: FoodTile(product: foodItem),
                            );
                          },
                        ),
                      ),
            const SizedBox(
              height: 20,
            ),
            const Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Popular Foods',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            shop.isLoadingProducts
                ? const Center(child: CircularProgressIndicator()) // Also show loading for popular foods if needed
                : shop.productError != null
                    ? Center(child: Text('Error: ${shop.productError}'))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: foodMenu.length,
                        itemBuilder: (context, index) {
                          final foodItem = foodMenu[index];
                          return Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: GestureDetector(
                              onTap: () => navigateToDetails(context, foodItem), // Pass Items object
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
                            // Use Image.network if imageUrl is a URL, or handle local assets if it's a path
                            // Assuming imageUrl might be a network URL from the API
                            foodItem.imageUrl.startsWith('http')
                                ? Image.network(
                                    foodItem.imageUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Image.asset('assets/images/default.png',  width: 60, height: 60, fit: BoxFit.cover), // Fallback
                                  )
                                : Image.asset(
                                    foodItem.imageUrl, // Assuming it could be a local asset path
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Image.asset('assets/images/default.png', width: 60, height: 60, fit: BoxFit.cover), // Fallback
                                  ),
                            const SizedBox(
                              width: 20,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  foodItem.name,
                                  style: GoogleFonts.dmSerifDisplay(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(foodItem.rating) // Assuming rating is still a string
                              ],
                            ),
                            const Spacer(), // Use Spacer to push price to the right
                            Text(
                              "\$${foodItem.price.toStringAsFixed(2)}", // Format price
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 20), // Add some padding to the right
                          ],
                        ),
                              ),
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
        );
      },
    );
  }
}
