const express = require('express');
const router = express.Router();

/* POST save account data. */
router.post('/', function(req, res, next) {
  res.send('respond with a resource');
});

module.exports = router;