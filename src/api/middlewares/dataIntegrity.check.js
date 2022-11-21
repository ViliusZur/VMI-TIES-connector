// packages
const Joi = require('joi');

/**
 * Middleware to check if data coming in is good
 */
const checkDataIntegrity = async (req, res, next) => {
  console.log('Checking data integrity');
  try {
    const schema = Joi.object({
      // add additional checks, for example max 2 letters in dnationality, iban regular expression, etc.
      accountId: Joi.string().required(),
      iban: Joi.string().required(),
      accountOpened: Joi.date().iso().required(),
      identityCode: Joi.string().required(),
      docCountry: Joi.string().required(),
      docType: Joi.string().required(),
      docNumber: Joi.string().required(),
      dateOfBirth: Joi.date().iso().required(),
      nationality: Joi.string().required(),
      firstName: Joi.string().required(),
      lastName: Joi.string().required(),
      address: Joi.string().required(),
    });

    await schema.validateAsync(req.body);

    return next();
  } catch (error) {
    next(error);
  }
};

module.exports = checkDataIntegrity;