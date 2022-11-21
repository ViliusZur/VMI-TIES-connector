// packages
const express = require('express');
const createError = require('http-errors');

// configs
const config = require('./config');
const loaders = require('./loaders');

async function startServer() {
  const app = express();
  
  await loaders.init({ expressApp: app });

  app.listen(config.port || 3000, err => {
    if (err) {
      console.log(err);
      return;
    }
    console.log(`Your server is ready!`);
  });

  // catch 404 and forward to error handler
  app.use(function(req, res, next) {
    next(createError(404));
  });

  // error handler
  app.use(function(err, req, res, next) {
    // creates a red ERROR log
    console.log("\x1b[31m%s\x1b[0m", "ERROR", err);
    const error = {
      status: err.status || 500,
      message: err.message,
    };
    res.status(err.status || 500);
    res.send(error);
  });
}

startServer();