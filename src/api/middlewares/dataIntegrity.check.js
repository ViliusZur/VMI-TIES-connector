/**
 * Middleware to check if data coming in is good
 */
 exports.checkDataIntegrity = async (req, res, next) => {
  logger.debug('middlewares/control - rateLimitIncrement', 'START', req.info);

  try {
    const user = req.user || undefined;
    const endpoint = _generateEndpointString({
      method: req.method,
      baseUrl: req.baseUrl,
      path: req.path,
      params: req.params
    });
    let ipAddress = req.ip;
    if (req.headers && req.headers['x-real-ip']) ipAddress = req.headers['x-real-ip'];

    logger.debug('middlewares/control - rateLimitIncrement', 'create RateLimit record', 'user', user ? user._id.toString() : undefined, req.info);
    logger.debug('middlewares/control - rateLimitIncrement', 'create RateLimit record', 'ipAddress', ipAddress, req.info);
    logger.debug('middlewares/control - rateLimitIncrement', 'create RateLimit record', 'endpoint', endpoint, req.info);
    await RateLimit.createRateLimit({
      user,
      ipAddress,
      endpoint,
    }, req.info);

    return next();
  } catch (error) {
    logger.error('middlewares/control - rateLimitIncrement', error.message, req.info);
    return libApiResponse.sendError({
      res,
      statusCode: httpStatus.INTERNAL_SERVER_ERROR,
      message: '',
    });
  }
};
