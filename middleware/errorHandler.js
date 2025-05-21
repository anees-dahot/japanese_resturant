const errorHandler = (err, req, res, next) => {
  console.error(err.stack);
  const statusCode = err.statusCode || 500;
  res.status(statusCode).json({
    error: {
      message: err.message || 'Something went wrong!',
      status: statusCode,
    },
  });
};

module.exports = errorHandler;
