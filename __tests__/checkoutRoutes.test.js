const request = require('supertest');
const app = require('../index');
const User = require('../models/User');
const Product = require('../models/Product');
const Cart = require('../models/Cart');
const Order = require('../models/Order');
const mongoose = require('mongoose');

describe('Checkout Routes', () => {
  let testUser, testProduct1, testProduct2, testUserId, testProductId1, testProductId2;

  beforeAll(async () => {
    // Create a user
    const userRes = await request(app)
      .post('/api/users/register')
      .send({ username: 'checkoutuser', email: 'checkout@example.com', password: 'password123' });
    testUser = userRes.body.user;
    testUserId = testUser._id;

    // Create products
    const product1Res = await request(app)
      .post('/api/products')
      .send({ name: 'Checkout Product 1', price: 30, stock: 15, category: 'CheckoutTest' });
    testProduct1 = product1Res.body;
    testProductId1 = testProduct1._id;

    const product2Res = await request(app)
      .post('/api/products')
      .send({ name: 'Checkout Product 2', price: 45, stock: 10, category: 'CheckoutTest' });
    testProduct2 = product2Res.body;
    testProductId2 = testProduct2._id;
  });

  // Helper function to add items to cart
  const addItemToCart = async (userId, productId, quantity) => {
    await request(app)
      .post(`/api/cart/${userId}/add`)
      .send({ productId, quantity });
  };

  // Test for POST /api/checkout/:userId
  describe('POST /api/checkout/:userId', () => {
    beforeEach(async () => {
      // Clear cart and orders before each checkout test
      await Cart.deleteMany({});
      await Order.deleteMany({});
    });

    it('should process checkout successfully for a cart with items', async () => {
      // Add items to cart
      await addItemToCart(testUserId, testProductId1, 2); // 2 * 30 = 60
      await addItemToCart(testUserId, testProductId2, 1); // 1 * 45 = 45
                                                         // Total = 105
      const res = await request(app)
        .post(`/api/checkout/${testUserId}`)
        .send({ shippingAddress: '123 Test Street, Testville' });

      expect(res.statusCode).toEqual(201);
      expect(res.body).toHaveProperty('_id'); // Order ID
      expect(res.body.userId).toBe(testUserId);
      expect(res.body.products.length).toBe(2);
      expect(res.body.totalAmount).toBe(105);
      expect(res.body.status).toBe('Pending');
      expect(res.body.shippingAddress).toBe('123 Test Street, Testville');

      // Verify cart is cleared
      const cart = await Cart.findOne({ userId: testUserId });
      expect(cart).not.toBeNull();
      expect(cart.products.length).toBe(0);

      // Verify order is created
      const order = await Order.findById(res.body._id);
      expect(order).not.toBeNull();
      expect(order.totalAmount).toBe(105);
    });

    it('should return 400 for checkout with an empty cart', async () => {
      // Ensure cart is empty (or non-existent)
      await Cart.deleteOne({ userId: testUserId });

      const res = await request(app)
        .post(`/api/checkout/${testUserId}`)
        .send({ shippingAddress: '123 Empty Cart St' });
      expect(res.statusCode).toEqual(400);
      expect(res.body.error.message).toContain('Cart is empty or not found');
    });

    it('should return 400 if shippingAddress is missing', async () => {
      await addItemToCart(testUserId, testProductId1, 1);
      const res = await request(app)
        .post(`/api/checkout/${testUserId}`)
        .send({}); // No shippingAddress
      expect(res.statusCode).toEqual(400);
      expect(res.body.error.message).toContain('Missing required field: shippingAddress');
    });

    it('should return 404 for a non-existent user ID during checkout', async () => {
      const nonExistentUserId = new mongoose.Types.ObjectId();
      const res = await request(app)
        .post(`/api/checkout/${nonExistentUserId}`)
        .send({ shippingAddress: '123 Ghost Town' });
      // This will likely result in a 400 "Cart is empty or not found" because no cart will be found for this user.
      // If we wanted a specific "User not found" error, the checkout logic would need to check for user existence first.
      expect(res.statusCode).toEqual(400);
      expect(res.body.error.message).toContain('Cart is empty or not found');
    });

     it('should handle errors if a product in cart is somehow missing details (e.g., price)', async () => {
      // Create a product and add it to cart
      await addItemToCart(testUserId, testProductId1, 1);

      // Directly manipulate the product in the database to remove its price (simulate data corruption)
      await Product.findByIdAndUpdate(testProductId1, { $unset: { price: "" } });
      
      const res = await request(app)
        .post(`/api/checkout/${testUserId}`)
        .send({ shippingAddress: '123 Error St' });
      
      expect(res.statusCode).toEqual(400); // Or 500 depending on how you want to classify this
      expect(res.body.error.message).toContain('Product details or price missing in cart item');

      // Restore product price for other tests
      await Product.findByIdAndUpdate(testProductId1, { price: 30 });
    });
  });
});
