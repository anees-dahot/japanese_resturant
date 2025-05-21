module.exports = {
  testEnvironment: 'node',
  setupFilesAfterEnv: ['./jest.setup.js'], // For global setup like in-memory DB
  coveragePathIgnorePatterns: [
    '/node_modules/',
    '/config/',
    '/models/', // Often, models are simple data structures tested via routes
    'index.js', // Entry point, usually tested via endpoint tests
    'errorHandler.js' // Error handler is tested implicitly
  ]
};
