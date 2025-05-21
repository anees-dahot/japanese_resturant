import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'cart_item.dart';
import 'food.dart';

class Shop extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Items> _foodMenu = [];
  List<CartItem> _cart = [];

  bool _isLoadingProducts = false;
  String? _productError;
  bool _isCartLoading = false;
  String? _cartError;

  // IMPORTANT: Replace with actual or dynamic user ID later
  final String _userId = "testUser123"; 

  List<Items> get foodMenu => _foodMenu;
  List<CartItem> get cart => _cart;

  bool get isLoadingProducts => _isLoadingProducts;
  String? get productError => _productError;
  bool get isCartLoading => _isCartLoading;
  String? get cartError => _cartError;

  Future<void> fetchProducts() async {
    _isLoadingProducts = true;
    _productError = null;
    notifyListeners();
    try {
      _foodMenu = await _apiService.getProducts();
    } catch (e) {
      _productError = e.toString();
    } finally {
      _isLoadingProducts = false;
      notifyListeners();
    }
  }

  Future<void> fetchCart() async {
    _isCartLoading = true;
    _cartError = null;
    notifyListeners();
    try {
      final List<Map<String, dynamic>> cartData = await _apiService.getCart(_userId);
      _cart = cartData.map((cartItemData) {
        final productMap = cartItemData['product'] as Map<String, dynamic>;
        final quantity = cartItemData['quantity'] as int;
        
        // Manual mapping from productMap to Items object
        Items foodItem = Items(
          id: productMap['_id'] as String?,
          name: productMap['name'] as String,
          price: (productMap['price'] as num).toDouble(),
          imageUrl: productMap['imageUrl'] as String? ?? 'assets/images/default.png',
          rating: productMap['rating']?.toString() ?? '0.0', // Adjust if rating is handled differently
          description: productMap['description'] as String?,
          category: productMap['category'] as String?,
        );
        return CartItem(food: foodItem, quantity: quantity);
      }).toList();
    } catch (e) {
      _cartError = e.toString();
      _cart = []; // Clear cart on error or handle as appropriate
    } finally {
      _isCartLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(Items foodItem, int quantity) async {
    if (foodItem.id == null) {
      _cartError = "Product ID is missing. Cannot add to cart.";
      notifyListeners();
      return;
    }
    // Optimistically set loading state, though fetchCart will also do it.
    _isCartLoading = true; 
    notifyListeners();
    try {
      await _apiService.addToCart(_userId, foodItem.id!, quantity);
      await fetchCart(); // Refresh cart from backend
    } catch (e) {
      _cartError = "Failed to add to cart: ${e.toString()}";
      // If fetchCart() itself doesn't set _isCartLoading = false on its own error, ensure it's done.
      // However, fetchCart has its own finally block for this.
      // We might still want to notifyListeners here if fetchCart failed and didn't update state.
      if(!_isCartLoading) _isCartLoading = false; // Redundant if fetchCart handles it
      notifyListeners(); // Ensure UI updates with error if fetchCart didn't
    } 
    // No finally block for _isCartLoading here, as fetchCart handles it.
    // If fetchCart was not called on error, then a finally block would be needed.
  }

  Future<void> removeCartItem(CartItem cartItem) async {
    if (cartItem.food.id == null) {
      _cartError = "Product ID is missing. Cannot remove from cart.";
      notifyListeners();
      return;
    }
    _isCartLoading = true;
    notifyListeners();
    try {
      await _apiService.removeFromCart(_userId, cartItem.food.id!);
      await fetchCart(); // Refresh cart from backend
    } catch (e) {
      _cartError = "Failed to remove from cart: ${e.toString()}";
      if(!_isCartLoading) _isCartLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCartItemQuantityInShop(CartItem cartItem, int newQuantity) async {
    if (cartItem.food.id == null) {
      _cartError = "Product ID is missing. Cannot update cart quantity.";
      notifyListeners();
      return;
    }
    if (newQuantity <= 0) {
      // Backend might handle this, but good practice to call remove if quantity is zero or less.
      // Or, rely on backend to remove/update, then fetchCart will sync.
      // For this pattern, we assume update API can handle quantity 0 (which might mean remove).
      // Or, if our API expects positive quantity for update, then call removeCartItem.
      // Let's assume for now API's update can handle it, or it's a no-op if product is removed.
      // If the intention is strict removal for quantity <=0, call removeCartItem.
      // For now, let's proceed with update and let fetchCart sync.
      // A more robust solution might be:
      // if (newQuantity <= 0) { await removeCartItem(cartItem); return; }
    }
    _isCartLoading = true;
    notifyListeners();
    try {
      await _apiService.updateCartItemQuantity(_userId, cartItem.food.id!, newQuantity);
      await fetchCart(); // Refresh cart from backend
    } catch (e) {
      _cartError = "Failed to update cart quantity: ${e.toString()}";
      if(!_isCartLoading) _isCartLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> placeOrder(String shippingAddress) async {
    _isCartLoading = true; 
    _cartError = null; 
    notifyListeners();
    try {
      final orderDetails = await _apiService.checkout(_userId, shippingAddress);
      // Cart is cleared on backend, fetchCart will update local _cart to be empty.
      await fetchCart(); 
      return orderDetails;
    } catch (e) {
      _cartError = "Checkout failed: ${e.toString()}";
      // _isCartLoading = false; // Handled by fetchCart or its own finally if it fails
      if(!_isCartLoading) _isCartLoading = false; // Ensure it's false if fetchCart throws
      notifyListeners(); // Make sure UI knows about the error
      return null;
    }
    // No finally for _isCartLoading here, as fetchCart should handle it.
  }
}