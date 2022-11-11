const config = require('../config');
const expressLoader = require('./express');
const mongooseLoader = require('./mongoose');
// const cronLoader = require('./cronJobs');

exports.init = async ({ expressApp }) => {
  // await mongooseLoader.init();
  const mongoConnection = await mongooseLoader.init(config.mongoURI);
  console.log('Mongoose initialized');

  await expressLoader.init({ app: expressApp });
  console.log('Express Initialized');

  // cronLoader.initScheduledJobs();
  console.log('Cron Jobs Initialized');
}

