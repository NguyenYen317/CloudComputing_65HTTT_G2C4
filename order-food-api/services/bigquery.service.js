const { getBigQuery } = require("../config/bigquery");
const predictionRepository = require("../repositories/prediction.repository");
const {
  bigQueryLocation,
  enableBigQuery,
  bigQueryDatasetId,
  bigQueryOrderEventsTableId,
} = require("../config/env");
const {
  normalizeOrderStatus,
  orderItemsForAnalytics,
} = require("../utils/orderHelpers");

function getBigQueryClient() {
  if (!enableBigQuery) return null;
  return getBigQuery();
}

function orderEventsTableRef() {
  const bigquery = getBigQueryClient();
  if (!bigquery) {
    throw new Error("BigQuery is not enabled");
  }
  return `\`${bigquery.projectId}.${bigQueryDatasetId}.${bigQueryOrderEventsTableId}\``;
}

async function ensureOrderEventsTable() {
  const bigquery = getBigQueryClient();
  if (!bigquery) return null;

  const dataset = bigquery.dataset(bigQueryDatasetId);
  const [datasetExists] = await dataset.exists();
  if (!datasetExists) {
    await dataset.create({ location: bigQueryLocation });
  }

  const table = dataset.table(bigQueryOrderEventsTableId);
  const [tableExists] = await table.exists();
  if (!tableExists) {
    await table.create({
      schema: [
        { name: "eventId", type: "STRING", mode: "REQUIRED" },
        { name: "eventType", type: "STRING", mode: "REQUIRED" },
        { name: "orderId", type: "STRING", mode: "REQUIRED" },
        { name: "userId", type: "STRING" },
        { name: "userEmail", type: "STRING" },
        { name: "status", type: "STRING" },
        { name: "totalAmount", type: "INTEGER" },
        { name: "itemCount", type: "INTEGER" },
        { name: "itemsJson", type: "STRING" },
        { name: "createdAt", type: "TIMESTAMP" },
        { name: "updatedAt", type: "TIMESTAMP" },
        { name: "eventAt", type: "TIMESTAMP", mode: "REQUIRED" },
      ],
    });
  }

  return table;
}

async function writeOrderEvent(eventType, order) {
  if (!enableBigQuery) return;

  try {
    const now = new Date().toISOString();
    const items = orderItemsForAnalytics(order);
    const table = await ensureOrderEventsTable();

    await table.insert([
      {
        eventId: `${eventType}-${order.id || order.code}-${Date.now()}`,
        eventType,
        orderId: order.id || order.code || "",
        userId: order.userId || "",
        userEmail: order.userEmail || order.email || "",
        status: normalizeOrderStatus(order),
        totalAmount: Number(order.totalAmount ?? order.total ?? 0),
        itemCount: items.reduce((total, item) => total + Number(item.quantity || 0), 0),
        itemsJson: JSON.stringify(items),
        createdAt: order.createdAt || now,
        updatedAt: order.updatedAt || now,
        eventAt: now,
      },
    ]);
  } catch (error) {
    console.error("BigQuery order event failed:", error.message);
  }
}

async function getAdminSummary() {
  const bigquery = getBigQueryClient();
  if (!bigquery) {
    return { totalOrders: 0, cancelledOrders: 0, revenue: 0, ordersByStatus: [] };
  }

  const [rows] = await bigquery.query({
    query: `
      WITH latest_orders AS (
        SELECT *
        FROM ${orderEventsTableRef()}
        QUALIFY ROW_NUMBER() OVER (PARTITION BY orderId ORDER BY eventAt DESC) = 1
      )
      SELECT
        (SELECT COUNT(*) FROM latest_orders) AS totalOrders,
        (SELECT COUNTIF(status = 'cancelled') FROM latest_orders) AS cancelledOrders,
        (SELECT SUM(IF(status != 'cancelled', totalAmount, 0)) FROM latest_orders) AS revenue,
        ARRAY(
          SELECT AS STRUCT status, COUNT(*) AS orderCount
          FROM latest_orders
          GROUP BY status
          ORDER BY orderCount DESC
        ) AS ordersByStatus
    `,
  });

  return rows[0] || {
    totalOrders: 0,
    cancelledOrders: 0,
    revenue: 0,
    ordersByStatus: [],
  };
}

async function listOrderEvents(limit = 100) {
  const bigquery = getBigQueryClient();
  if (!bigquery) return [];

  const normalizedLimit = Math.min(Number(limit || 100), 500);
  const [rows] = await bigquery.query({
    query: `
      SELECT eventType, orderId, userEmail, status, totalAmount, itemCount, eventAt
      FROM ${orderEventsTableRef()}
      ORDER BY eventAt DESC
      LIMIT @limit
    `,
    params: { limit: normalizedLimit },
  });

  return rows;
}

async function createOrderEvent(body) {
  await writeOrderEvent(body.eventType || "manual", body.order || body);
  return { message: "Đã ghi event BigQuery" };
}

async function revenueSummary() {
  const bigquery = getBigQueryClient();
  if (!bigquery) return { revenue: 0, orderCount: 0 };

  const [rows] = await bigquery.query({
    query: `SELECT SUM(totalAmount) AS revenue, COUNT(DISTINCT orderId) AS orderCount FROM ${orderEventsTableRef()}`,
  });

  return rows[0] || { revenue: 0, orderCount: 0 };
}

async function bestSellingFoods() {
  const predictions = await predictionRepository.getLatest();
  return predictions?.bestSellingFoods || [];
}

module.exports = {
  orderEventsTableRef,
  ensureOrderEventsTable,
  writeOrderEvent,
  getAdminSummary,
  listOrderEvents,
  createOrderEvent,
  revenueSummary,
  bestSellingFoods,
};
