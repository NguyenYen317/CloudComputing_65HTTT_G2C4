const orderService = require("../services/order.service");
const handleControllerError = require("../utils/controllerError");

async function listOrders(req, res) {
  try {
    res.json(await orderService.listOrders({ userId: req.query.userId }));
  } catch (error) {
    handleControllerError(res, error);
  }
}

async function createOrder(req, res) {
  try {
    res.json(await orderService.createOrder(req.body));
  } catch (error) {
    handleControllerError(res, error);
  }
}

async function updateOrderStatus(req, res) {
  try {
    res.json(await orderService.updateOrderStatus(req.params.id || req.params.orderId, req.body.status));
  } catch (error) {
    handleControllerError(res, error);
  }
}

async function cancelOrder(req, res) {
  try {
    res.json(await orderService.cancelOrder(req.params.id || req.params.orderId));
  } catch (error) {
    handleControllerError(res, error);
  }
}

async function deleteOrder(req, res) {
  try {
    res.json(await orderService.deleteOrder(req.params.id || req.params.orderId));
  } catch (error) {
    handleControllerError(res, error);
  }
}

async function getOrderDetail(req, res) {
  try {
    res.json(await orderService.getOrderDetail(req.params.orderId));
  } catch (error) {
    handleControllerError(res, error);
  }
}

async function listOrdersByUser(req, res) {
  try {
    res.json(await orderService.listOrdersByUser(req.params.userId));
  } catch (error) {
    handleControllerError(res, error);
  }
}

module.exports = {
  listOrders,
  createOrder,
  updateOrderStatus,
  cancelOrder,
  deleteOrder,
  getOrderDetail,
  listOrdersByUser,
};
