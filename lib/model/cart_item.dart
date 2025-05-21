import 'food.dart'; // Assuming food.dart contains your Items class

class CartItem {
  final Items food; // The product details
  int quantity;   // The quantity of this item in the cart

  CartItem({required this.food, required this.quantity});

  // Optional: Add methods like increment/decrement quantity if needed directly here
  // Or a copyWith method for easier state updates
}
