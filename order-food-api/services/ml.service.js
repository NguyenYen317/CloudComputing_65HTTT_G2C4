const fs = require("fs");
const orderRepository = require("../repositories/order.repository");
const predictionRepository = require("../repositories/prediction.repository");
const runPython = require("../utils/runPython");
const httpError = require("../utils/httpError");
const { predictionsPath, runtimeOrdersPath } = require("../config/env");
const { normalizeOrderStatus } = require("../utils/orderHelpers");

function readPredictions() {
  return JSON.parse(fs.readFileSync(predictionsPath, "utf8"));
}

function csvValue(value) {
  const text = String(value ?? "");
  if (/[",\n\r]/.test(text)) {
    return `"${text.replace(/"/g, '""')}"`;
  }
  return text;
}

function normalizeTrainingCategory(foodName, fallback) {
  const value = String(fallback || "").trim();
  if (value) return value;

  const lower = String(foodName || "").toLowerCase();
  if (lower.includes("pizza") || lower.includes("burger") || lower.includes("chicken")) {
    return "Fast Food";
  }
  if (lower.includes("coca") || lower.includes("tea")) return "Drink";
  if (lower.includes("salad")) return "Healthy";
  if (lower.includes("fries")) return "Snack";
  return "Other";
}

function shouldUseOrderForTraining(order) {
  if (order.cancelledAt) return false;
  return normalizeOrderStatus(order) !== "cancelled";
}

async function exportOrdersToTrainingCsv() {
  const orders = await orderRepository.list(1000);
  const rows = [
    [
      "orderId",
      "userId",
      "foodName",
      "category",
      "price",
      "quantity",
      "dayOfWeek",
      "hour",
      "isWeekend",
      "totalAmount",
    ],
  ];

  for (const order of orders.filter(shouldUseOrderForTraining)) {
    const createdAt = order.createdAt ? new Date(order.createdAt) : new Date();
    const dayOfWeek = createdAt.getUTCDay();
    const hour = createdAt.getUTCHours();
    const isWeekend = dayOfWeek === 0 || dayOfWeek === 6 ? 1 : 0;
    const items = Array.isArray(order.items) ? order.items : [];

    for (const item of items) {
      const foodName = item.name || item.foodName || "Unknown";
      const price = Number(item.price || 0);
      const quantity = Number(item.quantity || 1);
      rows.push([
        order.id || order.code || "",
        order.userId || "",
        foodName,
        normalizeTrainingCategory(foodName, item.category),
        price,
        quantity,
        dayOfWeek,
        hour,
        isWeekend,
        price * quantity,
      ]);
    }
  }

  if (rows.length < 6) {
    throw new Error("Chưa có đủ dữ liệu đơn hàng thật để huấn luyện model. Cần ít nhất 5 dòng món đã bán.");
  }

  fs.writeFileSync(
    runtimeOrdersPath,
    rows.map((row) => row.map(csvValue).join(",")).join("\n"),
    "utf8",
  );

  return rows.length - 1;
}

async function getPredictions(missingMessage) {
  const stored = await predictionRepository.getLatest();
  if (stored) return stored;

  if (!fs.existsSync(predictionsPath)) {
    throw httpError(404, missingMessage || "Chưa có dữ liệu dự đoán. Vui lòng chạy ML prediction trước.");
  }

  return readPredictions();
}

async function trainModel() {
  const rows = await exportOrdersToTrainingCsv();
  await runPython("train_model.py");
  await runPython("predict.py");
  const data = await predictionRepository.saveLatest(readPredictions());
  return { rows, data };
}

async function updatePredictions() {
  await runPython("predict.py");
  return predictionRepository.saveLatest(readPredictions());
}

async function updatePredictionsWithFallback() {
  try {
    const data = await updatePredictions();
    return { data };
  } catch (error) {
    const data = await predictionRepository.saveLatest(readPredictions());
    return {
      data,
      warning: error.message,
      fallback: true,
    };
  }
}

module.exports = {
  getLatestPredictions: predictionRepository.getLatest,
  saveLatestPredictions: predictionRepository.saveLatest,
  readPredictions,
  exportOrdersToTrainingCsv,
  getPredictions,
  trainModel,
  updatePredictions,
  updatePredictionsWithFallback,
};
