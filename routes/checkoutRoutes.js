const express = require('express');
const router = express.Router();
const Order = require('../models/Order');
const Cart = require('../models/Cart');
const User = require('../models/User'); // Assuming User model might be needed for validation or future use

// POST /:userId - Processes the checkout
router.post('/:userId', async (req, res, next) => {
  const userId = req.params.userId;
  const { shippingAddress } = req.body;

  if (!shippingAddress) {
    const error = new Error('Missing required field: shippingAddress');
    error.statusCode = 400;
    return next(error);
  }

  try {
    const cart = await Cart.findOne({ userId }).populate('products.productId');
    if (!cart || cart.products.length === 0) {
      const error = new Error('Cart is empty or not found.');
      error.statusCode = 400;
      return next(error);
    }

    let totalAmount = 0;
    const orderProducts = [];

    for (const item of cart.products) {
      if (!item.productId || item.productId.price == null) { // Ensure product and price exist
        const error = new Error('Product details or price missing in cart item.');
        error.statusCode = 400; // Or 500 if this indicates a server-side data integrity issue
        return next(error);
      }
      const price = item.productId.price;
      totalAmount += item.quantity * price;
      orderProducts.push({
        productId: item.productId._id,
        quantity: item.quantity,
        price: price,
      });
    }

    const newOrder = new Order({
      userId,
      products: orderProducts,
      totalAmount,
      shippingAddress, // Use validated shippingAddress
      status: 'Pending',
    });

    const savedOrder = await newOrder.save();

    cart.products = [];
    cart.updatedAt = Date.now();
    await cart.save();

    res.status(201).json(savedOrder);
  } catch (err) {
    if (err.name === 'ValidationError') {
      err.statusCode = 400;
    }
    console.error('Checkout error:', err); // Keep server-side log for debugging
    next(err);
  }
});

module.exports = router;
