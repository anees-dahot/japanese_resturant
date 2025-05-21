import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/food.dart'; // Your Items model
import '../config.dart'; // Your apiBaseUrl

class ApiService {
  // Helper method to handle response and errors
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null; // Or handle as needed
      return jsonDecode(response.body);
    } else {
      print('API Error: ${response.statusCode} ${response.reasonPhrase}');
      print('Response body: ${response.body}');
      // Try to parse error message from backend if available
      String message = 'An error occurred';
      try {
        var errorData = jsonDecode(response.body);
        if (errorData['error'] != null && errorData['error']['message'] != null) {
          message = errorData['error']['message'];
        } else if (errorData['message'] != null) {
          message = errorData['message'];
        }
      } catch (e) {
        // Could not parse error, use default
      }
      throw Exception('Failed to load data from API: $message (Status Code: ${response.statusCode})');
    }
  }

  Future<List<Items>> getProducts() async {
    final response = await http.get(Uri.parse('$apiBaseUrl/api/products'));
    final data = _handleResponse(response);
    if (data is List) {
      return data.map((item) {
        // Note: Backend uses _id, ensure your Items model has an 'id' field.
        // The backend price is a number, ensure Items model expects double.
        return Items(
          id: item['_id'] as String?,
          name: item['name'] as String,
          price: (item['price'] as num).toDouble(), // Ensure price is parsed as num then to double
          imageUrl: item['imageUrl'] as String? ?? 'assets/images/default.png', // Handle missing imageUrl
          rating: item['rating']?.toString() ?? '0.0', // Backend doesn't have rating, provide default or adapt
          description: item['description'] as String?,
          category: item['category'] as String?,
        );
      }).toList();
    }
    return [];
  }

  // Note: The backend /api/cart/:userId currently returns a Cart document which includes userId and a list of products.
  Future<List<Map<String, dynamic>>> getCart(String userId) async {
    final response = await http.get(Uri.parse('$apiBaseUrl/api/cart/$userId'));
    final data = _handleResponse(response); // This should be the cart object
    if (data != null && data['products'] is List) {
      // Ensure products are actually maps, not just IDs
      // The backend populates productId, so each element in data['products']
      // should be like { productId: { product_fields ... }, quantity: X }
      List<dynamic> backendCartItems = data['products'];
      return backendCartItems.map((item) {
        if (item is Map<String, dynamic> && item['productId'] is Map<String, dynamic> && item['quantity'] is int) {
          return {
            'product': item['productId'] as Map<String, dynamic>,
            'quantity': item['quantity'] as int,
          };
        } else {
          // This case should ideally not happen if backend is consistent
          // Also check if productId is null (product might have been deleted from DB but still in cart)
          if (item is Map<String, dynamic> && item['productId'] == null && item['quantity'] is int) {
             // Handle case where product was deleted but still in cart by returning a placeholder or specific structure
             // For now, let's throw, but a more graceful handling might be needed for production.
             print('Warning: Cart item with ID ${item['_id']} refers to a deleted product.');
             // Or return a specific structure that Shop provider can filter out or mark.
             // For simplicity in this step, we throw.
             throw Exception('Cart item refers to a deleted product.');
          }
          throw Exception('Unexpected cart item format from API');
        }
      }).toList();
    }
    return []; // Return empty list if no products or unexpected structure
  }

  Future<void> addToCart(String userId, String productId, int quantity) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/api/cart/$userId/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'productId': productId, 'quantity': quantity}),
    );
    _handleResponse(response); // Throws exception on error
  }

  Future<void> removeFromCart(String userId, String productId) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/api/cart/$userId/remove'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'productId': productId}),
    );
    _handleResponse(response);
  }

  Future<void> updateCartItemQuantity(String userId, String productId, int quantity) async {
    final response = await http.put(
      Uri.parse('$apiBaseUrl/api/cart/$userId/update'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'productId': productId, 'quantity': quantity}),
    );
    _handleResponse(response);
  }
  
  // The backend POST /api/checkout/:userId expects a userId in params 
  // and can optionally take shippingAddress in the body.
  Future<Map<String, dynamic>> checkout(String userId, String shippingAddress) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/api/checkout/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'shippingAddress': shippingAddress}),
    );
    final data = _handleResponse(response);
    // Assuming the backend returns the created order object
    if (data is Map<String, dynamic>) {
        return data;
    }
    throw Exception('Checkout failed or returned unexpected data format.');
  }
}
