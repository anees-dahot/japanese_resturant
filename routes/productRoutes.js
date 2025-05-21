const express = require('express');
const router = express.Router();
const Product = require('../models/Product');

// GET /: Fetches all products
router.get('/', async (req, res, next) => {
  try {
    const products = await Product.find();
    res.json(products);
  } catch (err) {
    next(err);
  }
});

// GET /:id: Fetches a single product by ID
router.get('/:id', async (req, res, next) => {
  try {
    const product = await Product.findById(req.params.id);
    if (product == null) {
      const error = new Error('Cannot find product');
      error.statusCode = 404;
      return next(error);
    }
    res.json(product);
  } catch (err) {
    next(err);
  }
});

// POST /: Creates a new product
router.post('/', async (req, res, next) => {
  const { name, price } = req.body;
  if (!name || price == null) {
    const error = new Error('Missing required fields: name and price');
    error.statusCode = 400;
    return next(error);
  }

  const product = new Product({
    name: req.body.name,
    description: req.body.description,
    price: req.body.price,
    imageUrl: req.body.imageUrl,
    category: req.body.category,
    stock: req.body.stock,
  });
  try {
    const newProduct = await product.save();
    res.status(201).json(newProduct);
  } catch (err) {
    if (err.name === 'ValidationError') {
      err.statusCode = 400;
    }
    next(err);
  }
});

// PUT /:id: Updates an existing product by ID
router.put('/:id', async (req, res, next) => {
  try {
    const product = await Product.findById(req.params.id);
    if (product == null) {
      const error = new Error('Cannot find product');
      error.statusCode = 404;
      return next(error);
    }

    // Basic validation: Ensure at least one field is being updated
    if (Object.keys(req.body).length === 0) {
        const error = new Error('No fields to update');
        error.statusCode = 400;
        return next(error);
    }
    
    if (req.body.name != null) {
      product.name = req.body.name;
    }
    if (req.body.description != null) {
      product.description = req.body.description;
    }
    if (req.body.price != null) {
      product.price = req.body.price;
    }
    if (req.body.imageUrl != null) {
      product.imageUrl = req.body.imageUrl;
    }
    if (req.body.category != null) {
      product.category = req.body.category;
    }
    if (req.body.stock != null) {
      product.stock = req.body.stock;
    }

    const updatedProduct = await product.save();
    res.json(updatedProduct);
  } catch (err) {
    if (err.name === 'ValidationError') {
      err.statusCode = 400;
    }
    next(err);
  }
});

// DELETE /:id: Deletes a product by ID
router.delete('/:id', async (req, res, next) => {
  try {
    const product = await Product.findById(req.params.id);
    if (product == null) {
      const error = new Error('Cannot find product');
      error.statusCode = 404;
      return next(error);
    }
    await product.deleteOne();
    res.json({ message: 'Deleted Product' });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
