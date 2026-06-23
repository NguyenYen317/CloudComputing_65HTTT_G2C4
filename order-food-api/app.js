const express = require("express");
const cors = require("cors");
const legacyRoutes = require("./routes/legacy.routes");
const authRoutes = require("./routes/auth.routes");
const foodRoutes = require("./routes/food.routes");
const cartRoutes = require("./routes/cart.routes");
const orderRoutes = require("./routes/order.routes");
const adminRoutes = require("./routes/admin.routes");
const uploadRoutes = require("./routes/upload.routes");
// Load BigQuery routes only when enabled to avoid requiring Google Cloud
// libraries at startup in development/testing environments.
let bigqueryRoutes = null;
try {
	if (process.env.ENABLE_BIGQUERY === "true") {
		bigqueryRoutes = require("./routes/bigquery.routes");
	}
} catch (err) {
	console.warn('BigQuery routes not loaded:', err.message);
}
const mlRoutes = require("./routes/ml.routes");
const shipperRoutes = require("./routes/shipper.routes");
const notificationRoutes = require("./routes/notification.routes");
const mapsRoutes = require("./routes/maps.routes");
const zohoRoutes = require("./routes/zoho.routes");
const healthRoutes = require("./routes/health.routes");
const requestLogger = require("./middlewares/requestLogger.middleware");
const errorMiddleware = require("./middlewares/error.middleware");

const app = express();

app.use(cors());
app.use(express.json({ limit: "12mb" }));
app.use(requestLogger);
app.use(healthRoutes);
app.use(legacyRoutes);
app.use("/auth", authRoutes);
app.use("/foods", foodRoutes);
app.use("/cart", cartRoutes);
app.use("/orders", orderRoutes);
app.use("/admin", adminRoutes);
app.use("/upload", uploadRoutes);
if (bigqueryRoutes) {
	app.use("/bigquery", bigqueryRoutes);
}
app.use("/ml", mlRoutes);
app.use("/shipper", shipperRoutes);
app.use("/notifications", notificationRoutes);
app.use("/maps", mapsRoutes);
app.use("/zoho", zohoRoutes);
app.use(errorMiddleware);

module.exports = app;
