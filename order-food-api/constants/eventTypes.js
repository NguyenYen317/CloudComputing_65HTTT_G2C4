const EVENT_TYPES = {
  ORDER_CREATED: "order_created",
  ORDER_STATUS_UPDATED: "order_status_updated",
  ORDER_CANCELLED: "order_cancelled",
  ORDER_DELETED: "order_deleted",
  SHIPPER_ASSIGNED: "shipper_assigned",
  SHIPPER_DELIVERING: "shipper_delivering",
  SHIPPER_COMPLETED: "shipper_completed",
  FOOD_CREATED: "food_created",
  FOOD_UPDATED: "food_updated",
  FOOD_DELETED: "food_deleted",
  ML_TRAINED: "ml_trained",
  ML_PREDICTED: "ml_predicted",
};

module.exports = EVENT_TYPES;
