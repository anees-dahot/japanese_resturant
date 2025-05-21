const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
  name: { type: String, required: true },
  description: { type: String },
  price: { type: Number, required: true, min: 0 },
  imageUrl: { type: String },
  category: { type: String },
  stock: { type: Number, default: 0, min: 0 },
});

module.exports = mongoose.model('Product', productSchema);
