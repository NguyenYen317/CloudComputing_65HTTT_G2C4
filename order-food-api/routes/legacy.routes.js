const express = require("express");
const authController = require("../controllers/auth.controller");

const router = express.Router();

router.get("/", (req, res) => {
  res.json({
    message: "Order Food API is running",
    endpoints: ["/foods", "/orders", "/auth/register", "/auth/login", "/auth/google"],
  });
});

router.get("/users", authController.listUsers);
router.delete("/users/:email", authController.removeUser);

module.exports = router;
