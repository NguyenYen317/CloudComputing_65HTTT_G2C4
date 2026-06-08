const ORDER_STATUS = {
  PENDING: "pending",
  CONFIRMED: "confirmed",
  PREPARING: "preparing",
  WAITING_SHIPPER: "waiting_shipper",
  DELIVERING: "delivering",
  COMPLETED: "completed",
  CANCELLED: "cancelled",
};

const orderStatuses = new Set(Object.values(ORDER_STATUS));

const orderStatusTransitions = {
  [ORDER_STATUS.PENDING]: [ORDER_STATUS.CONFIRMED],
  [ORDER_STATUS.CONFIRMED]: [ORDER_STATUS.PREPARING],
  [ORDER_STATUS.PREPARING]: [ORDER_STATUS.WAITING_SHIPPER],
  [ORDER_STATUS.WAITING_SHIPPER]: [ORDER_STATUS.DELIVERING],
  [ORDER_STATUS.DELIVERING]: [ORDER_STATUS.COMPLETED],
  [ORDER_STATUS.COMPLETED]: [],
  [ORDER_STATUS.CANCELLED]: [],
};

const cancellableStatuses = new Set([
  ORDER_STATUS.PENDING,
  ORDER_STATUS.CONFIRMED,
  ORDER_STATUS.PREPARING,
  ORDER_STATUS.WAITING_SHIPPER,
]);

module.exports = {
  ORDER_STATUS,
  orderStatuses,
  orderStatusTransitions,
  cancellableStatuses,
};
