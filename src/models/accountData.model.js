// packages
const mongoose = require('mongoose');

const ACCOUNT_REPORT_STATUSES = {
  ENUM: ['PENDING', 'GENERATING_PACKAGE', 'SENDING', 'SENT', 'FAILED'],
  CONSTANTS: {
    PENDING: 'PENDING',
    GENERATING_PACKAGE: 'GENERATING_PACKAGE',
    SENDING: 'SENDING',
    SENT: 'SENT',
    FAILED: 'FAILED',
  },
};

const AccountDataSchema = new mongoose.Schema({
  state: {
    type: String,
    required: true,
    enum: ACCOUNT_REPORT_STATUSES.ENUM,
    default: 'PENDING',
  },
  account: {
    refId: {
      type: String,
      required: true,
    },
    iban: {
      type: String,
      required: true,
    },
    accountOpened: {
      type: Date,
      required: true,
    },
    currency: {
      type: String,
      required: true,
    },
    accountType: {
      type: Number,
      required: true,
    },
    bic: {
      type: String,
      required: true,
    },
  },
  user: {
    identityCode: {
      type: String,
      required: false,
    },
    documentCountry: {
      type: String,
      required: true,
    },
    documentType: {
      type: String,
      required: true,
    },
    documentNumber: {
      type: String,
      required: false,
    },
    dateOfBirth: {
      type: Date,
      required: true,
    },
    nationality: {
      type: String,
      required: true,
    },
    firstName: {
      type: String,
      required: true,
    },
    lastName: {
      type: String,
      required: true,
    },
    address: {
      type: String,
      required: true,
    },
    addressCountry: {
      type: String,
      required: false,
    }
  }
}, { timestamps: true });

module.exports = mongoose.model('AccountData', AccountDataSchema);