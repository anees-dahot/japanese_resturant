const express = require('express');
const connectDB = require('./config/db');
const productRoutes = require('./routes/productRoutes');
const cartRoutes = require('./routes/cartRoutes'); // Import cart routes
const checkoutRoutes = require('./routes/checkoutRoutes'); // Import checkout routes
const userRoutes = require('./routes/userRoutes'); // Import user routes
const errorHandler = require('./middleware/errorHandler'); // Import error handler

const app = express();

// Middleware
app.use(express.json());

// Connect to Database
connectDB();

// Routes
app.use('/api/products', productRoutes);
app.use('/api/cart', cartRoutes); // Mount cart routes
app.use('/api/checkout', checkoutRoutes); // Mount checkout routes
app.use('/api/users', userRoutes); // Mount user routes

// Error Handler Middleware - should be last
app.use(errorHandler);

const PORT = process.env.PORT || 3000;

if (require.main === module) {
  app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
}

module.exports = app; // Export app for testing
