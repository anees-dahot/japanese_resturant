const express = require('express');
const router = express.Router();
const Cart = require('../models/Cart');
const Product = require('../models/Product');
const User = require('../models/User'); // Assuming User model exists for userId validation later

// GET /:userId - Fetches the cart for the given userId
router.get('/:userId', async (req, res, next) => {
  try {
    const cart = await Cart.findOne({ userId: req.params.userId }).populate('products.productId');
    if (!cart) {
      const error = new Error('Cart not found for this user.');
      error.statusCode = 404;
      return next(error);
    }
    res.json(cart);
  } catch (err) {
    next(err);
  }
});

// POST /:userId/add - Adds a product to the cart
router.post('/:userId/add', async (req, res, next) => {
  const { productId, quantity } = req.body;
  const userId = req.params.userId;

  if (!productId) {
    const error = new Error('Missing required field: productId');
    error.statusCode = 400;
    return next(error);
  }
  if (quantity != null && (!Number.isInteger(quantity) || quantity < 1)) {
    const error = new Error('Quantity must be a positive integer.');
    error.statusCode = 400;
    return next(error);
  }


  try {
    const product = await Product.findById(productId);
    if (!product) {
      const error = new Error('Product not found');
      error.statusCode = 404;
      return next(error);
    }

    let cart = await Cart.findOne({ userId });

    if (!cart) {
      cart = new Cart({ userId, products: [] });
    }

    const productIndex = cart.products.findIndex(p => p.productId.toString() === productId);

    if (productIndex > -1) {
      cart.products[productIndex].quantity += quantity || 1;
    } else {
      cart.products.push({ productId, quantity: quantity || 1 });
    }

    const savedCart = await cart.save();
    await savedCart.populate('products.productId');
    res.status(200).json(savedCart);
  } catch (err) {
    if (err.name === 'ValidationError') {
      err.statusCode = 400;
    }
    next(err);
  }
});

// POST /:userId/remove - Removes a product from the cart
router.post('/:userId/remove', async (req, res, next) => {
  const { productId } = req.body;
  const userId = req.params.userId;

  if (!productId) {
    const error = new Error('Missing required field: productId');
    error.statusCode = 400;
    return next(error);
  }

  try {
    const cart = await Cart.findOne({ userId });
    if (!cart) {
      const error = new Error('Cart not found');
      error.statusCode = 404;
      return next(error);
    }

    cart.products = cart.products.filter(p => p.productId.toString() !== productId);

    const savedCart = await cart.save();
    await savedCart.populate('products.productId');
    res.json(savedCart);
  } catch (err) {
    if (err.name === 'ValidationError') {
      err.statusCode = 400;
    }
    next(err);
  }
});

// PUT /:userId/update - Updates the quantity of a product in the cart
router.put('/:userId/update', async (req, res, next) => {
  const { productId, quantity } = req.body;
  const userId = req.params.userId;

  if (!productId || quantity == null) {
    const error = new Error('Missing required fields: productId and quantity');
    error.statusCode = 400;
    return next(error);
  }

  if (!Number.isInteger(quantity) || quantity < 0) {
    const error = new Error('Quantity must be a non-negative integer.');
    error.statusCode = 400;
    return next(error);
  }

  try {
    const cart = await Cart.findOne({ userId });
    if (!cart) {
      const error = new Error('Cart not found');
      error.statusCode = 404;
      return next(error);
    }

    const productIndex = cart.products.findIndex(p => p.productId.toString() === productId);

    if (productIndex > -1) {
      if (quantity === 0) {
        cart.products.splice(productIndex, 1);
      } else {
        cart.products[productIndex].quantity = quantity;
      }
    } else {
      const error = new Error('Product not found in cart');
      error.statusCode = 404;
      return next(error);
    }

    const savedCart = await cart.save();
    await savedCart.populate('products.productId');
    res.json(savedCart);
  } catch (err) {
    if (err.name === 'ValidationError') {
      err.statusCode = 400;
    }
    next(err);
  }
});

module.exports = router;
