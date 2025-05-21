import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:japanese_resturant/components/colors.dart';
import 'package:provider/provider.dart';
import '../components/button.dart';
import '../model/cart_item.dart'; // Import CartItem
import '../model/shop.dart';
// import 'home_screen.dart'; // Not used for navigation in this version of button

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

// Removed standalone removeCart, will be part of Shop provider call

class _CartPageState extends State<CartPage> {
  final TextEditingController _shippingAddressController = TextEditingController(text: "123 Main St, Anytown"); // Placeholder

  void _showCheckoutResultDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
              if (title == 'Order Placed!') {
                // Optionally navigate away or clear cart further if needed
                // Provider.of<Shop>(context, listen: false).fetchCart(); // Refresh cart (should be empty)
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Shop>(
      builder: (context, shop, child) {
        return Scaffold(
          backgroundColor: redColor, // Or scaffoldBgColor for consistency
          appBar: AppBar(
            backgroundColor: redColor, // Match scaffold or theme
            iconTheme: const IconThemeData(color: Colors.white),
            centerTitle: true,
            title: Text(
              'My Cart',
              style: GoogleFonts.raleway(
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
            elevation: 0,
          ),
          body: Column(
            children: [
              if (shop.isCartLoading && shop.cart.isEmpty)
                const Expanded(
                  child: Center(child: CircularProgressIndicator(color: Colors.white)),
                )
              else if (shop.cartError != null && shop.cart.isEmpty)
                Expanded(
                  child: Center(child: Text('Error loading cart: ${shop.cartError}', style: const TextStyle(color: Colors.white))),
                )
              else if (shop.cart.isEmpty)
                const Expanded(
                  child: Center(child: Text('Your cart is empty.', style: TextStyle(color: Colors.white, fontSize: 18))),
                )
              else
                Expanded(
                  flex: 7,
                  child: ListView.builder(
                    itemCount: shop.cart.length,
                    itemBuilder: (context, index) {
                      final CartItem cartItem = shop.cart[index];
                      final foodName = cartItem.food.name;
                      final price = cartItem.food.price;
                      final image = cartItem.food.imageUrl;
                      final quantity = cartItem.quantity;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: image.startsWith('http')
                                ? Image.network(image, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Image.asset('assets/images/default.png', width: 50, height: 50, fit: BoxFit.cover))
                                : Image.asset(image, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Image.asset('assets/images/default.png', width: 50, height: 50, fit: BoxFit.cover)),
                            title: Text(foodName, style: GoogleFonts.dmSerifDisplay(fontSize: 17)),
                            subtitle: Text('\$${price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.black54),
                                  onPressed: () {
                                    if (cartItem.quantity > 1) {
                                      shop.updateCartItemQuantityInShop(cartItem, cartItem.quantity - 1);
                                    } else {
                                      shop.removeCartItem(cartItem); // Remove if quantity becomes 0
                                    }
                                  },
                                ),
                                Text('$quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, color: Colors.black54),
                                  onPressed: () {
                                    shop.updateCartItemQuantityInShop(cartItem, cartItem.quantity + 1);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () => shop.removeCartItem(cartItem),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    // Basic Shipping Address Input (can be improved)
                    if (shop.cart.isNotEmpty)
                      TextField(
                        controller: _shippingAddressController,
                        decoration: InputDecoration(
                          labelText: 'Shipping Address',
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                           enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    const SizedBox(height: 10),
                    if (shop.isCartLoading && !shop.cart.isEmpty) // Show loading indicator on button if cart is not empty
                       const Center(child: CircularProgressIndicator(color: Colors.white))
                    else if (shop.cart.isNotEmpty)
                      CustomButton(
                        icon: Icons.payment, // Changed icon
                        width: double.infinity, // Full width
                        height: 55,
                        text: 'Place Order (\$${shop.cart.fold(0.0, (sum, item) => sum + item.food.price * item.quantity).toStringAsFixed(2)})',
                        onTap: () async {
                          if (_shippingAddressController.text.isEmpty) {
                             _showCheckoutResultDialog(context, 'Error', 'Please enter a shipping address.');
                            return;
                          }
                          final orderDetails = await shop.placeOrder(_shippingAddressController.text);
                          if (orderDetails != null) {
                            _showCheckoutResultDialog(context, 'Order Placed!', 'Your order ID is ${orderDetails['_id']}. Total: \$${orderDetails['totalAmount'].toStringAsFixed(2)}');
                          } else {
                             _showCheckoutResultDialog(context, 'Order Failed', shop.cartError ?? 'Could not place order.');
                          }
                        },
                      )
                    else 
                      Container(), // Empty container if cart is empty and not loading
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _shippingAddressController.dispose();
    super.dispose();
  }
}
