function authMiddleware(req, res, next) {
  if (process.env.REQUIRE_ADMIN_AUTH !== "true") return next();

  const email =
    req.headers["x-user-email"] ||
    req.headers["x-admin-email"] ||
    req.query.adminEmail ||
    req.body?.adminEmail;

  if (!email) {
    return res.status(401).json({ message: "Vui lòng đăng nhập" });
  }

  req.authUser = { email: String(email).trim().toLowerCase() };
  return next();
}

module.exports = authMiddleware;
