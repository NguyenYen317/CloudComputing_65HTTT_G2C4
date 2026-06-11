const express = require("express");
const notificationController = require("../controllers/notification.controller");

const router = express.Router();

router.post("/save-token", notificationController.saveToken);

module.exports = router;
