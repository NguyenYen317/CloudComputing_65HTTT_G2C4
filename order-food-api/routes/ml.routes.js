const express = require("express");
const mlController = require("../controllers/ml.controller");
const authMiddleware = require("../middlewares/auth.middleware");
const adminMiddleware = require("../middlewares/admin.middleware");

const router = express.Router();
const adminOnly = [authMiddleware, adminMiddleware];

router.post("/train", ...adminOnly, mlController.trainModel);
router.post("/predict", ...adminOnly, mlController.updatePredictions);
router.get("/predictions", ...adminOnly, mlController.getPredictions);

module.exports = router;
