const request = require('supertest');
const app = require('../index');
const User = require('../models/User');
const mongoose = require('mongoose');

describe('User Routes', () => {
  const testUser = {
    username: 'testuser',
    email: 'test@example.com',
    password: 'password123',
  };
  let createdUser;

  // Test for POST /api/users/register
  describe('POST /api/users/register', () => {
    it('should register a new user successfully', async () => {
      const res = await request(app)
        .post('/api/users/register')
        .send(testUser);
      expect(res.statusCode).toEqual(201);
      expect(res.body).toHaveProperty('user');
      expect(res.body.user.username).toBe(testUser.username);
      expect(res.body.user.email).toBe(testUser.email);
      expect(res.body.user).not.toHaveProperty('password');
      createdUser = res.body.user; // Save for login test
    });

    it('should return 400 for duplicate email', async () => {
      const res = await request(app)
        .post('/api/users/register')
        .send({ ...testUser, username: 'anotheruser' }); // Same email, different username
      expect(res.statusCode).toEqual(400);
      expect(res.body.error.message).toContain('User already exists');
    });

    it('should return 400 for duplicate username', async () => {
      const res = await request(app)
        .post('/api/users/register')
        .send({ ...testUser, email: 'another@example.com' }); // Same username, different email
      expect(res.statusCode).toEqual(400);
      expect(res.body.error.message).toContain('User already exists');
    });

    it('should return 400 for missing required fields (e.g., password)', async () => {
      const res = await request(app)
        .post('/api/users/register')
        .send({ username: 'testuser2', email: 'test2@example.com' });
      expect(res.statusCode).toEqual(400);
      expect(res.body.error.message).toContain('Missing required fields');
    });

    it('should return 400 for invalid email format', async () => {
        const res = await request(app)
          .post('/api/users/register')
          .send({ username: 'invalidemailuser', email: 'invalidemail', password: 'password123' });
        expect(res.statusCode).toEqual(400);
        // Mongoose validation error for email format
        expect(res.body.error.message).toContain('Please fill a valid email address');
      });

    it('should return 400 for password too short', async () => {
    const res = await request(app)
        .post('/api/users/register')
        .send({ username: 'shortpass', email: 'short@pass.com', password: '123' });
    expect(res.statusCode).toEqual(400);
    // Mongoose validation error for password length
    expect(res.body.error.message).toContain('is shorter than the minimum allowed length (6)');
    });
  });

  // Test for POST /api/users/login
  describe('POST /api/users/login', () => {
    it('should login an existing user successfully', async () => {
      const res = await request(app)
        .post('/api/users/login')
        .send({ email: testUser.email, password: testUser.password });
      expect(res.statusCode).toEqual(200);
      expect(res.body).toHaveProperty('user');
      expect(res.body.user.email).toBe(testUser.email);
      expect(res.body.user).not.toHaveProperty('password');
    });

    it('should return 400 for incorrect password', async () => {
      const res = await request(app)
        .post('/api/users/login')
        .send({ email: testUser.email, password: 'wrongpassword' });
      expect(res.statusCode).toEqual(400);
      expect(res.body.error.message).toBe('Invalid credentials');
    });

    it('should return 400 for user not found (incorrect email)', async () => {
      const res = await request(app)
        .post('/api/users/login')
        .send({ email: 'nonexistent@example.com', password: 'password123' });
      expect(res.statusCode).toEqual(400);
      expect(res.body.error.message).toBe('Invalid credentials');
    });

     it('should return 400 for missing email', async () => {
      const res = await request(app)
        .post('/api/users/login')
        .send({ password: 'password123' });
      expect(res.statusCode).toEqual(400);
      expect(res.body.error.message).toContain('Missing required fields');
    });

    it('should return 400 for missing password', async () => {
      const res = await request(app)
        .post('/api/users/login')
        .send({ email: testUser.email });
      expect(res.statusCode).toEqual(400);
      expect(res.body.error.message).toContain('Missing required fields');
    });
  });
});
