const express = require("express");
const cors = require("cors");
const legacyRoutes = require("./routes/legacy.routes");
const authRoutes = require("./routes/auth.routes");
const foodRoutes = require("./routes/food.routes");
const cartRoutes = require("./routes/cart.routes");
const orderRoutes = require("./routes/order.routes");
const adminRoutes = require("./routes/admin.routes");
const uploadRoutes = require("./routes/upload.routes");
const bigqueryRoutes = require("./routes/bigquery.routes");
const mlRoutes = require("./routes/ml.routes");
const errorMiddleware = require("./middlewares/error.middleware");

const app = express();

app.use(cors());
app.use(express.json({ limit: "12mb" }));
app.use(legacyRoutes);
app.use("/auth", authRoutes);
app.use("/foods", foodRoutes);
app.use("/cart", cartRoutes);
app.use("/orders", orderRoutes);
app.use("/admin", adminRoutes);
app.use("/upload", uploadRoutes);
app.use("/bigquery", bigqueryRoutes);
app.use("/ml", mlRoutes);
app.use(errorMiddleware);

module.exports = app;
