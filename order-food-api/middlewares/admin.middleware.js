const { adminEmails } = require("../config/env");

function adminMiddleware(req, res, next) {
  if (process.env.REQUIRE_ADMIN_AUTH !== "true") return next();

  const email = req.authUser?.email || "";
  if (!adminEmails.has(email)) {
    return res.status(403).json({ message: "Bạn không có quyền admin" });
  }

  return next();
}

module.exports = adminMiddleware;
