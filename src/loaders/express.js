const express = require('express');
const cors = require('cors');

const config = require('../config');
const routes = require('../api');

exports.init = async ({ app }) => {

  app.get('/status', (req, res) => { res.status(200).end(); });
  app.head('/status', (req, res) => { res.status(200).end(); });
  app.enable('trust proxy');

  app.use(cors());
  app.use(require('morgan')('dev'));
  app.use(express.json());
  app.use(express.urlencoded({ extended: false }));

  // Load API routes
  app.use(config.api.prefix, routes);

  return app;
}
