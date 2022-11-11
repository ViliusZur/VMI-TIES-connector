const { Router } = require('express');
const mmrSask = require('./routes/mmrSask.route');

const router = Router();

router.use('/mmr-sask', mmrSask);

module.exports = router;