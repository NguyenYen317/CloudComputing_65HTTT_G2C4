const express = require("express");
const legacyRoutes = require("./legacy.routes");
const authRoutes = require("./auth.routes");
const foodRoutes = require("./food.routes");
const cartRoutes = require("./cart.routes");
const orderRoutes = require("./order.routes");
const adminRoutes = require("./admin.routes");
const uploadRoutes = require("./upload.routes");
const bigqueryRoutes = require("./bigquery.routes");
const mlRoutes = require("./ml.routes");

const router = express.Router();

router.use(legacyRoutes);
router.use("/auth", authRoutes);
router.use("/foods", foodRoutes);
router.use("/cart", cartRoutes);
router.use("/orders", orderRoutes);
router.use("/admin", adminRoutes);
router.use("/upload", uploadRoutes);
router.use("/bigquery", bigqueryRoutes);
router.use("/ml", mlRoutes);

module.exports = router;
