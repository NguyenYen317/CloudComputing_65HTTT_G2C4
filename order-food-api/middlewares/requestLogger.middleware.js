const { serviceName } = require("../config/env");

function requestLogger(req, res, next) {
  const startedAt = Date.now();

  res.on("finish", () => {
    const log = {
      severity: res.statusCode >= 500 ? "ERROR" : res.statusCode >= 400 ? "WARNING" : "INFO",
      service: serviceName,
      event: "http_request",
      method: req.method,
      path: req.originalUrl || req.url,
      statusCode: res.statusCode,
      responseTimeMs: Date.now() - startedAt,
      timestamp: new Date().toISOString(),
      userId: req.authUser?.id || req.body?.userId || req.query?.userId || "",
      role: req.authUser?.role || req.body?.role || "",
    };

    console.log(JSON.stringify(log));
  });

  next();
}

module.exports = requestLogger;
