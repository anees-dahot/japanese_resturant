const mongoose = require('mongoose');

const url = 'mongodb://localhost:27017/ecommerce_app';

async function connectDB() {
  try {
    await mongoose.connect(url);
    console.log('Connected successfully to MongoDB using Mongoose');
  } catch (err) {
    console.error('Failed to connect to MongoDB using Mongoose', err);
    process.exit(1);
  }
}

module.exports = connectDB;
