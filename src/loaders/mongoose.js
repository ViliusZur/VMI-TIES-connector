const mongoose = require('mongoose');

exports.init = async (mongoUri) => {
  const connection = await mongoose.connect(mongoUri, { useNewUrlParser: true });
  return connection.connection.db;
}