const express = require("express");
const uploadController = require("../controllers/upload.controller");
const authMiddleware = require("../middlewares/auth.middleware");
const adminMiddleware = require("../middlewares/admin.middleware");

const router = express.Router();
const adminOnly = [authMiddleware, adminMiddleware];

router.post("/food-image", ...adminOnly, uploadController.uploadFoodImage);

module.exports = router;
