// packages
const express = require('express');
const router = express.Router();

// middlewares
const checkDataIntegrity = require('../middlewares/dataIntegrity.check');

// services
const mmrSaskService = require('../../services/mmrSask.service');

/* POST save account data. */
router.post('/', checkDataIntegrity, async function(req, res, next) {
  try {
    const response = await mmrSaskService.saveData(req.body);
    res.send(response);
  } catch (error) {
    next(error);
  }
});

module.exports = router;