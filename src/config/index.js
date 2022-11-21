const dotenv = require('dotenv');
// config() will read your .env file, parse the contents, assign it to process.env.
dotenv.config();

module.exports = {
  port: process.env.PORT,
  api: {
    prefix: process.env.API_PREFIX
  },
  mongoURI: process.env.MONGO_URI,
  lithuanianTaxesKeys: {
    privateKeyString: process.env.PRIVATE_KEY_STRING,
    publicCertString: process.env.PUBLIC_CERT_STRING,
  },
  accountData: {
    currency: process.env.CURRENCY,
    accountType: process.env.ACCOUNT_TYPE,
    bic: process.env.BIC,
  }
}