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
const shipperRoutes = require("./shipper.routes");
const notificationRoutes = require("./notification.routes");
const healthRoutes = require("./health.routes");
const mapsRoutes = require("./maps.routes");

const router = express.Router();

router.use(legacyRoutes);
router.use(healthRoutes);
router.use("/auth", authRoutes);
router.use("/foods", foodRoutes);
router.use("/cart", cartRoutes);
router.use("/orders", orderRoutes);
router.use("/admin", adminRoutes);
router.use("/upload", uploadRoutes);
router.use("/bigquery", bigqueryRoutes);
router.use("/ml", mlRoutes);
router.use("/shipper", shipperRoutes);
router.use("/notifications", notificationRoutes);
router.use("/maps", mapsRoutes);

module.exports = router;
