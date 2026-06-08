const orderRepository = require("../repositories/order.repository");
const { orderStatuses } = require("../constants/orderStatus");
const httpError = require("../utils/httpError");
const {
  normalizeOrderStatus,
  publicOrder,
  canTransitionOrder,
} = require("../utils/orderHelpers");

function sortOrdersDesc(orders) {
  return orders.sort((a, b) => String(b.createdAt || "").localeCompare(String(a.createdAt || "")));
}

async function findOrderById(id) {
  return orderRepository.findById(id);
}

async function listOrders({ userId = "", limit = 200, slice = 100 } = {}) {
  const normalizedUserId = String(userId || "").trim();
  const orders = await orderRepository.list(limit);
  let result = sortOrdersDesc(orders.filter((order) => !normalizedUserId || order.userId === normalizedUserId));

  if (slice) result = result.slice(0, slice);
  return result.map(publicOrder);
}

async function listOrdersByUser(userId) {
  return listOrders({ userId, limit: 200, slice: 0 });
}

async function listAdminOrders() {
  const orders = await orderRepository.list(500);
  return sortOrdersDesc(orders).map(publicOrder);
}

async function getOrderDetail(orderId) {
  const order = await findOrderById(orderId);
  if (!order) {
    throw httpError(404, "Không tìm thấy đơn hàng");
  }

  return publicOrder(order);
}

async function saveOrder(order) {
  return orderRepository.save(order);
}

async function createOrder(body) {
  const bigQueryService = require("./bigquery.service");
  const id = `OD${Date.now().toString().slice(-8)}`;
  const createdAt = new Date().toISOString();
  const totalAmount = Number(body.totalAmount ?? body.total ?? 0);
  const order = {
    id,
    ...body,
    total: totalAmount,
    totalAmount,
    status: "pending",
    createdAt,
    updatedAt: createdAt,
  };

  await saveOrder(order);
  await bigQueryService.writeOrderEvent("created", order);

  return {
    message: "Đặt món thành công",
    order: publicOrder(order),
  };
}

async function updateOrderStatus(orderId, nextStatus) {
  const bigQueryService = require("./bigquery.service");
  const normalizedNextStatus = String(nextStatus || "").trim();

  if (!orderStatuses.has(normalizedNextStatus)) {
    throw httpError(400, "Trạng thái đơn hàng không hợp lệ");
  }

  const order = await findOrderById(orderId);
  if (!order) {
    throw httpError(404, "Không tìm thấy đơn hàng");
  }

  const currentStatus = normalizeOrderStatus(order);
  if (currentStatus === "cancelled" || currentStatus === "completed") {
    throw httpError(400, "Không thể chuyển trạng thái đơn hàng theo luồng này");
  }

  if (!canTransitionOrder(currentStatus, normalizedNextStatus)) {
    throw httpError(400, "Không thể chuyển trạng thái đơn hàng theo luồng này");
  }

  const updated = {
    ...order,
    status: normalizedNextStatus,
    updatedAt: new Date().toISOString(),
    ...(normalizedNextStatus === "cancelled" ? { cancelledAt: new Date().toISOString() } : {}),
  };

  await saveOrder(updated);
  await bigQueryService.writeOrderEvent("status_updated", updated);

  return {
    message: "Cập nhật trạng thái đơn hàng thành công",
    order: publicOrder(updated),
  };
}

async function cancelOrder(orderId) {
  const bigQueryService = require("./bigquery.service");
  const order = await findOrderById(orderId);

  if (!order) {
    throw httpError(404, "Không tìm thấy đơn hàng");
  }

  const currentStatus = normalizeOrderStatus(order);
  if (!canTransitionOrder(currentStatus, "cancelled")) {
    throw httpError(400, "Không thể hủy đơn ở trạng thái hiện tại");
  }

  const updated = {
    ...order,
    status: "cancelled",
    cancelledAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };

  await saveOrder(updated);
  await bigQueryService.writeOrderEvent("cancelled", updated);

  return {
    message: "Đã hủy đơn hàng",
    order: updated,
  };
}

async function deleteOrder(orderId) {
  const bigQueryService = require("./bigquery.service");
  const order = await findOrderById(orderId);

  if (!order) {
    throw httpError(404, "Không tìm thấy đơn hàng");
  }

  await orderRepository.remove(orderId);
  await bigQueryService.writeOrderEvent("deleted", order);

  return {
    message: "Đã xóa đơn hàng",
    order,
  };
}

async function revenueSummary() {
  const orders = await orderRepository.list(500);
  const revenue = orders.reduce((sum, order) => sum + Number(order.totalAmount || order.total || 0), 0);
  return { revenue, totalOrders: orders.length };
}

module.exports = {
  normalizeOrderStatus,
  publicOrder,
  canTransitionOrder,
  findOrderById,
  listOrders,
  listOrdersByUser,
  listAdminOrders,
  getOrderDetail,
  saveOrder,
  createOrder,
  updateOrderStatus,
  cancelOrder,
  deleteOrder,
  revenueSummary,
  removeOrder: orderRepository.remove,
};
