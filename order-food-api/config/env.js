const path = require("path");

const PORT = process.env.PORT || 8080;
const pythonBin =
  process.env.PYTHON_BIN || (process.platform === "win32" ? "python" : "python3");

const mlDir = path.join(__dirname, "..", "ml");

const predictionsPath = path.join(mlDir, "predictions.json");
const runtimeOrdersPath = path.join(mlDir, "orders_runtime.csv");
const foodModelPath = path.join(mlDir, "model_food.pkl");
const revenueModelPath = path.join(mlDir, "model_revenue.pkl");

const bigQueryDatasetId =
  process.env.BIGQUERY_DATASET ||
  process.env.BIGQUERY_DATASET_ID ||
  "orderfood_analytics";
const bigQueryOrderEventsTableId =
  process.env.BIGQUERY_ORDER_EVENTS_TABLE ||
  process.env.BIGQUERY_TABLE_ID ||
  "order_events";
const bigQueryLocation = process.env.BIGQUERY_LOCATION || "asia-southeast1";
const enableBigQuery = process.env.ENABLE_BIGQUERY !== "false";

const foodImageBucket =
  process.env.FOOD_IMAGE_BUCKET || process.env.CLOUD_STORAGE_BUCKET || "";
const enablePubSub = process.env.ENABLE_PUBSUB !== "false";
const pubSubOrderEventsTopic =
  process.env.PUBSUB_ORDER_EVENTS_TOPIC ||
  process.env.PUBSUB_ORDER_TOPIC ||
  "order-events-topic";
const serviceName = process.env.SERVICE_NAME || "orderfood-api";
const googleMapsApiKey = process.env.GOOGLE_MAPS_API_KEY || "";
const defaultStoreLat = Number(process.env.STORE_LAT || 21.028511);
const defaultStoreLng = Number(process.env.STORE_LNG || 105.804817);
const defaultStoreAddress =
  process.env.STORE_ADDRESS || "Ha Noi, Viet Nam";

const adminEmails = new Set(
  (process.env.ADMIN_EMAILS || "phuy08463@gmail.com,admin123@gmail.com")
    .split(",")
    .map((email) => email.trim().toLowerCase())
    .filter(Boolean),
);

const shipperEmails = new Set(
  (process.env.SHIPPER_EMAILS || "deli123@gmail.com")
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
  enablePubSub,
  pubSubOrderEventsTopic,
  serviceName,
  googleMapsApiKey,
  defaultStoreLat,
  defaultStoreLng,
  defaultStoreAddress,
  adminEmails,
  shipperEmails,
};
