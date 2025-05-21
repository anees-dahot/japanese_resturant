const request = require('supertest');
const app = require('../index'); // Your Express app
const Product = require('../models/Product');
const mongoose = require('mongoose');

describe('Product Routes', () => {
  let productId;

  // Test for POST /api/products (create product)
  describe('POST /api/products', () => {
    it('should create a new product', async () => {
      const res = await request(app)
        .post('/api/products')
        .send({
          name: 'Test Product',
          description: 'This is a test product',
          price: 100,
          category: 'Test Category',
          stock: 10,
        });
      expect(res.statusCode).toEqual(201);
      expect(res.body).toHaveProperty('_id');
      expect(res.body.name).toBe('Test Product');
      productId = res.body._id; // Save for later tests
    });

    it('should return 400 for missing required fields (name)', async () => {
      const res = await request(app)
        .post('/api/products')
        .send({
          description: 'This is a test product',
          price: 100,
        });
      expect(res.statusCode).toEqual(400);
    });
     it('should return 400 for missing required fields (price)', async () => {
      const res = await request(app)
        .post('/api/products')
        .send({
          name: 'Test Product No Price',
          description: 'This is a test product',
        });
      expect(res.statusCode).toEqual(400);
    });
    it('should return 400 for invalid price (negative)', async () => {
      const res = await request(app)
        .post('/api/products')
        .send({
          name: 'Test Product Negative Price',
          price: -10,
        });
      expect(res.statusCode).toEqual(400);
    });
  });

  // Test for GET /api/products (get all products)
  describe('GET /api/products', () => {
    it('should fetch all products', async () => {
      const res = await request(app).get('/api/products');
      expect(res.statusCode).toEqual(200);
      expect(Array.isArray(res.body)).toBe(true);
      expect(res.body.length).toBeGreaterThanOrEqual(1); // Assuming the product from POST test is there
    });
  });

  // Test for GET /api/products/:id (get single product)
  describe('GET /api/products/:id', () => {
    it('should fetch a single product by ID', async () => {
      const res = await request(app).get(`/api/products/${productId}`);
      expect(res.statusCode).toEqual(200);
      expect(res.body).toHaveProperty('_id', productId);
    });

    it('should return 404 for a non-existent product ID', async () => {
      const res = await request(app).get(`/api/products/${new mongoose.Types.ObjectId()}`);
      expect(res.statusCode).toEqual(404);
    });

    it('should return 500 for an invalid product ID format', async () => {
      const res = await request(app).get('/api/products/invalidIdFormat');
      // Mongoose/MongoDB driver might return a CastError which our handler turns into 500
      // or if specific CastError handling is added, it might be 400.
      // For now, checking if it's not 200. Ideally, should be 400 or 404.
      // The current global error handler will make it a 500 if not specified.
      // Let's refine error handler for CastError to return 400 in a future step if needed.
      // For now, the default behavior of Mongoose for invalid ObjectId format is a CastError leading to 500.
      expect(res.statusCode).toEqual(500);
    });
  });

  // Test for PUT /api/products/:id (update product)
  describe('PUT /api/products/:id', () => {
    it('should update an existing product', async () => {
      const res = await request(app)
        .put(`/api/products/${productId}`)
        .send({
          name: 'Updated Test Product',
          price: 150,
        });
      expect(res.statusCode).toEqual(200);
      expect(res.body.name).toBe('Updated Test Product');
      expect(res.body.price).toBe(150);
    });

    it('should return 404 for updating a non-existent product ID', async () => {
      const res = await request(app)
        .put(`/api/products/${new mongoose.Types.ObjectId()}`)
        .send({ name: 'Non Existent' });
      expect(res.statusCode).toEqual(404);
    });

    it('should return 400 for invalid update data (e.g. negative price)', async () => {
       const res = await request(app)
        .put(`/api/products/${productId}`)
        .send({ price: -50 });
      expect(res.statusCode).toEqual(400); // Mongoose validation should trigger
    });
  });

  // Test for DELETE /api/products/:id (delete product)
  describe('DELETE /api/products/:id', () => {
    it('should delete a product by ID', async () => {
      const res = await request(app).delete(`/api/products/${productId}`);
      expect(res.statusCode).toEqual(200);
      expect(res.body.message).toBe('Deleted Product');

      // Verify product is actually deleted
      const getRes = await request(app).get(`/api/products/${productId}`);
      expect(getRes.statusCode).toEqual(404);
    });

    it('should return 404 for deleting a non-existent product ID', async () => {
      const res = await request(app).delete(`/api/products/${new mongoose.Types.ObjectId()}`);
      expect(res.statusCode).toEqual(404);
    });
  });
});
