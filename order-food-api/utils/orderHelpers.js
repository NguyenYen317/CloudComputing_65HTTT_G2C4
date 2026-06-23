const {
  orderStatuses,
  orderStatusTransitions,
  cancellableStatuses,
} = require("../constants/orderStatus");

function normalizeOrderStatus(order) {
  const status = String(order?.status || "").trim();
  if (orderStatuses.has(status)) return status;

  const lower = status.toLowerCase();
  if (
    order?.cancelledAt ||
    lower.includes("cancel") ||
    lower.includes("huy") ||
    lower.includes("hủy")
  ) {
    return "cancelled";
  }

  return "pending";
}

function publicOrder(order) {
  const status = normalizeOrderStatus(order);
  return {
    ...order,
    status,
    totalAmount: Number(order.totalAmount ?? order.total ?? 0),
    updatedAt: order.updatedAt || order.createdAt || new Date().toISOString(),
  };
}

function canTransitionOrder(currentStatus, nextStatus) {
  if (nextStatus === "cancelled") return cancellableStatuses.has(currentStatus);
  return orderStatusTransitions[currentStatus]?.includes(nextStatus) ?? false;
}

function orderItemsForAnalytics(order) {
  return (Array.isArray(order.items) ? order.items : []).map((item) => ({
    id: item.id || item.foodId || "",
    name: item.name || item.foodName || "",
    price: Number(item.price || 0),
    quantity: Number(item.quantity || 1),
  }));
}

module.exports = {
  normalizeOrderStatus,
  publicOrder,
  canTransitionOrder,
  orderItemsForAnalytics,
};
