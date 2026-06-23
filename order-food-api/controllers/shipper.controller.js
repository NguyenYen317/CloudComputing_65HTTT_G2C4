const shipperService = require("../services/shipper.service");
const handleControllerError = require("../utils/controllerError");

async function getAvailableOrders(req, res) {
  try {
    res.json(await shipperService.listAvailableOrders());
  } catch (error) {
    handleControllerError(res, error);
  }
}

async function getMyDeliveryOrders(req, res) {
  try {
    res.json(await shipperService.listMyDeliveryOrders(req.params.shipperId));
  } catch (error) {
    handleControllerError(res, error);
  }
}

async function getDeliveryOrderDetail(req, res) {
  try {
    res.json(await shipperService.getDeliveryOrderDetail(req.params.orderId));
  } catch (error) {
    handleControllerError(res, error);
  }
}

async function acceptOrder(req, res) {
  try {
    res.json(await shipperService.acceptOrder(req.params.orderId, req.body));
  } catch (error) {
    handleControllerError(res, error);
  }
}

async function startDelivering(req, res) {
  try {
    res.json(await shipperService.startDelivering(req.params.orderId, req.body));
  } catch (error) {
    handleControllerError(res, error);
  }
}

async function completeOrder(req, res) {
  try {
    res.json(await shipperService.completeOrder(req.params.orderId, req.body));
  } catch (error) {
    handleControllerError(res, error);
  }
}

module.exports = {
  getAvailableOrders,
  getMyDeliveryOrders,
  getDeliveryOrderDetail,
  acceptOrder,
  startDelivering,
  completeOrder,
};
