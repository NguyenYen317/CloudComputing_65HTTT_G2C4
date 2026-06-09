const ORDER_STATUS = require("../constants/orderStatus").ORDER_STATUS;
const EVENT_TYPES = require("../constants/eventTypes");
const orderRepository = require("../repositories/order.repository");
const bigQueryService = require("./bigquery.service");
const httpError = require("../utils/httpError");
const { normalizeOrderStatus, publicOrder } = require("../utils/orderHelpers");

function sortOrdersDesc(orders) {
  return orders.sort((a, b) =>
    String(b.updatedAt || b.createdAt || "").localeCompare(String(a.updatedAt || a.createdAt || "")),
  );
}

function normalizeShipper(body = {}) {
  const shipperId = String(body.shipperId || body.id || "").trim();
  const shipperEmail = String(body.shipperEmail || body.email || "").trim().toLowerCase();
  const shipperName = String(body.shipperName || body.name || "Shipper").trim();

  if (!shipperId || !shipperEmail) {
    throw httpError(400, "Thiếu thông tin shipper");
  }

  return { shipperId, shipperEmail, shipperName };
}

function ensureOwnedByShipper(order, shipperId) {
  if (String(order.shipperId || "") !== String(shipperId || "")) {
    throw httpError(403, "Shipper không có quyền cập nhật đơn này");
  }
}

async function findOrderOrThrow(orderId) {
  const order = await orderRepository.findById(orderId);
  if (!order) {
    throw httpError(404, "Không tìm thấy đơn hàng");
  }
  return order;
}

async function listAvailableOrders() {
  const orders = await orderRepository.list(500);
  return sortOrdersDesc(
    orders.filter((order) => normalizeOrderStatus(order) === ORDER_STATUS.WAITING_SHIPPER),
  ).map(publicOrder);
}

async function listMyDeliveryOrders(shipperId) {
  const normalizedShipperId = String(shipperId || "").trim();
  if (!normalizedShipperId) {
    throw httpError(400, "Thiếu shipperId");
  }

  const orders = await orderRepository.list(500);
  return sortOrdersDesc(
    orders.filter((order) => String(order.shipperId || "") === normalizedShipperId),
  ).map(publicOrder);
}

async function acceptOrder(orderId, body) {
  const shipper = normalizeShipper(body);
  const order = await findOrderOrThrow(orderId);
  const status = normalizeOrderStatus(order);

  if (status !== ORDER_STATUS.WAITING_SHIPPER) {
    throw httpError(400, "Chỉ đơn chờ shipper lấy hàng mới được nhận");
  }

  const now = new Date().toISOString();
  const updated = {
    ...order,
    status: ORDER_STATUS.ASSIGNED_SHIPPER,
    shipperId: shipper.shipperId,
    shipperEmail: shipper.shipperEmail,
    shipperName: shipper.shipperName,
    acceptedAt: now,
    updatedAt: now,
  };

  await orderRepository.save(updated);
  await bigQueryService.writeOrderEvent(EVENT_TYPES.SHIPPER_ASSIGNED, updated);

  return {
    message: "Nhận đơn thành công",
    order: publicOrder(updated),
  };
}

async function startDelivering(orderId, body) {
  const shipperId = String(body.shipperId || "").trim();
  if (!shipperId) {
    throw httpError(400, "Thiếu shipperId");
  }

  const order = await findOrderOrThrow(orderId);
  ensureOwnedByShipper(order, shipperId);

  const status = normalizeOrderStatus(order);
  if (status !== ORDER_STATUS.ASSIGNED_SHIPPER) {
    throw httpError(400, "Chỉ đơn đã được shipper nhận mới chuyển sang đang giao");
  }

  const now = new Date().toISOString();
  const updated = {
    ...order,
    status: ORDER_STATUS.DELIVERING,
    deliveringAt: now,
    updatedAt: now,
  };

  await orderRepository.save(updated);
  await bigQueryService.writeOrderEvent(EVENT_TYPES.SHIPPER_DELIVERING, updated);

  return {
    message: "Bắt đầu giao đơn thành công",
    order: publicOrder(updated),
  };
}

async function completeOrder(orderId, body) {
  const shipperId = String(body.shipperId || "").trim();
  if (!shipperId) {
    throw httpError(400, "Thiếu shipperId");
  }

  const order = await findOrderOrThrow(orderId);
  ensureOwnedByShipper(order, shipperId);

  const status = normalizeOrderStatus(order);
  if (status !== ORDER_STATUS.DELIVERING) {
    throw httpError(400, "Chỉ đơn đang giao mới được hoàn thành");
  }

  const now = new Date().toISOString();
  const updated = {
    ...order,
    status: ORDER_STATUS.COMPLETED,
    completedAt: now,
    updatedAt: now,
  };

  await orderRepository.save(updated);
  await bigQueryService.writeOrderEvent(EVENT_TYPES.SHIPPER_COMPLETED, updated);

  return {
    message: "Giao đơn thành công",
    order: publicOrder(updated),
  };
}

module.exports = {
  listAvailableOrders,
  listMyDeliveryOrders,
  acceptOrder,
  startDelivering,
  completeOrder,
};
