const { shipperEmails } = require("../config/env");

function shipperMiddleware(req, res, next) {
  if (process.env.REQUIRE_ADMIN_AUTH !== "true") return next();

  const email = req.authUser?.email || "";
  if (!shipperEmails.has(email)) {
    return res.status(403).json({ message: "Bạn không có quyền shipper" });
  }

  return next();
}

module.exports = shipperMiddleware;
