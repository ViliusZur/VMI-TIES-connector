require('dotenv').config()

const express = require('express');
const logger = require('morgan');
const createError = require('http-errors');
const mongoose = require('mongoose');

const vmiTiesRouter = require('./routes/vmiTies');
const vmiTiesCron = require('./lib/cron/vmiTies.cron')

const app = express();

// Connect to mongoDB database
mongoose.connect(process.env.MONGO_URI,
  {
    useNewUrlParser: true,
    useUnifiedTopology: true
  }
);

const db = mongoose.connection;
db.on("error", console.error.bind(console, "MongoDB connection error: "));
db.once("open", function () {
  console.log("MongoDB connected successfully");
});

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));

vmiTiesCron.initScheduledJobs();

app.use('/vmi-ties', vmiTiesRouter);

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

module.exports = app;
