// packages
const iso3311a2 = require('iso-3166-1-alpha-2');

// models
const AccountData = require('../models/accountData.model');

// configs
const config = require('../config');

exports.saveData = async ({
  accountId, 
  iban, 
  accountOpened, 
  identityCode,
  docCountry,
  docType,
  docNumber,
  dateOfBirth,
  nationality,
  firstName,
  lastName,
  address
}) => {

    let addressCountry = address.split(', ')[2];
    if (!iso3311a2.getCountry(addressCountry)) {
      addressCountry = iso3311a2.getCode(addressCountry);
    }

    const data = {
      account: {
        refId: accountId,
        iban,
        accountOpened: accountOpened,
        currency: config.accountData.currency,
        accountType: config.accountData.accountType,
        bic: config.accountData.bic,
      },
      user: {
        identityCode,
        documentCountry: docCountry,
        documentType: docType,
        documentNumber: docNumber,
        dateOfBirth: dateOfBirth,
        nationality,
        firstName,
        lastName,
        address,
        addressCountry,
      },
    };

    const newAccount = await AccountData.create(data);
      
    return newAccount;
};
