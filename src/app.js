const express = require('express');

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
}

startServer();