const path = require("path");

const PORT = process.env.PORT || 8080;
const pythonBin =
  process.env.PYTHON_BIN || (process.platform === "win32" ? "python" : "python3");

const mlDir = path.join(__dirname, "..", "ml");

const predictionsPath = path.join(mlDir, "predictions.json");
const runtimeOrdersPath = path.join(mlDir, "orders_runtime.csv");
const foodModelPath = path.join(mlDir, "model_food.pkl");
const revenueModelPath = path.join(mlDir, "model_revenue.pkl");

const bigQueryDatasetId = process.env.BIGQUERY_DATASET || "orderfood_analytics";
const bigQueryOrderEventsTableId =
  process.env.BIGQUERY_ORDER_EVENTS_TABLE || "order_events";
const bigQueryLocation = process.env.BIGQUERY_LOCATION || "asia-southeast1";
const enableBigQuery = process.env.ENABLE_BIGQUERY !== "false";

const foodImageBucket = process.env.FOOD_IMAGE_BUCKET || "";

const adminEmails = new Set(
  (process.env.ADMIN_EMAILS || "phuy08463@gmail.com")
    .split(",")
    .map((email) => email.trim().toLowerCase())
    .filter(Boolean),
);

module.exports = {
  PORT,
  pythonBin,
  predictionsPath,
  runtimeOrdersPath,
  foodModelPath,
  revenueModelPath,
  bigQueryDatasetId,
  bigQueryOrderEventsTableId,
  bigQueryLocation,
  enableBigQuery,
  foodImageBucket,
  adminEmails,
};
