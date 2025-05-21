const express = require('express');
const router = express.Router();
const User = require('../models/User');
const bcrypt = require('bcryptjs');

// POST /register: Registers a new user
router.post('/register', async (req, res, next) => {
  const { username, email, password } = req.body;

  if (!username || !email || !password) {
    const error = new Error('Missing required fields: username, email, and password');
    error.statusCode = 400;
    return next(error);
  }

  try {
    let user = await User.findOne({ $or: [{ email }, { username }] });
    if (user) {
      const error = new Error('User already exists with this email or username');
      error.statusCode = 400;
      return next(error);
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    user = new User({
      username,
      email,
      password: hashedPassword,
    });

    await user.save();

    const userToReturn = user.toObject();
    delete userToReturn.password;
    res.status(201).json({ message: 'User registered successfully', user: userToReturn });

  } catch (err) {
    if (err.name === 'ValidationError') {
      err.statusCode = 400;
    }
    next(err);
  }
});

// POST /login: Logs in an existing user
router.post('/login', async (req, res, next) => {
  const { email, password } = req.body;

  if (!email || !password) {
    const error = new Error('Missing required fields: email and password');
    error.statusCode = 400;
    return next(error);
  }

  try {
    const user = await User.findOne({ email });
    if (!user) {
      const error = new Error('Invalid credentials');
      error.statusCode = 400;
      return next(error);
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      const error = new Error('Invalid credentials');
      error.statusCode = 400;
      return next(error);
    }

    const userToReturn = user.toObject();
    delete userToReturn.password;
    res.status(200).json({ message: 'Login successful', user: userToReturn });

  } catch (err) {
    next(err);
  }
});

module.exports = router;
